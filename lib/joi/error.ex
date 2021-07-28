defmodule Joi.Error do
  @doc """
  The struct of error
  """
  @type t :: %{
          type: String.t(),
          message: String.t(),
          path: list(),
          context: map()
        }
  defstruct [:type, :message, path: [], context: %{}]

  alias __MODULE__

  def new(type, options) do
    path = options[:path]

    message =
      if base_type(type) in Joi.Util.all_types() do
        module = type |> base_type() |> Joi.Util.atom_type_to_mod()
        apply(module, :message, [type, options])
      else
        options[:message]
      end

    special_properties = options |> Keyword.drop([:path, :value]) |> Enum.into(%{})

    context = %{key: List.last(path), value: options[:value]} |> Map.merge(special_properties)

    {:error, %Error{type: type, message: message, path: path, context: context}}
  end

  defp base_type(code) do
    # "integer.min" -> :integer
    code |> String.split(".") |> hd |> String.to_atom()
  end
end

