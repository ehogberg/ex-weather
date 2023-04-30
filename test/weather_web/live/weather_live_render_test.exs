defmodule WeatherWeb.WeatherLiveRenderTest do
  use WeatherWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "LiveView Weather"
    assert render(page_live) =~ "LiveView Weather"
  end
end
