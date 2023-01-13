defmodule WeatherWeb.WeatherLive do
  @moduledoc """
  A LiveView stateful component, providing a container of WeatherWeb.WeatherStationLiveComponent's,
  and exposes functionality which can be used to add and remove new weather station components from
  the container.

  This view also serves as state controller for the list of stations being displayed.  Nested
  components handle the input mechanics of adding new stations or deleting active ones from the
  working list.  Those components send :add_station and :clear_station messages which are
  caught by the view using handle_info(evt,socket) to update its list.
  """
  use WeatherWeb, :live_view
  require Logger
  import Weather.Util
  alias Weather.WeatherInfoService
  alias Weather.WeatherInfoServiceSupervisor
  alias Weather.WeatherServiceMonitor

  @doc """
  Initializes the component state by creating a default set of WeatherStationLiveComponent's
  and sets up a component data refresh frequency (by default, every 10 minutes.)

  The default initial set of weather stations can be overriden at mount time by passing a `"stations"`
  value in the params.   The stations var should be a pipe-delimited list of weather station identifiers
  to use as the new initial set for this component instance.  Example:

  `New York,NY,US|London|Paris,FR|Zurich`

  """
  @impl true
  def mount(params, _sess, socket) do
    stations =
      params
      |> Map.get("stations", "")
      |> parse_stations()

    tz = Map.get(params,"tz", "Etc/UTC")

    {:ok,
     socket
     |> assign_default_stations(stations)
     |> assign(:timezone, tz)
    }
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :uri, base_uri(uri))}
  end

  defp base_uri(uri) do
    parsed_uri = URI.parse(uri)
    "#{parsed_uri.scheme}://#{parsed_uri.authority}/"
  end

  @impl true
  def handle_info({:add_station, station_id}, socket),
    do: {:noreply, assign_new_station(socket, normalize_string(station_id))}

  @impl true
  def handle_info({:clear_station, station_id}, socket),
    do: {:noreply, clear_station(socket, station_id)}

  @impl true
  def handle_info(
        {:station_info_updated, station_id, current_conditions},
        socket
      ) do
    Logger.debug("Received current conditions update for station #{station_id}.")

    {:noreply,
     update_station_current_conditions(
       socket,
       station_id,
       current_conditions
     )}
  end

  defp update_station_current_conditions(socket, station_id, current_conditions)
       when is_map_key(socket.assigns.stations, station_id) do
    assign(socket, :stations, Map.put(socket.assigns.stations, station_id, current_conditions))
  end

  defp update_station_current_conditions(socket, _, _), do: socket

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="flex-grow text-center font-bold text-2xl mb-4">
        Phoenix LiveView Weather
      </div>
      <.live_component
        module={WeatherWeb.WeatherStationSummaryLiveComponent}
        id="live_list" stations={@stations} timezone={@timezone}
        uri={@uri}/>
      <.footer />
    </div>
    """
  end

  def footer(assigns) do
    ~H"""
    <div class="flex-grow text-center text-sm italic">
      Weather data from Open Weather Map:
      <a href='https://openweathermap.org'
        class="hover:text-blue-500">https://openweathermap.org</a>
    <br>
      Find the sourcecode for this at
      <a href="https://github.com/ehogberg/ex-weather"
        class="hover:text-blue-500">https://github.com/ehogberg/ex-weather</a>
    </div>
    """
  end

  # Local helpers below...

  defp parse_stations(stations_param) when stations_param == "", do: []
  defp parse_stations(stations_param), do: String.split(stations_param, "|")

  defp assign_default_stations(socket, stations) when length(stations) == 0,
    do: assign_default_stations(socket, ["Chicago", "London", "Prague"])

  defp assign_default_stations(socket, default_stations) do

      stations =
        if connected?(socket) do
          Enum.reduce(default_stations, %{}, fn station_id, acc ->
            Map.put(acc, station_id, initialize_new_station(station_id))
          end)
        else
          %{}
        end

      assign(socket, :stations, stations)
  end

  defp initialize_new_station(station_id) do
    WeatherInfoServiceSupervisor.start_child(station_id)
    current_conditions = WeatherInfoService.station_current_conditions(station_id)
    WeatherServiceMonitor.add_station_monitor(station_id,self())
    Phoenix.PubSub.subscribe(Weather.PubSub, "station:#{station_id}")
    current_conditions
  end

  defp assign_new_station(socket, new_station) when new_station == "", do: socket

  defp assign_new_station(socket, new_station)
       when is_map_key(socket.assigns.stations, new_station),
       do: socket

  defp assign_new_station(socket, new_station) do
    assign(
      socket,
      :stations,
      Map.put(socket.assigns.stations, new_station, initialize_new_station(new_station))
    )
  end

  defp clear_station(socket, station_id) do
    if length(Map.keys(socket.assigns.stations)) < 2 do
      socket
    else
      Phoenix.PubSub.unsubscribe(Weather.PubSub, "station:#{station_id}")
      WeatherServiceMonitor.remove_station_monitor(station_id, self())
      assign(socket, :stations, Map.delete(socket.assigns.stations, station_id))
    end
  end
end
