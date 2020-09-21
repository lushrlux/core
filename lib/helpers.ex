defmodule LushrLux.Core.Helpers do
  @moduledoc """
  Helpers is for functions that are going to transform data structurs
  that are needed in ordered to make life of the dev life easier.
  """
  @doc """
  Atom map turns a string map into an atom map. This is used when some JSON comes into
  an endpoint and then it's converted as it's just that little bit easier to work with atom maps.

  ## Example
      iex> LushrLux.Core.Helpers.atom_map(%{"Elixir" => "Is cool"})
      %{Elixir: "Is cool"}
  """
  def atom_map(string_map) when is_map(string_map) do
    for {k, v} <- string_map, into: %{}, do: {String.to_atom(k), v}
  end

  def atom_map(value), do: value

  @doc """
  String map does the opposit of `atom_map/1`. It takes an atom map and converts it to a string map.
  This is useful when it comes to testing a POST endpoint.
  It's easier to read and write an atom map and then just convert it here to mock the JSON that the endpoint
  would see.

  ## Example
      iex> LushrLux.Core.Helpers.string_map(%{Elixir: "Is cool"})
      %{"Elixir" => "Is cool"}
  """
  def string_map(atom_map) when is_map(atom_map) do
    for {k, v} <- atom_map, into: %{}, do: {Atom.to_string(k), v}
  end

  def string_map(value), do: value

  @doc """
  When a query is passed to a GET endpoint that returns a collection of records such as `?location=Birmingham&asc=company_name`.
  The `conn.params` are sent here to be turned into a list of 2 lists. The first list being a list of fields and a value, in this case
  `location=Birmingham` and the second one being the sort by option where it detects the key of either `asc` or `desc` and the value, which
  would be a field that needs to be sorted by.

  This is all done so that the common method fir each table in the database referred to as `fetch/2`
  will be able to work and correctly orientate the inputs and interpolate them correctly for valid SQL code.

  ## Example
      iex> query = %{"asc" => "company_name", "location" => "Birmingham"}
      ...> LushrLux.Core.Helpers.parse_params(query)
      [[location: "Birmingham"], [asc: :company_name]]
  """
  def parse_params(%{} = params) do
    sort = parse_sort_params(params)

    params = Map.delete(params, "asc")
    params = Map.delete(params, "desc")

    search = for {key, val} <- params, into: [], do: {String.to_atom(key), val}

    [search, sort]
  end

  defp parse_sort_params(%{} = params, result \\ []) do
    case params do
      %{"asc" => val} ->
        parse_sort_params(Map.delete(params, "asc"), result ++ [{:asc, String.to_atom(val)}])

      %{"desc" => val} ->
        parse_sort_params(Map.delete(params, "desc"), result ++ [{:desc, String.to_atom(val)}])

      _ ->
        result
    end
  end

  @doc """
  Struct to json is as it sounds. It takes a struct, such as in servicer `%Servicer.User{first_name: "Jose", last_name: "Valim"}`.
  Then it uses `Map.from_struct/1` and would convert it to `%{first_name: "Jose", last_name: "Valim"}`. From there it's able to be
  encoded into a JSON version safe for returning.

  This function can take a single struct or a list of structs.
  """
  def struct_to_json(structs) when is_list(structs) do
    Enum.map(structs, &struct_to_map/1) |> Jason.encode!()
  end

  def struct_to_json(%{} = struct) do
    struct |> struct_to_map() |> Jason.encode!()
  end

  defp struct_to_map(%{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end
end
