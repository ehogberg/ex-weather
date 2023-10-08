defmodule WeatherWeb.StationInfoLive do
  use WeatherWeb, :live_component
  import WeatherWeb.WeatherLiveComponents
  alias Weather
  require Logger

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_weather_station_data()
    }
  end

  defp assign_weather_station_data(
    %{assigns: %{station_id: station_id}} = socket
  ) do
    Logger.debug("Retrieving updated weather data for station: #{station_id}")
    current_weather = Weather.get_current_station_info(station_id)
    Logger.debug("Updated weather for station #{station_id}: #{inspect(current_weather)}")
    assign(
      socket,
      :station_data,
      current_weather
    )
  end

  defp assign_weather_station_data(
    %{assigns: %{id: id}} = socket
  ) do
    Weather.start_weather_station_info(id)

    socket
    |> assign(:station_id, id)
    |> assign(:station_data, Weather.get_current_station_info(id))
  end
end
