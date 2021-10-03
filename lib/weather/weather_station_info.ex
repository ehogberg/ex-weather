defmodule Weather.WeatherStationInfo do

  def format_weather_info_url(station) do
    "https://api.openweathermap.org/data/2.5/weather?appid=7ad3656d8650368a5116994d7b9a5610&units=imperial&q=" <> station
  end

  def call_weather_info_webservice(station) do
    station
    |> format_weather_info_url
    |> HTTPoison.get!
  end

  def extract_weather_info_from_response(resp) do
    resp
    |> Map.get(:body)
    |> Jason.decode(keys: :atoms)
  end
  
  def get_weather_station_info(station) do
    with %{status_code: 200} = resp <- call_weather_info_webservice(station),
	 {:ok, body} <- extract_weather_info_from_response(resp) do
      body
    else
      %{status_code: 404} -> %{error_message: "Could not find weather station."}
      _error -> %{error_message: "Something went wrong!"}
    end
  end
 
end
