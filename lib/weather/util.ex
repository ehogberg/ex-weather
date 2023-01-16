defmodule Weather.Util do
  @moduledoc """
  Various useful helper functions.
  """

  def normalize_weather_info_service_name(name) do
      name
      |> String.downcase()
      |> String.replace(~r"[[:blank]]", "")
  end

  def via_tuple(name) do
    {:via, Horde.Registry, {Weather.WeatherServicesRegistry, name}}
  end

  def tuple_to_string(tuple) when is_tuple(tuple) do
    tuple |> Tuple.to_list() |> Enum.join(", ")
  end

  def ref_to_string(ref) when is_reference(ref) do
    ref |> :erlang.ref_to_list() |> List.to_string()
  end

  def normalize_string(str), do: str |> to_string() |> String.trim()

  def friendly_timestamp(ts), do: Calendar.strftime(ts, "%x %X")

  def friendly_time(ts), do: Calendar.strftime(ts, "%I:%M %p")

  def to_localtime(ts, local_tz, valid_timezone? \\ true) do
    utc_datetime = DateTime.from_naive!(ts, "Etc/UTC")

    if valid_timezone? do
      {:ok, local_datetime} = DateTime.shift_zone(utc_datetime, local_tz)
      local_datetime
    else
      utc_datetime
    end
  end
end
