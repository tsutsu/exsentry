defmodule ExSentry.Model.RequestTest do
  use ExSpec, async: true
  import ExSentry.Model.Request
  doctest ExSentry.Model.Request

  @headers %{"header1" => "value1, value3", "header2" => "value2"}

  @request %ExSentry.Model.Request{
    url: "/your/mom",
    method: "POST",
    data: "body",
    query_string: "your=mom",
    headers: @headers,
    cookies: %{"mm" => "food"},
    env: %{
      remote_ip: "127.0.0.1"
    }
  }

  ExSpec.describe "from_conn" do
    it "makes a valid ExSentry.Model.Request from conn" do
      assert(@request == from_conn(FakeConn.conn))
    end
  end

  ExSpec.describe "serialization" do
    it "serializes to JSON" do
      assert({:ok, _} = from_conn(FakeConn.conn) |> Poison.encode)
    end
  end
end

