defmodule WeatherWeb.WeatherStationSummaryLiveComponent do
  use WeatherWeb, :live_component

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.weather_station_input phx-submit="add_station"
        phx-target={@myself}
        form_id="add_station_form" />

      <.live_component
        module={WeatherWeb.WeatherStationGridLiveComponent}
        id="summary" stations={@stations} />

      <div class="flex-grow text-center mb-4">
        <.list_permalink stations={Map.keys(@stations)} uri={@uri}
          class="hover:text-blue-500">Permalink</.list_permalink>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add_station", %{"station" => %{"station_id" => station_id}}, socket) do
    Logger.debug("Adding station: #{station_id}")
    send(self(), {:add_station, station_id})
    {:noreply, socket}
  end

  def list_permalink(assigns) do
    attrs = assigns_to_attributes(assigns, [:uri, :stations])

    ~H"""
    <a href={"#{@uri}?stations=#{Enum.join(@stations,"|")}"} {attrs}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def weather_station_input(assigns) do
    attrs = assigns_to_attributes(assigns, [:form_id])

    ~H"""
    <div class="flex flex-row mb-4">
      <span class="w-3/12">Enter a station to add:</span>
      <span class="w-9/12">
        <form id={@form_id} {attrs}>
          <%= text_input :station, :station_id, value: "",
            class: "rounded w-full placeholder:italic placeholder:text-slate-400",
            placeholder: "Examples: \"New York\", \"Paris, FR\"" %>
        </form>
      </span>
      <span class="ml-3">
        <button class="border" type="submit" form={@form_id}>
          <i class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded far fa-solid fa-plus-large"></i>
        </button>
      </span>
    </div>
    """
  end
end
