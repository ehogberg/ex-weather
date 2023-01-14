defmodule Weather.WeatherInfoServiceSupervisor do
  @moduledoc """
  DynamicSupervisor used to manage WeatherInfoService instances.  Exposes
  a start_child helper useful for adding a new station service.
  """
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
      %{
        id: Weather.WeatherInfoService,
        start: {Weather.WeatherInfoService, :start_link, [station_id]},
        restart: :transient
      }
    )
  end
end
