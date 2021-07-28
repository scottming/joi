defmodule Joi.Util do
  defdelegate error(type, opts), to: Joi.Error, as: :new

  @doc ~S"""
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

  @doc ~S"""
  Returns a list of types that support the input validator

  Examples:

      iex> types_of(:min_length)
      [:string, atom, :list]
  """
  def types_by(validator) do
    all_types()
    |> Enum.map(fn x ->
      module = Module.safe_concat(Joi.Type, Atom.to_string(x) |> Macro.camelize())
      args = ["#{x}.#{validator}", [path: [:fake_path]]]
      message = apply(module, :message, args)
      {x, message}
    end)
    |> Enum.reject(fn {_x, message} -> is_nil(message) end)
    |> Enum.map(&elem(&1, 0))
  end

  @doc ~S"""
  Return a module name when input a atom

  Examples:

      iex> atom_type_to_mod(:atom)
      Joi.Type.Atom
  """
  def atom_type_to_mod(t) when is_atom(t) do
    Module.safe_concat(Joi.Type, t |> Atom.to_string() |> Macro.camelize())
  end

  @doc ~S"""
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

  @doc """
  Append a parent_path to the options of schema's field
  """
  def append_parent_path_to(schema, parent_path) do
    for {k, opts} <- schema do
      {k, opts ++ [parent_path: parent_path]}
    end
    |> Enum.into(%{})
  end

  @doc """
  Return a new parent path.

  The parent path default is nil, the return a [parent_index] list by input field.
  """
  def parent_path(appended_path, options) when is_list(appended_path) do
    if options[:parent_path] do
      options[:parent_path] ++ appended_path
    else
      appended_path
    end
  end

  def parent_path(appended_path, options) do
    if options[:parent_path] do
      options[:parent_path] ++ [appended_path]
    else
      [appended_path]
    end
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
