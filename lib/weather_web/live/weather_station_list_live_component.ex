defmodule WeatherWeb.WeatherStationListLiveComponent do
  use WeatherWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.weather_station_input />

      <.live_component
        module={WeatherWeb.WeatherStationSummaryLiveComponent}
        id="summary" stations={@stations}
        class="flex flex-row flex-wrap mb-4" />

      <div class="flex-grow text-center mb-4">
        <.list_permalink stations={@stations}>Permalink</.list_permalink>
      </div>

      <div class="flex-grow text-center text-sm italic">
        Last updated at <%= friendly_timestamp(@last_updated_at) %> UTC.
        Next update in <%= countdown_string(@countdown_timer)%>
      </div>
    </div>
    """
  end

  def list_permalink(assigns) do
    ~H"""
    <a href={"#{WeatherWeb.Endpoint.static_url()}/?stations=#{Enum.join(@stations,"|")}"}
        class="hover:text-blue-500">
      <%= render_slot(@inner_block) %>
    </a>
    """
  end
  
  def weather_station_input(assigns) do
    ~H"""
    <div class="flex flex-row mb-4">
      <span class="w-3/12">Enter a station to add:</span>
      <span class="w-9/12">
        <form id="add_station_frm" phx-submit="add_station">
          <%= text_input :station, :station_id, value: "",
            class: "rounded w-full placeholder-grey-500",
            placeholder: "enter a weather station specifier string" %>
        </form>
      </span>
      <span class="ml-3">
        <button class="border" type="submit" form="add_station_frm">
          <i class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded far fa-plus fa-lg"></i>
        </button>
      </span>
    </div>
    """
  end
end
