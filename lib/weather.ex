defmodule Weather do

  alias Weather.WeatherInfoServiceSupervisor
  alias Weather.WeatherInfoService

  def start_weather_station_info(station_id) do
    WeatherInfoServiceSupervisor.start_child(station_id)
  end

  def get_current_station_info(station_id) do
    WeatherInfoService.station_current_conditions(station_id)
  end
end
