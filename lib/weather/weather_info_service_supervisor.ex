defmodule Weather.WeatherInfoServiceSupervisor do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(station_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Weather.WeatherInfoService, station_id}
    )
  end
end
