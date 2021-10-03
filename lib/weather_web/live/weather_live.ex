defmodule WeatherWeb.WeatherLive do
  use WeatherWeb, :live_view

  @impl true
  def mount(_params, _sess, socket), do: {:ok, socket}

end
