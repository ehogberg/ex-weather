defmodule WeatherWeb.WeatherLive do
  use WeatherWeb, :live_view
  import WeatherWeb.WeatherLiveComponents
  alias WeatherWeb.{
    Endpoint,
    StationInfoLive
  }
  alias Weather
  require Logger

  @impl true
  def mount(params, _session, socket) do
    weather_stations = if connected?(socket) do
      Endpoint.subscribe("station_updates")
      initial_stations(Map.get(params, "stations", ""))
    else
      []
    end

    tz = Map.get(params, "tz", "Etc/UTC")

    {
      :ok,
      socket
      |> stream_configure(:weather_stations, dom_id: &("station-#{&1}.id"))
      |> assign_weather_stations(weather_stations)
      |> assign_tz_data(tz)
    }
  end

  defp initial_stations(stations) when stations == "", do: ["Chicago", "New York"]
  defp initial_stations(stations), do: String.split(stations, "|")

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :uri, base_uri(uri))}
  end

  defp base_uri(uri) do
    parsed_uri = URI.parse(uri)
    "#{parsed_uri.scheme}://#{parsed_uri.authority}/"
  end

  defp assign_weather_stations(socket, weather_stations) do
    socket
    |> stream(:weather_stations, weather_stations)
    |> assign(:full_station_list, weather_stations)
  end

  defp assign_tz_data(socket, tz) do
    socket
    |> assign(:tz, tz)
    |> assign(:valid_tz?, Tzdata.zone_exists?(tz))
  end

  @impl true
  def handle_event(
    "add_station",
    %{"station" => %{"station_id" => station_id}},
    socket
  ) do

    {
      :noreply,
      socket
      |> stream_insert(:weather_stations,station_id)
      |> assign(:full_station_list, socket.assigns.full_station_list ++ [station_id])
    }
  end

  @impl true
  def handle_event(
    "clear_station",
    %{"station-id" => station_id},
    socket
  ) do
    {
      :noreply,
      socket
      |> stream_delete(:weather_stations, station_id)
      |> assign(:full_station_list, socket.assigns.full_station_list -- [station_id])
    }
  end

  @impl true
  def handle_event(_evt, _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(
    %{event: "station_info_updated", payload: %{station_id: station_id}},
    %{assigns: %{full_station_list: weather_stations}} = socket
  ) do
    Logger.debug("Received station_info_updated message for #{station_id}")
    if station_id in weather_stations do
      Logger.debug("Notifying component #{station_id} of weather update.")
      send_update(StationInfoLive, id: station_id)
    end

    {:noreply, socket}
  end

  def handle_info(evt, socket) do
    Logger.debug("Event received: #{inspect(evt)}")
    {:noreply, socket}
  end
end
