defmodule ExSentry.Model.UserTest do
  use ExSpec, async: true
  doctest ExSentry.Model.User

  @user %ExSentry.Model.User{
    id: 123,
    email: "a@b.com",
    username: "a",
    ip_address: "127.0.0.1"
  }

  context "serialization" do
    it "serializes to JSON" do
      assert({:ok, _} = @user |> Poison.encode)
    end
  end
end

