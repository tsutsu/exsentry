defmodule ExSentry.IntegrationTest do
  use ExSpec, async: false
  import Mock

  defp with_mock_http(fun) do
    with_mock ExSentry.Sender, [
      get_connection: fn (_) -> :pretend_this_is_a_conn_ref end,
      send_request: fn (_,_,_,_) -> :ok end
    ] do
      fun.()
    end
  end

  context "integration" do
    it "ExSentry.new to HTTPotion.post, via capture_message" do
      with_mock_http fn ->
        client = ExSentry.new("http://user:pass@example.com/1")
        assert(:ok == client |> ExSentry.capture_message("whoa"))
        :timer.sleep(300)
        assert called ExSentry.Sender.send_request(:_, :_, :_, :_)
      end
    end

    it "ExSentry.new to HTTPotion.post, via capture_exceptions" do
      with_mock_http fn ->
        client = ExSentry.new("http://user:pass@example.com/1")
        try do
          ExSentry.capture_exceptions client, fn -> raise "whee" end
        rescue
          _ -> :ok
        end
        :timer.sleep(300)
        assert called ExSentry.Sender.send_request(:_, :_, :_, :_)
      end
    end
  end
end
