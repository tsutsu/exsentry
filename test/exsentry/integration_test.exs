defmodule ExSentry.IntegrationTest do
  use ExSpec, async: false
  import Mock

  ExSpec.describe "integration" do
    it "ExSentry.new to HTTPotion.post, via capture_message" do
      with_mock HTTPotion, [
        post: fn (url, _opts) ->
          assert("http://example.com/api/1/store/" == url)
          %{status_code: 200, headers: %{}}
        end
      ] do
        client = ExSentry.new("http://user:pass@example.com/1")
        assert(:ok == client |> ExSentry.capture_message("whoa"))
        :timer.sleep(300)
        assert called HTTPotion.post(:_, :_)
      end
    end

    it "ExSentry.new to HTTPotion.post, via capture_exceptions" do
      with_mock HTTPotion, [
        post: fn (url, _opts) ->
          assert("http://example.com/api/1/store/" == url)
          %{status_code: 200, headers: %{}}
        end
      ] do
        client = ExSentry.new("http://user:pass@example.com/1")
        try do
          ExSentry.capture_exceptions client, fn -> raise "whee" end
        rescue
          _ -> :ok
        end
        :timer.sleep(300)
        assert called HTTPotion.post(:_, :_)
      end
    end
  end
end
