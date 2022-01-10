defmodule Weather.WeatherStationInfo do
  @moduledoc """
  """
  def format_weather_info_url(station) do
    "https://api.openweathermap.org/data/2.5/weather?" <>
      "appid=#{Application.fetch_env!(:weather, :weather_service_api_key)}" <>
      "&units=imperial&q=#{station}"
  end

  def call_weather_info_webservice(station) do
    station
    |> format_weather_info_url
    |> HTTPoison.get!()
  end

  def extract_weather_info_from_response(resp) do
    resp
    |> Map.get(:body)
    |> Jason.decode(keys: :atoms)
  end

  def get_weather_station_info(station) do
    IO.puts("Retrieving weather station info for station: #{station}")

    with %{status_code: 200} = resp <- call_weather_info_webservice(station),
         {:ok, body} <- extract_weather_info_from_response(resp) do
      body
    else
      %{status_code: 404} -> %{error_message: "Could not find weather station: #{station}."}
      _error -> %{error_message: "Something went wrong retrieving station #{station}!"}
    end
  end
end
