defmodule WeatherWeb.WeatherLive do

  @refresh_interval 600 # in seconds

  @moduledoc """
  A LiveView stateful component, providing a container of WeatherWeb.WeatherStationLiveComponent's,
  and exposes functionality which can be used to add and remove new weather station components from
  the container.
  """
  use WeatherWeb, :live_view
  require Logger

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
    schedule_next_countdown_timer_check(socket)

    stations =
      params
      |> Map.get("stations", "")
      |> parse_stations()

    {:ok,
     socket
     |> assign_default_stations(stations)
     |> assign_next_update()}
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
  def handle_info(:check_update, socket) do
    schedule_next_countdown_timer_check(socket)

    if DateTime.diff(socket.assigns.next_update, DateTime.utc_now()) <= 0 do
      Logger.debug("Refreshing weather info for #{inspect(socket.assigns.stations)}")

      for station <- socket.assigns.stations do
        send_update(WeatherWeb.WeatherStationLiveComponent, id: station, station: station)
      end

      {:noreply, assign_next_update(socket)}
    else
      {:noreply, assign_countdown_timer(socket, socket.assigns.next_update)}
    end
  end

  @impl true
  def handle_info({:add_station, station_id}, socket),
    do: {:noreply, assign_new_station(socket, normalize_string(station_id))}

  @impl true
  def handle_info({:clear_station, station_id}, socket),
   do: {:noreply, clear_station(socket, station_id)}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="flex-grow text-center font-bold text-2xl mb-4">
        Phoenix LiveView Weather
      </div>
      <.live_component
        module={WeatherWeb.WeatherStationSummaryLiveComponent}
        id="live_list" stations={@stations}
        uri={@uri}
        last_updated_at={@last_updated_at}
        countdown_timer={@countdown_timer} />
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
  defp assign_default_stations(socket, stations), do: assign(socket, :stations, stations)

  defp assign_new_station(socket,new_station) when new_station == "", do: socket
  defp assign_new_station(socket, new_station) do
    if new_station in socket.assigns.stations do
      socket
    else
      assign(socket, :stations, socket.assigns.stations ++ [new_station])
    end
  end

  defp schedule_next_countdown_timer_check(socket),
    do: if(connected?(socket), do: Process.send_after(self(), :check_update, 1000))

  defp assign_countdown_timer(socket, next_update),
    do: assign(socket, :countdown_timer, calc_countdown_timer(next_update))

  defp assign_next_update(socket) do
    next_update = DateTime.utc_now() |> DateTime.add(@refresh_interval)

    socket
    |> assign(:last_updated_at, DateTime.utc_now())
    |> assign(:next_update, next_update)
    |> assign_countdown_timer(next_update)
  end

  defp clear_station(socket, _) when length(socket.assigns.stations) < 2, do: socket

  defp clear_station(socket, station_id),
    do: assign(socket, :stations, List.delete(socket.assigns.stations, station_id))
end
