defmodule ExSentry.SenderTest do
  use ExSpec, async: false
  import Mock
  import ExSentry.Sender, only: [send_request: 3, send_request: 4]
  doctest ExSentry.Sender

  setup do
    {:ok, pid} = GenServer.start_link(ExSentry.Sender,
      %{testing: true, logging: false, delay: 1})
    {:ok, sender: pid}
  end

  @response_1xx %{status_code: 100, headers: %{}}
  @response_2xx %{status_code: 200, headers: %{}}
  @response_3xx %{status_code: 301, headers: %{hdrs: [location: "https://example.com"]}}
  @response_4xx %{status_code: 400, headers: %{hdrs: [{:"x-sentry-error", "omg"}]}}
  @response_5xx %{status_code: 503, headers: %{hdrs: [{:"x-sentry-error", "lol"}]}}

  ExSpec.describe "send_request/3" do
    it "launches and stops server automatically" do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_2xx end
      ] do
        pid = send_request("", [], "")
        :timer.sleep(300)
        assert(false == Process.alive?(pid))
      end
    end
  end

  ExSpec.describe "send_request/4" do
    it "handles 2xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_2xx end
      ] do
        send_request(sender, "", [], "")
        state = GenServer.call(sender, :state)
        assert(:success == state.status)
      end
    end

    it "handles 3xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_3xx end
      ] do
        send_request(sender, "", [], "")
        state = GenServer.call(sender, :state)
        assert(:max_retries == state.status)
      end
    end

    it "handles 4xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_4xx end
      ] do
        send_request(sender, "", [], "")
        state = GenServer.call(sender, :state)
        assert(:client_error == state.status)
      end
    end

    it "handles 5xx", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_5xx end
      ] do
        send_request(sender, "", [], "")
        state = GenServer.call(sender, :state)
        assert(:max_retries == state.status)
      end
    end

    it "handles other statuses", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> @response_1xx end
      ] do
        send_request(sender, "", [], "")
        state = GenServer.call(sender, :state)
        assert(:unhandled_status == state.status)
      end
    end

    it "handles timeouts", %{sender: sender} do
      with_mock HTTPotion, [
        post: fn (_url, _opts) -> :meck.exception(:error, :lol) end
      ] do
        send_request(sender, "", [], "")
        state = GenServer.call(sender, :state)
        assert(:max_retries == state.status)
      end

    end
  end

end
