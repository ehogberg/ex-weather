defmodule Weather.WeatherInfoService do
  use GenServer

  alias Weather.WeatherStationInfo
  alias Phoenix.PubSub

  require Logger

  @check_interval 1000 * 60 * 10   # ten minutes

  ## Public API

  def start_link(station_id) do
    GenServer.start_link(__MODULE__, [station_id], name: via_tuple(station_id))
  end

  def service_state(station_id) do
    GenServer.call(
      via_tuple(station_id),
      :service_state
    )
  end

  def station_current_conditions(station_id) do
    GenServer.call(
      via_tuple(station_id),
      :current_conditions
    )
  end

  defp via_tuple(name) do
    normalized_name = name
    |> String.downcase()
    |> String.replace(~r"[[:blank]]", "")

    {:via, Registry, {Weather.WeatherServicesRegistry, normalized_name}}
  end

  ## Behaviour implementation
  @impl true
  def init([station_id]) do
    {:ok, %{station_id: station_id, history: []}, {:continue, :initial_station_load}}
  end

  @impl true
  def handle_continue(:initial_station_load, state) do
    Process.send_after(self(), :update_weather_info, @check_interval)
    {:noreply, load_station_and_update_state(state)}
  end

  @impl true
  def handle_call(:service_state, _, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:current_conditions, _, state) do
    {:reply, get_in(state, [:history, Access.at(0)]), state}
  end

  @impl true
  def handle_info(:update_weather_info, state) do
    Process.send_after(self(), :update_weather_info, @check_interval)
    {:noreply, load_station_and_update_state(state)}
  end

  defp load_station_and_update_state(%{station_id: station_id} = state) do
    current_info = WeatherStationInfo.get_weather_station_info(station_id)

    PubSub.broadcast(
      Weather.PubSub,
      "station:#{station_id}",
      {:station_info_updated, station_id, current_info}
    )

    update_in(state, [:history], &[current_info | Enum.take(&1, 99)])
  end
end
