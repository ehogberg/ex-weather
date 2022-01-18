defmodule Weather.WeatherStationInfo do
  @moduledoc """
  """
  def format_weather_info_url(station) do
    "https://api.openweathermap.org/data/2.5/weather?" <>
      "appid=#{Application.fetch_env!(:weather, :weather_service_api_key)}" <>
      "&units=imperial&q=#{station}"
  end

  defp call_weather_info_webservice(station) do
    station
    |> format_weather_info_url
    |> HTTPoison.get!()
  end

  defp extract_weather_info_from_response(resp) do
    resp
    |> Map.get(:body)
    |> Jason.decode(keys: :atoms)
  end

  def get_weather_station_info(station) do
    IO.puts("Retrieving weather station info for station: #{station}")

    with %{status_code: 200} = resp <- call_weather_info_webservice(station),
         {:ok, body} <- extract_weather_info_from_response(resp),
         station_data <- normalize_station_data(body) do
      station_data
    else
      %{status_code: 404} -> %{error_message: "Could not find weather station: #{station}."}
      _error -> %{error_message: "Something went wrong retrieving station #{station}!"}
    end
  end

  defp normalize_station_data(raw_station_data) do
    %{
      name: raw_station_data.name,
      icon: get_in(raw_station_data.weather,[Access.at(0),:icon]),
      conditions: get_in(raw_station_data.weather,[Access.at(0), :description]),
      curr_temp: trunc(raw_station_data.main.temp),
      feels_like: trunc(raw_station_data.main.feels_like),
      temp_max: trunc(raw_station_data.main.temp_max),
      temp_min: trunc(raw_station_data.main.temp_min),
      humidity: trunc(raw_station_data.main.humidity)
    }
  end
end
