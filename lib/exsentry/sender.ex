defmodule ExSentry.Sender do
  @moduledoc ~S"""
  A GenServer which handles the sending of a single Sentry request.
  Invoked from ExSentry.Client.
  """

  defmodule State do
    defstruct delay: 1000,
              timeout: 3000,
              retries: 3,
              status: :launched,
              logging: true,
              testing: false
  end

  require Logger
  use GenServer

  @doc ~S"""
  Sends a POST request to the given Sentry URL with the given headers and body,
  using the given ExSentry.Sender PID.
  Handles retry, exponential backoff, and error logging.

  Returns pid of new ExSentry.Sender process.
  """
  @spec send_request(pid, String.t, [{String.t, String.t}], String.t) :: pid
  def send_request(pid, url, headers, body) do
    GenServer.cast(pid, {:send, url, headers, body, 0})
    pid
  end

  @doc ~S"""
  Sends a POST request to the given Sentry URL with the given headers and body,
  spawning a new ExSentry.Sender process to handle it.
  Handles retry, exponential backoff, and error logging.

  Returns pid of ExSentry.Sender process.
  """
  @spec send_request(String.t, [{String.t, String.t}], String.t) :: pid
  def send_request(url, headers, body) do
    {:ok, pid} = GenServer.start_link(ExSentry.Sender, %{delay: 1000})
    send_request(pid, url, headers, body)
  end


  def init(state) do
    {:ok, Map.merge(%State{}, state)}
  end

  ## Returns `state`.  Useful for testing.
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  ## Stops this process unless state[:testing] == true.
  def handle_cast(:stop, state) do
    if state.testing, do: {:noreply, state}, else: {:stop, :normal, state}
  end

  ## Handles the sending of requests.
  def handle_cast({:send, url, headers, body, retries}, state) do
    delay = state.delay * :math.pow(2, retries)
    delay_with_jitter = trunc(delay + 0.1 * (:random.uniform) * delay)
    log = if state.logging do
            fn (level, msg) -> Logger.log(level, msg) end
          else
            fn (_, _) -> nil end
          end
    body_str = body |> Poison.encode!

    if (retries >= state.retries) do
      log.(:error, "ExSentry reached max retries, aborting.")
      stop(self, %{state | status: :max_retries})
    else
      resp = try do
               HTTPotion.post(url, timeout: state.timeout, body: body_str, headers: headers)
             rescue
                e ->
                  %{status_code: 555,
                    exception: e,
                    headers: %{hdrs: ["x-sentry-error": "Request timed out"]}}
             end
      resp_headers = resp |> Map.get(:headers, %{}) |> Map.get(:hdrs, [])
      x_sentry_error = Keyword.get(resp_headers, :"x-sentry-error", "(no error given)")

      case div(resp.status_code, 100) do
        2 -> # success
          stop(self, %{state | status: :success})

        3 -> # redirect, follow it
          location = Keyword.get(resp_headers, :"location", "")
          log.(:info, "ExSentry got HTTP redirect, following it.")
          log.(:info, "Location: #{location}")
          :timer.sleep(delay_with_jitter)
          handle_cast({:send, location, headers, body, retries+1},
                      %{state | status: :redirect})

        4 -> # our fault, don't retry
          log.(:error, "ExSentry got HTTP status #{resp.status_code}, aborting.")
          log.(:error, "X-Sentry-Error: #{x_sentry_error}")
          stop(self, %{state | status: :client_error})

        5 -> # server error or timeout, retry
          log.(:info, "ExSentry got HTTP status #{resp.status_code}, retrying.")
          log.(:info, "X-Sentry-Error: #{x_sentry_error}")
          :timer.sleep(delay_with_jitter)
          handle_cast({:send, url, headers, body, retries+1},
                      %{state | status: :retrying})

        _ ->
          log.(:error, "ExSentry got unhandled HTTP status #{resp.status_code}, aborting.")
          log.(:error, "X-Sentry-Error: #{x_sentry_error}")
          stop(self, %{state | status: :unhandled_status})
      end
    end
  end

  defp stop(server, state) do
    GenServer.cast(server, :stop)
    {:noreply, state}
  end

end
