defmodule Joi.Support.Util do
  @doc """
  Returns all types that Joi supported
  """
  def all_types() do
    with {:ok, list} <- :application.get_key(:joi, :modules) do
      list
      |> Enum.filter(fn x ->
        module_list = x |> Module.split()

        # TODO: delete map when implemented
        Enum.slice(module_list, 0..1) == ~w|Joi Type| &&
          module_list not in [~w|Joi Type|, ~w|Joi Util|] &&
          module_list != ~w|Joi Type Map|
      end)
      |> Enum.map(&(&1 |> Module.split() |> List.last() |> String.downcase() |> String.to_atom()))
    end
  end

  @doc """
  Returns a list of types that support the input validator

  Examples: 
    iex> types(validator)
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

  @doc """
  Return a module name when input a atom

  Examples:
    iex> atom_type_to_mod(:atom)
    Joi.Type.Atom
  """
  def atom_type_to_mod(t) when is_atom(t) do
    Module.safe_concat(Joi.Type, t |> Atom.to_string() |> Macro.camelize())
  end
end
