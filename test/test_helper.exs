ExUnit.start()

defmodule FakeConn do
  defmodule Adapter do
    #def read_req_body(conn, _opts) do
      #{:ok, "body", conn}
    #end
  end

  def req_headers do
    [
      {"header1", "value1"},
      {"header2", "value2"},
      {"header1", "value3"}
    ]
  end

  def conn do
    %Plug.Conn{
      adapter: {Adapter, :hi_mom},
      request_path: "/your/mom",
      method: "POST",
      query_string: "your=mom",
      req_headers: req_headers,
      remote_ip: {127,0,0,1},
      req_cookies: %{"mm" => "food"},
      private: [
        exsentry_request_body: "body",
      ]
    }
  end
end

