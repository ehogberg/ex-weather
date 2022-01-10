defmodule WeatherWeb.WeatherLiveRenderTest do
  use WeatherWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Phoenix LiveView Weather"
    assert render(page_live) =~ "Phoenix LiveView Weather"
    assert render(page_live) =~ "Chicago"
  end
end
