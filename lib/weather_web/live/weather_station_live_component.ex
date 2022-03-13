defmodule WeatherWeb.WeatherStationLiveComponent do
  @moduledoc """
  Defines a LiveView stateful component which, given a weather station ID, retrieves current
  weather data for that station and displays it.
  """
  use WeatherWeb, :live_component

  require Logger

  @impl true
  def update(%{station: station, station_data_fn: station_data_fn}, socket) do
    {:ok, assign_station_data(socket, station, station_data_fn)}
  end

  defp assign_station_data(socket, station, station_data_fn) do
    assign(socket, :station_data, station_data_fn.(station))
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
        <.conditions_summary class="mr-2"
          icon={@station_data.icon} conditions={@station_data.conditions} />
      </div>
      <.station_summary  station_data={@station_data} />
    """
  end

  defp conditions_icon(assigns) do
    ~H"""
    <img src={"http://openweathermap.org/img/wn/#{@icon}.png"}/>
    """
  end

  defp station_summary(assigns) do
    ~H"""
    <div class="w-3/5 text-sm">
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
      <div class="mr-2">
        <.conditions_icon icon={@icon}/>
        <span class="conditions text-sm"><%= @conditions %></span>
      </div>
    """
  end
end
