defmodule ExSentry.PlugTest do
  use ExSpec, async: true
  doctest ExSentry.Plug

  describe "handle_errors" do
    it "returns :ok just like capture_exception" do
      try do
        raise "omglol"
      rescue
        e ->
          st = System.stacktrace
          assert(:ok == ExSentry.Plug.handle_errors(FakeConn.conn, %{reason: e, stack: st}))
      end
    end
  end

  defmodule NotFoundError do
    defexception plug_status: 404, message: "not found"
  end

  describe "with_whitelists" do
    it "respects :exception_whitelist" do
      e = %NotFoundError{}
      opts = [exception_whitelist: [NotFoundError]]
      assert :whitelisted = ExSentry.Plug.with_whitelists opts, e, fn ->
        assert false
      end
    end

    it "respects :plug_status_whitelist" do
      e = %NotFoundError{}
      opts = [plug_status_whitelist: [404]]
      assert :whitelisted = ExSentry.Plug.with_whitelists opts, e, fn ->
        assert false
      end
    end

    it "runs function otherwise" do
      e = %NotFoundError{}
      opts = [exception_whitelist: [ArgumentError],
              plug_status_whitelist: [401]]
      assert :cool = ExSentry.Plug.with_whitelists opts, e, fn ->
        :cool
      end
    end
  end
end

