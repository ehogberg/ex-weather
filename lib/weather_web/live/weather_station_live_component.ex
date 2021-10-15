defmodule WeatherWeb.WeatherStationLiveComponent do
  use WeatherWeb, :live_component

  alias Weather.WeatherStationInfo

  @impl true
  def update(%{station: station} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_station_data(station)}
  end

  def assign_station_data(socket,station) do
    station_info = WeatherStationInfo.get_weather_station_info(station)
    assign(socket, :station_data,station_info)
  end
end
