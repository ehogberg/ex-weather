defmodule WeatherWeb.WeatherLiveComponents do
  use Phoenix.Component
  import Weather.Util



  def time_display_info(assigns) when assigns.valid_timezone? == false do
    ~H"""
    <div>
    <p class="mb-2">You specified timezone <strong><%= @timezone %></strong>
    but IANA doesn't know that one.</p>
    <p>
    Displaying times as UTC.
    </p>
    </div>
    """
  end

  def time_display_info(assigns) when assigns.timezone == "Etc/UTC" do
    ~H"""
    <div>
    <p class="mb-2">Times displayed as UTC</p>
    <p>
    Setting the <code>tz</code> query string parameter to an
    <br>
    <a class="hover:text-blue-500" href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones">
    [IANA timezone specifier]
    </a>
    will display time
    <br>
    as relative to the specified timezone.
    </p>
    </div>
    """
  end

  def time_display_info(assigns) do
    ~H"""
    <div>
    <p>Times displayed relative to timezone <strong><%= @timezone %></strong></p>
    </div>
    """
  end


  attr :station_data, Weather.WeatherStationInfo, required: true
  attr :tz, :any, required: true
  attr :valid_tz?, :boolean, required: true
  def station_info(assigns) do
    ~H"""
      <div class="summary w-2/5">
        <div class="text-lg font-bold"><%= @station_data.name %></div>
        <div class="mr-2">
          <img src={"https://openweathermap.org/img/wn/#{@station_data.icon}.png"}/>
          <span class="italic text-sm"><%= @station_data.conditions %></span>
        </div>
      </div>

      <div class="w-3/5 text-sm">
        Curr. temp.: <%= @station_data.curr_temp %>&deg; F<br>
        Feels like: <%= @station_data.feels_like %>&deg; F<br>
        Today's high: <%= @station_data.temp_max %>&deg; F<br>
        Today's low: <%= @station_data.temp_min %>&deg; F<br>
        Rel. humidity: <%= @station_data.humidity %>%<br>

          <div class="italic text-sm">
              Last updated at:
              <%=
                @station_data.weather_updated_at
                |> to_localtime(@tz, @valid_tz?)
                |> friendly_time()
              %>
          </div>
      </div>
    """
  end

  attr :error_msg, :string, required: true
  def station_info_error(assigns) do
    ~H"""
    <div class="w-full">
      <%= @error_msg %>
    </div>
    """
  end
end
