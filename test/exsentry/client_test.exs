defmodule ExSentry.ClientTest do
  use ExSpec, async: false
  import Mock
  import ExSentry.Client, only: [capture_exception: 4, capture_message: 3]
  alias ExSentry.Client.State
  doctest ExSentry.Client

  defp with_mock_http(fun) do
    with_mock ExSentry.Sender, [
      get_connection: fn (_) -> :pretend_this_is_a_conn_ref end,
      send_request: fn (_conn_ref, _url, headers, payload) ->
        assert([] != headers |> Enum.filter(fn ({k,_}) -> k == "X-Sentry-Auth" end))
        assert([] != headers |> Enum.filter(fn ({k,_}) -> k == "Content-Type" end))
        body = Poison.decode!(payload)
        assert("hey" == body["message"])
        :lol
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
          e ->
            assert(:lol == capture_exception(e, System.stacktrace, [], %State{}))
        end
      end
    end
  end

  context "capture_message" do
    it "dispatches a well-formed request" do
      with_mock_http fn ->
        assert(:lol == capture_message("hey", [], %State{}))
      end
    end
  end

end
