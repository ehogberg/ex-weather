defmodule WeatherWeb.WeatherStationSummaryLiveComponent do
  use WeatherWeb, :live_component

  @impl true
  def update(%{stations: stations} = assigns, socket) do
    {:ok,
    socket
    |> assign(:stations, stations)
    |> assign(:class, Map.get(assigns,:class,""))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class}>
      <%= for station <- @stations do %>
        <div class="w-1/2 p-2 mb-1px mr-1px border border-slate-400">
          <div class="flex flex-row">
            <div class="w-full">
              <.live_component module={WeatherWeb.WeatherStationLiveComponent}
                id={station} station={station} />
            </div>

            <%= link to: "#", "phx-click": "clear_station",
              class: "dismissal",
              "phx-value-station-id": station do %>
              <i class="text-red-700 fas fa-window-close"></i>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
