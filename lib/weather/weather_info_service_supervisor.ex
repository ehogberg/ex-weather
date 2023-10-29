defmodule Weather.WeatherInfoServiceSupervisor do
  @moduledoc """
  DynamicSupervisor used to manage WeatherInfoService instances.  Exposes
  a start_child helper useful for adding a new station service.
  """
  use Horde.DynamicSupervisor
  require Logger

  def start_link(args) do
    Logger.debug("Starting weather info services supervisor.")
    Horde.DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Horde.DynamicSupervisor.init(strategy: :one_for_one, member: :auto)
  end

  def start_child(station_id) do
    Horde.DynamicSupervisor.start_child(
      __MODULE__,
      {Weather.WeatherInfoService,station_id}
    )
  end
end
