defmodule ExSentry.Plug do
  @moduledoc ~S"""
  ExSentry.Plug is a Plug error handler which can be used to automatically
  intercept and report to Sentry any exceptions encountered by a Plug-based
  web application.

  To use, configure `mix.exs` and `config.exs` as described in README.md,
  then add `use ExSentry.Plug` near the top of your webapp's plug stack,
  for example:

      defmodule MyApp.Router do
        use MyApp.Web, :router
        use ExSentry.Plug

        pipeline :browser do
        ...
  """

  use Plug.ErrorHandler
  use Plug.Builder
  plug CopyRequestBody

  defmodule CopyRequestBody do
    def init(opts), do: opts

    def call(conn, opts) do
      copy? = cond do
                Keyword.has_key?(opts, :copy_request_body) ->
                  opts[:copy_request_body]
                true ->
                  Application.get_env(:exsentry, :copy_request_body) || false
                end

      bytes = opts[:copy_request_body_bytes] ||
              Application.get_env(:exsentry, :copy_request_body_bytes) ||
              10000

      if copy? do
        case Plug.Conn.read_body(conn, length: bytes) do
          {:ok, body, _} ->
            IO.puts "WOW LOL YEAH"
            conn |> Plug.Conn.put_private(:exsentry_request_body, body)
          _ ->
            IO.puts "OMG LOL NO"
            conn
        end
      else
        conn
      end
    end
  end

  # legacy
  defmacro __using__(opts \\ []) do
    quote do
      use Plug.Builder
      plug ExSentry.Plug
    end
  end

  ## Ignore missing Plug and Phoenix routes
  defp handle_errors(_conn, %{reason: %FunctionClauseError{function: :do_match}}) do
    nil
  end

  if :code.is_loaded(Phoenix) do
    defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
      nil
    end
  end

  @spec handle_errors(%Plug.Conn{}, map) :: :ok
  defp handle_errors(conn, %{reason: exception, stack: stack}) do
    req = ExSentry.Model.Request.from_conn(conn)
    st = ExSentry.Model.Stacktrace.from_stacktrace(stack)
    ExSentry.capture_exception(exception, request: req, stacktrace: st)
  end
end

