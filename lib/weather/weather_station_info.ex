defmodule Weather.WeatherStationInfo do
  @moduledoc """
  Handles the retrieval of weather information for a weather station using the
  OpenWeatherMap platform.
  """

  require Logger

  defstruct [
    :name, :icon, :conditions, :curr_temp,
    :feels_like, :temp_max, :temp_min,
    :humidity, :weather_updated_at, :weather_checked_at
  ]

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
    Logger.debug("Retrieving weather station info for station: #{station}")

    station_info =
      with %{status_code: 200} = resp <- call_weather_info_webservice(station),
           {:ok, body} <- extract_weather_info_from_response(resp),
           station_data <- normalize_station_data(body) do
        Logger.debug("Successfully retrieved station data for #{station}.")
        station_data
      else
        %{status_code: 404} ->
          Logger.warning("No such station: #{station}.")
          %{error_message: "Could not find weather station: #{station}."}

        error ->
          Logger.warning("Error while retrieving data for station #{station}: #{inspect(error)}")
          %{error_message: "Something went wrong retrieving station #{station}!"}
      end

    Map.put(station_info, :weather_checked_at, DateTime.utc_now())
  end

  defp normalize_station_data(raw_station_data) do
    current_conditions = List.first(raw_station_data.weather)

    %__MODULE__{
      name: raw_station_data.name,
      icon: current_conditions.icon,
      conditions: current_conditions.description,
      curr_temp: trunc(raw_station_data.main.temp),
      feels_like: trunc(raw_station_data.main.feels_like),
      temp_max: trunc(raw_station_data.main.temp_max),
      temp_min: trunc(raw_station_data.main.temp_min),
      humidity: trunc(raw_station_data.main.humidity),
      weather_updated_at: DateTime.from_unix!(raw_station_data.dt),
      weather_checked_at: DateTime.utc_now()
    }
  end
end
