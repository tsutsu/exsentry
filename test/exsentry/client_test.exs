defmodule ExSentry.ClientTest do
  use ExSpec, async: false
  import Mock
  doctest ExSentry.Client

  defp with_mock_http(fun) do
    with_mock :hackney, [
      request: fn (_method, _url, headers, payload) ->
        assert([] != headers |> Enum.filter(fn ({k,_}) -> k == "X-Sentry-Auth" end))
        assert([] != headers |> Enum.filter(fn ({k,_}) -> k == "Content-Type" end))
        body = Poison.decode!(payload)
        assert("hey" == body["message"])
      end
    ] do
      fun.()
    end
  end

  context "capture_exception" do
    it "dispatches a well-formed request" do
      with_mock_http fn ->
        try do
          raise "hey"
        rescue
          e -> assert(:ok == ExSentry.capture_exception(e))
        end
      end
    end
  end

  context "capture_message" do
    it "dispatches a well-formed request" do
      with_mock_http fn ->
        assert(:ok == ExSentry.capture_message("hey"))
      end
    end
  end

end
