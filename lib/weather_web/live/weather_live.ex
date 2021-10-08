defmodule WeatherWeb.WeatherLive do
  use WeatherWeb, :live_view

  @impl true
  def mount(_params, _sess, socket) do
    {:ok,
     socket
     |> assign_default_stations()}
  end

  @impl true
  def handle_event("add_station", %{"station" => %{"station_id" => station_id}} , socket) do
    {:noreply,assign_new_station(socket, station_id)}
  end

  @impl true
  def handle_event("clear_station", %{"station-id" => station_id} = params, socket) do
    {:noreply, clear_station(socket, station_id)}
  end
  
  def assign_default_stations(socket) do
    socket
    |> assign(:stations, MapSet.new(["Chicago","Boston"]))
  end

  def assign_new_station(socket,new_station) do
    socket
    |> assign(:stations, MapSet.put(socket.assigns.stations,new_station))
  end

  def clear_station(socket,station_id) do
    socket
    |> assign(:stations, MapSet.delete(socket.assigns.stations, station_id))
  end
  
end
