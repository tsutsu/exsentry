defmodule ExSentry.PlugTest do
  use ExSpec, async: false
  doctest ExSentry.Plug
  import Mock

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

  describe "use ExSentry.Plug" do
    it "works" do
      with_mock ExSentry, [capture_exception: fn(_e, _o) -> :krad end] do
        try do
          FakeConn.conn |> ExSentry.RaisingPlug.call([])
        rescue
          _ -> :ok
        end
        assert called ExSentry.capture_exception(:_, :_)
      end
    end

    describe "copy_request_body" do
      it "copies request body when true" do
        conn = %{FakeConn.conn | private: []}
        with_mock Plug.Conn, [read_body: fn(_c, _o) -> {:ok, "wow", 22} end] do
          private = ExSentry.CopyPlug.call(conn, []).private
          assert called Plug.Conn.read_body(:_, :_)
          assert("wow" == private[:exsentry_request_body])
        end
      end

      it "does not copy request when false" do
        conn = %{FakeConn.conn | private: []}
        with_mock Plug.Conn, [read_body: fn(_c, _o) -> {:ok, "wow", 22} end] do
          private = ExSentry.NoCopyPlug.call(conn, []).private
          assert !called Plug.Conn.read_body(:_, :_)
          assert(nil == private[:exsentry_request_body])
        end
      end
    end
  end
end

defmodule ExSentry.RaisingPlug do
  use ExSentry.Plug
  def call(_conn, _opts), do: raise "WAT"
  def init(opts), do: opts
end

defmodule ExSentry.CopyPlug do
  use ExSentry.Plug, copy_request_body: true
  def call(conn, _opts), do: conn
  def init(opts), do: opts
end

defmodule ExSentry.NoCopyPlug do
  use ExSentry.Plug, copy_request_body: false
  def call(conn, _opts), do: conn
  def init(opts), do: opts
end

