defmodule WeatherWeb.WeatherLive do
  use WeatherWeb, :live_view

  @impl true
  def mount(params, sess, socket) do
    if connected?(socket), do: Process.send_after(self(),:check_update,1000)

    station_params = params
    |> Map.get("stations")
    |> parse_stations()
    
    {:ok,
     socket
     |> assign_default_stations(station_params)
     |> assign_next_update()}
  end

  def parse_stations(stations_param) when is_nil(stations_param), do: nil

  def parse_stations(stations_param), do: String.split(stations_param,"|")
  
  @impl true
  def handle_info(:check_update,socket) do
    Process.send_after(self(), :check_update, 1000)

    if (DateTime.diff(socket.assigns.next_update,DateTime.utc_now) <= 0) do
      for station <- socket.assigns.stations do
	send_update(WeatherWeb.WeatherStationLiveComponent, id: station, station: station)
      end
      
      {:noreply, socket |> assign_next_update()}
    else
	{:noreply,
	 socket
	 |> assign_countdown_timer(socket.assigns.next_update)}
    end
  end

  @impl true
  def handle_event("add_station", %{"station" => %{"station_id" => station_id}} , socket) do
    {:noreply,assign_new_station(socket, station_id)}
  end

  @impl true
  def handle_event("clear_station", %{"station-id" => station_id} = params, socket) do
    {:noreply, clear_station(socket, station_id)}
  end

  def assign_default_stations(socket, stations) when is_nil(stations) do
    assign_default_stations(socket, ["Chicago", "London", "Prague"])
  end
  
  def assign_default_stations(socket, stations) do
    socket
    |> assign(:stations, stations)
  end
  
  
  def assign_new_station(socket,new_station) do
    if new_station in socket.assigns.stations do
      socket
    else
      assign(socket, :stations, socket.assigns.stations ++ [new_station])
    end
  end

  def assign_countdown_timer(socket, next_update) do
    assign(socket, :countdown_timer, calc_countdown_timer(next_update))
  end
        
  def assign_next_update(socket) do
    next_update = DateTime.utc_now
    |> DateTime.add(600,:second)

    socket
    |> assign(:last_updated_at, DateTime.utc_now)
    |> assign(:next_update,next_update)
    |> assign_countdown_timer(next_update)
  end
  
  def clear_station(socket,station_id) do
    socket
    |> assign(:stations, List.delete(socket.assigns.stations, station_id))
  end

  def calc_countdown_timer(next_update_time) do
    seconds_diff = DateTime.diff(next_update_time, DateTime.utc_now)
    minutes_until = div(seconds_diff,60)
    seconds_until = Integer.mod(seconds_diff,60)
    {minutes_until, seconds_until}
  end

  def countdown_string({minutes_until,_}) when minutes_until > 0 do
    "approx. #{pluralize(minutes_until,'minute','minutes')}"
  end
  
  def countdown_string({_, seconds_until}) do
    pluralize(seconds_until,"second","seconds")
  end

  def friendly_timestamp(ts), do: Calendar.strftime(ts,"%x %X")
  
  def pluralize(amt, singular, _plural) when amt == 1, do: "#{amt} #{singular}"
  def pluralize(amt, _singular, plural), do: "#{amt} #{plural}"
    
end
