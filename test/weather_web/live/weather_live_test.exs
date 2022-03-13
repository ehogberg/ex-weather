defmodule WeatherWeb.WeatherLiveTests do
  use ExUnit.Case
  alias WeatherWeb.WeatherLive

  defp create_empty_socket() do
    [socket: %Phoenix.LiveView.Socket{}]
  end

  defp create_mounted_socket() do
    {:ok, mounted_socket} = WeatherLive.mount(%{}, nil, %Phoenix.LiveView.Socket{})
    [mounted_socket: mounted_socket]
  end

  defp clear_multiple_stations(socket, station_list) do
    Enum.reduce(station_list, socket, fn el, socket ->
      elem(
        WeatherLive.handle_info(
          {:clear_station,el},socket),
        1
      )
    end)
  end

  describe "Initial socket state" do
    setup do
      create_empty_socket()
    end

    test "when no weather stations are provided", %{socket: socket} do
      {:ok, socket} = WeatherLive.mount(%{}, nil, socket)
      assert socket.assigns.stations == ["Chicago", "London", "Prague"]
    end

    test "when stations are provided", %{socket: socket} do
      params = %{"stations" => "Peoria|Louisville"}
      {:ok, socket} = WeatherLive.mount(params, nil, socket)
      assert socket.assigns.stations == ["Peoria", "Louisville"]
    end

    test "callback time set appropriately in the future", %{socket: socket} do
      ten_minutes_hence = DateTime.utc_now() |> DateTime.add(600)
      {:ok, socket} = WeatherLive.mount(%{}, nil, socket)
      assert DateTime.diff(socket.assigns.next_update, ten_minutes_hence) < 1
    end
  end

  describe "Add and clear weather stations" do
    setup do
      create_mounted_socket()
    end

    test "adding an additional station", %{mounted_socket: mounted_socket} do
      {:noreply, socket} =
        WeatherLive.handle_info( {:add_station, "Springfield"}, mounted_socket)

      assert socket.assigns.stations == ["Chicago", "London", "Prague", "Springfield"]
    end

    test "duplicate station addition requests are ignored", %{mounted_socket: mounted_socket} do
      {:noreply, socket} =
        WeatherLive.handle_info({:add_station, "Prague"}, mounted_socket)
      assert socket.assigns.stations == ["Chicago", "London", "Prague"]
    end

    test "adding an empty (nil or blank) station specifier is ignored",
      %{mounted_socket: mounted_socket} do
      {:noreply, socket} =
        WeatherLive.handle_info({:add_station, ""}, mounted_socket)
      assert length(socket.assigns.stations) == 3

      {:noreply, socket} =
        WeatherLive.handle_info({:add_station, ""}, mounted_socket)
      assert length(socket.assigns.stations) == 3

      {:noreply, socket} =
        WeatherLive.handle_info({:add_station, nil}, mounted_socket)
      assert length(socket.assigns.stations) == 3
    end

    test "clearing a station", %{mounted_socket: mounted_socket} do
      {:noreply, socket} =
        WeatherLive.handle_info({:clear_station, "London"}, mounted_socket)
      assert socket.assigns.stations == ["Chicago", "Prague"]
    end

    test "can't clear the last station in the set", %{mounted_socket: mounted_socket} do
      socket = clear_multiple_stations(mounted_socket, ["Chicago", "London", "Prague"])
      assert socket.assigns.stations == ["Prague"]
    end
  end
end
