defmodule WeatherWeb.WeatherLiveTests do
  use WeatherWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  use WeatherWeb.ConnCase


  test "displays home page", %{conn: conn} do
    {:ok, view, _} = live(conn, "/")
  end

  test "add a station", %{conn: conn} do
    {:ok, view, _} = live(conn, "/")

    html =
      view
      |> element("#add_station_form")
      |> render_submit(%{"station" => %{"station_id" => "Paris"}})

    assert html =~ "station_info_Paris"

  end
end
