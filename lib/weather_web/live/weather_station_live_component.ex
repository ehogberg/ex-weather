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

  @impl true
  def render(assigns) do
    ~H"""
      <div class="station-info flex flex-row mb-3">
        <.station_component station_data={@station_data} />
      </div>
    """
  end

  defp station_component(assigns) when is_map_key(assigns.station_data, :error_message) do
    ~H"""
      <div class="summary">
        <%= @station_data.error_message %>
      </div>
    """
  end

  defp station_component(assigns) do
    ~H"""
      <div class="summary w-2/5">
        <div class="text-lg font-bold"><%= @station_data.name %></div>
        <.conditions_summary class="mr-2" station_data={@station_data} />
      </div>
      <.station_summary class="w-3/5 text-sm" station_data={@station_data} />
    """
  end

  defp conditions_icon(assigns) do
    ~H"""
    <img src={"http://openweathermap.org/img/wn/#{@icon}.png"} {Map.drop(assigns,[:icon])}/>
    """
  end

  defp station_summary(assigns) do
    ~H"""
    <div {Map.drop(assigns,[:station_data])}>
      Curr. temp.: <%= @station_data.curr_temp %>&deg; F<br>
      Feels like: <%= @station_data.feels_like %>&deg; F<br>
      Today's high: <%= @station_data.temp_max %>&deg; F<br>
      Today's low: <%= @station_data.temp_min %>&deg; F<br>
      Rel. humidity: <%= @station_data.humidity %>%<br>
    </div>
    """
  end

  defp conditions_summary(assigns) do
    ~H"""
      <div {Map.drop(assigns, [:station_data])}>
        <.conditions_icon icon={@station_data.icon} class="weather-icon"/>
        <span class="conditions text-sm"><%= @station_data.conditions %></span>
      </div>
    """
  end
end
