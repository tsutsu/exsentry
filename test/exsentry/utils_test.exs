defmodule ExSentry.UtilsTest do
  use ExSpec, async: true
  doctest ExSentry.Utils

  context "version" do
    it "returns the correct version string" do
      assert(Regex.match?(~r"^\d+\.\d+(?:\.\d+)?", ExSentry.Utils.version))
    end
  end

  context "versions" do
    it "returns correct version strings" do
      ExSentry.Utils.versions
      |> Enum.map(fn ({_k, v}) ->
           assert(Regex.match?(~r"^\d+\.\d+(?:\.\d+)?", v))
         end)
    end

    it "has the same rank as Application.loaded_applications" do
      assert(Enum.count(Application.loaded_applications) ==
             Enum.count(Map.to_list(ExSentry.Utils.versions)))
    end
  end

  context "datetime_now" do
    it "returns an ISO 8601 datetime string" do
      dt_str = ExSentry.Utils.datetime_now
      assert(String.match?(dt_str, ~r/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ/))
    end
  end
end

