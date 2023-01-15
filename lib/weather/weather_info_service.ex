defmodule Weather.WeatherInfoService do
  @moduledoc """
  GenServer-based implementation of a weather station query service.
  Uses Phoenix.PubSub as a communication mechanism; processes interested in
  updates to a particular weather station's current conditions can subscribe
  to a topic of update events specific to that station

  In addition, current conditions can be obtained in-band via the
  station_current_conditions function.
  """
  use GenServer

  alias Weather.WeatherStationInfo
  alias Phoenix.PubSub
  import Weather.Util
  require Logger

  ## Public API

  def start_link(station_id) do
    case GenServer.start_link(
      __MODULE__,
      [station_id],
      name: via_weather_info_service_tuple(station_id)) do
        {:ok, pid} ->
          Logger.debug("Weather info service instance #{station_id} successfully started.")
          {:ok, pid}

        {:error, {:already_started, pid}} ->
          Logger.warn("Weather info service instance #{station_id} already started at pid #{inspect(pid)}.")
          :ignore
    end
  end

  def service_state(station_id) do
    GenServer.call(
      via_weather_info_service_tuple(station_id),
      :service_state
    )
  end

  def station_current_conditions(station_id) do
    GenServer.call(
      via_weather_info_service_tuple(station_id),
      :current_conditions
    )
  end

  def stop(station_id) do
    GenServer.stop(
      via_weather_info_service_tuple(station_id),
      {:shutdown, :unused}
    )
  end

  defp via_weather_info_service_tuple(name) do
    name
    |> normalize_weather_info_service_name()
    |> via_tuple()
  end

  def child_spec(station_id) do
    %{
      id: "#{__MODULE__}_#{station_id}",
      start: {Weather.WeatherInfoService, :start_link, [station_id]},
      restart: :transient,
      timeout: 10_000
    }
  end

  ## Behaviour implementation
  @impl true
  def init([station_id]) do
    {:ok, %{station_id: station_id, history: []}, {:continue, :initial_station_load}}
  end

  @impl true
  def handle_continue(:initial_station_load, state) do
    Process.send_after(self(), :update_weather_info, check_interval())
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
    Process.send_after(self(), :update_weather_info, check_interval())
    {:noreply, load_station_and_update_state(state)}
  end

  @impl true
  def terminate(reason, state) do
    Logger.debug(
      "Weather station info service #{state.station_id} shutting down. (#{tuple_to_string(reason)})"
    )
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

  defp check_interval, do: Application.get_env(:weather, :station_refresh_interval)
end
