defmodule Joi.Util do
  defdelegate error(type, opts), to: Joi.Error, as: :new

  @doc """
  Returns all types that Joi supported
  """
  def all_types() do
    with {:ok, list} <- :application.get_key(:joi, :modules) do
      list
      |> Enum.filter(fn x ->
        module_list = x |> Module.split()

        # TODO: delete map when implemented
        Enum.slice(module_list, 0..1) == ~w|Joi Type| && module_list not in [~w|Joi Type|, ~w|Joi Util|]
        # && module_list != ~w|Joi Type Map|
      end)
      |> Enum.map(&(&1 |> Module.split() |> List.last() |> String.downcase() |> String.to_atom()))
    end
  end

  @doc """
  Return the real path of error

  Examples:
    iex> path("2", parent_path: [1])
    [1, "2"]
    iex> path("2", [])
    ["2"]
  """
  def path(field, %{parent_path: parent_path}) do
    parent_path ++ [field]
  end

  def path(field, _) do
    [field]
  end

  def is_schema(schema) when is_map(schema) do
    values = Enum.map(schema, fn {_k, v} -> v end)
    all_values_are_list?(values) && all_types_are_validated?(values) && all_tail_options_are_keyword?(values)
  end

  def is_schema(_schema) do
    false
  end

  defp all_values_are_list?(values), do: Enum.all?(values, &is_list/1)

  defp all_types_are_validated?(values), do: Enum.all?(values, &(hd(&1) in all_types()))

  defp all_tail_options_are_keyword?(values) do
    validations = Enum.map(values, fn [_h | t] -> t end)
    Enum.all?(validations, &Keyword.keyword?/1)
  end

  def string_to_float(str) do
    case Float.parse(str) do
      {num, _} -> num
      _ -> nil
    end
  end

  def len(value) when is_binary(value) do
    String.length(value)
  end

  def len(value) do
    length(value)
  end
end

