defmodule WeatherWeb.WeatherStationGridLiveComponent do
  @moduledoc """
  Container live component displaying a set of WeatherStationLive components in a
  flowing grid.   Each weather station component is decorated with a dismissal icon;
  when clicked a "clear-station" instruction is sent to the parent LiveView to remove
  the station from the working list of stations.
  """
  use WeatherWeb, :live_component

  @impl true
  def handle_event("clear_station", %{"station-id" => station_id}, socket) do
    send(self(),{:clear_station, station_id})
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do

    ~H"""
    <div class="flex flex-row flex-wrap mb-4">
      <%= for station <- @stations do %>
        <div class="w-1/2 p-2 mb-1px mr-1px border border-slate-400">
          <div class="flex flex-row">
            <div class="w-full">
              <.live_component module={WeatherWeb.WeatherStationLiveComponent}
                id={station} station={station} />
            </div>

            <i phx-click="clear_station" phx-target={@myself}
               phx-value-station-id={station}
               class="cursor-pointer text-red-700 fas fa-window-close"></i>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
