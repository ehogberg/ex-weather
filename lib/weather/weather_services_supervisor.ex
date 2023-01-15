defmodule Weather.WeatherServicesSupervisor do
  @moduledoc """
  Supervisor organizing the various processes used to run weather station
  information services.
  """

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {Horde.Registry, keys: :unique, name: Weather.WeatherServicesRegistry, members: :auto},
      Weather.WeatherServiceMonitor,
      Weather.WeatherInfoServiceSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
