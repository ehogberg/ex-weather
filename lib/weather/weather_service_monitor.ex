defmodule Weather.WeatherServiceMonitor do
  @moduledoc """
  GenServer-based monitoring for tracking usage of weather services and also
  implementing a periodic reaper function which stops services no longer being
  used.   Clients using a service should register their interest using
  add_station_monitor(pid) and, when no longer interested/terminating processing,
  use remove_station_monitor(pid) to remove themselves from the monitor.

  Registered clients will have a monitor created by the service which signals
  shutdowns/terminations and will appropriate reduce the reference counts of
  any services subscribed to by the terminating process.
  """
  alias Weather.WeatherInfoService
  use GenServer
  require Logger
  import Weather.Util

  def start_link(_args) do
    case GenServer.start_link(
      __MODULE__, [],
      name: via_tuple(__MODULE__)) do
        {:ok, pid} ->
          {:ok, pid}

        {:error, {:already_started, pid}} ->
            Logger.warn("Weather service monitor instance already started at pid #{inspect(pid)}.")
            :ignore
    end
  end

  @spec add_station_monitor(binary, pid) :: :ok
  def add_station_monitor(station_id, pid)
      when is_pid(pid) and is_binary(station_id) do
    GenServer.cast(via_tuple(__MODULE__), {:add_station_monitor, station_id, pid})
  end

  def remove_station_monitor(station_id, pid)
      when is_pid(pid) and is_binary(station_id) do
    GenServer.cast(via_tuple(__MODULE__), {:remove_station_monitor, station_id, pid})
  end

  def server_state() do
    GenServer.call(via_tuple(__MODULE__), :server_state)
  end

  @impl true
  def init(_args) do
    Logger.info("Starting station service monitor (autoreaper interval: #{reaper_interval()})")

    Process.send_after(
      self(),
      :reap_unused_services,
      reaper_interval()
    )

    {:ok, %{}}
  end

  defp reaper_interval(), do: Application.get_env(:weather, :reaper_interval)

  @impl true
  def handle_call(:server_state, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:add_station_monitor, station_id, pid}, state) do
    ref = Process.monitor(pid)

    Logger.debug(
      "Adding monitor #{ref_to_string(ref)} for weather station #{station_id} (pid #{:erlang.pid_to_list(pid)})"
    )

    {:noreply, append_station_monitor_pid(state, station_id, pid)}
  end

  @impl true
  def handle_cast({:remove_station_monitor, station_id, pid}, state) do
    Logger.debug("Removing monitor #{:erlang.pid_to_list(pid)} for weather station #{station_id}")
    {:noreply, remove_station_monitor_pid(state, station_id, pid)}
  end

  @impl true
  def handle_info({:DOWN, reference, :process, pid, reason}, state) do
    Logger.debug(
      "Process #{:erlang.pid_to_list(pid)} has terminated (reason: #{tuple_to_string(reason)}); clearing monitor #{ref_to_string(reference)}"
    )

    Process.demonitor(reference)
    {:noreply, remove_pid_from_all_monitors(state, pid)}
  end

  @impl true
  def handle_info(:reap_unused_services, state) do
    unused_services =
      state
      |> Map.filter(fn {_, v} -> MapSet.size(v) == 0 end)
      |> Map.keys()

    Logger.debug("Reaping unused services: #{Enum.join(unused_services, ",")}")

    for service <- unused_services,
        do: WeatherInfoService.stop(service)

    Process.send_after(
      self(),
      :reap_unused_services,
      reaper_interval()
    )

    {:noreply, Map.drop(state, unused_services)}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug("General message received: #{IO.inspect(msg)}")
    {:noreply, state}
  end

  defp append_station_monitor_pid(state, station_id, pid) do
    station_monitors = Map.get(state, station_id, MapSet.new())
    Map.put(state, station_id, MapSet.put(station_monitors, pid))
  end

  defp remove_station_monitor_pid(state, station_id, pid) do
    station_monitors = Map.get(state, station_id)
    Map.put(state, station_id, MapSet.delete(station_monitors, pid))
  end

  defp remove_pid_from_all_monitors(state, pid) do
    monitored_services_for_pid =
      state
      |> Map.filter(fn {_, v} -> MapSet.member?(v, pid) end)
      |> Map.keys()

    Enum.reduce(monitored_services_for_pid, state, fn service, s ->
      Map.update!(s, service, fn pids ->
        MapSet.delete(pids, pid)
      end)
    end)
  end
end
