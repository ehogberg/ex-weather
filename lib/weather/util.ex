defmodule Weather.Util do
  def via_tuple(name) do
    normalized_name = name
    |> String.downcase()
    |> String.replace(~r"[[:blank]]", "")

    {:via, Registry, {Weather.WeatherServicesRegistry, normalized_name}}
  end

  def tuple_to_string(tuple) when is_tuple(tuple) do
    tuple |> Tuple.to_list() |> Enum.join(", ")
  end

  def ref_to_string(ref) when is_reference(ref) do
    ref |> :erlang.ref_to_list() |> List.to_string()
  end
end
