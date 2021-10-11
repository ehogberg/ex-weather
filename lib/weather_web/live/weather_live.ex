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
    |> assign(:stations, ["Chicago","Boston"])
  end
  
  def assign_new_station(socket,new_station) do
    if new_station in socket.assigns.stations do
      socket
    else
      assign(socket, :stations, socket.assigns.stations ++ [new_station])
    end
  end

  def clear_station(socket,station_id) do
    socket
    |> assign(:stations, List.delete(socket.assigns.stations, station_id))
  end
end
