defmodule ExSentry.IntegrationTest do
  use ExSpec, async: false
  import Mock

  defp with_mock_http(fun) do
    with_mock :hackney, [
      request: fn (_method, _url, _headers, _payload) -> :ok end
    ] do
      fun.()
      Process.sleep(300)
      assert called :hackney.request(:_, :_, :_, :_)
    end
  end

  context "integration" do
    it "ExSentry.new to HTTPotion.post, via capture_message" do
      with_mock_http fn ->
        client = ExSentry.new("http://user:pass@example.com/1")
        assert(:ok == client |> ExSentry.capture_message("whoa"))
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
      end
    end
  end
end

