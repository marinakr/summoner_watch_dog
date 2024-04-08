defmodule SummonerWatchDogWeb.ErrorJSONTest do
  use SummonerWatchDogWeb.ConnCase, async: true

  test "renders 404" do
    assert SummonerWatchDogWeb.ErrorJSON.render("404.json", %{message: "data not found"}) == %{
             errors: %{detail: "Not Found", message: "data not found"}
           }
  end

  test "renders 500" do
    assert SummonerWatchDogWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
