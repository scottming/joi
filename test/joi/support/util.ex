defmodule Joi.Support.Util do
  defdelegate all_types, to: Joi.Util

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

