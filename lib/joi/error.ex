defmodule Joi.Error do
  @doc """
  The struct of error

  Examples:
    iex> %Joi.Error{
       type: "integer.min"
       path: [:field],
       message: "field must be greater than or equal to 3}",
       context: %{key: :field, value: nil},
    }}
  """
  defstruct [:type, :message, path: [], context: %{}]

  alias __MODULE__

  def new(type, options) do
    path = options[:path]
    message = Module.safe_concat(Joi.Type, base_type(type)) |> apply(:message, [type, options])
    special_properties = options |> Keyword.drop([:path, :value]) |> Enum.into(%{})

    context = %{key: options[:path] |> List.last, value: options[:value]} |> Map.merge(special_properties)

    {:error, %Error{type: type, message: message, path: path, context: context}}
  end

  defp base_type(code) do
    # "integer.min" -> "Integer"
    code |> String.split(".") |> hd |> Macro.camelize()
  end
end
