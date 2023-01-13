defmodule WeatherWeb.WeatherStationGridLiveComponent do
  @moduledoc """
  Container live component displaying a set of WeatherStationLive components in a
  flowing grid.   Each weather station component is decorated with a dismissal icon;
  when clicked a "clear-station" instruction is sent to the parent LiveView to remove
  the station from the working list of stations.
  """
  use WeatherWeb, :live_component
  import Weather.Util

  @impl true
  def handle_event("clear_station", %{"station-id" => station_id}, socket) do
    send(self(), {:clear_station, station_id})
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.station_entries id='station_entry_grid'
        stations={@stations} myself={@myself} timezone={@timezone}/>
    </div>
    """
  end

  def station_entries(assigns) when map_size(assigns.stations) > 0 do
    ~H"""
    <div class="flex flex-row flex-wrap mb-4">
      <%= for {station, station_data} <- @stations do %>
          <div class="w-1/2 p-2 mb-1px mr-1px border border-slate-400">
            <div class="flex flex-row">
              <div class="w-full">
                <.live_component module={WeatherWeb.WeatherStationLiveComponent}
                  id={station} station_data={station_data} />
              </div>

              <i phx-click="clear_station" phx-target={@myself}
                phx-value-station-id={station}
                class="cursor-pointer fas fa-duotone fa-xmark"></i>
            </div>
            <div>
              <div class="italic text-sm text-center">
                Last checked at:
                <%= station_data.weather_checked_at
                |> to_localtime(@timezone)
                |> friendly_time()
                %>
              </div>
            </div>
          </div>
        <% end %>
    </div>
    """
  end

  def station_entries(assigns) do
    ~H"""
      <div class="flex justify-center items-center">
        <div class="fa-6x">
          <i class="fa-duotone fa-circle-notch fa-spin" />
        </div>
      </div>
    """
  end
end
