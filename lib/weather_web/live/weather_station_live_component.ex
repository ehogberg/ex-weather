defmodule WeatherWeb.WeatherStationLiveComponent do
  @moduledoc """
  Defines a LiveView stateful component which, given a weather station ID, retrieves current
  weather data for that station and displays it.
  """
  use WeatherWeb, :live_component

  alias Weather.WeatherStationInfo

  @impl true
  def update(%{station: station} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_station_data(station)}
  end

  defp assign_station_data(socket, station) do
    station_info = WeatherStationInfo.get_weather_station_info(station)
    assign(socket, :station_data, station_info)
  end
end
