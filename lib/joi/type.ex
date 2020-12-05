defmodule Joi.Type do
  @moduledoc false

  alias __MODULE__
  alias Joi.Validator.Custom

  def validate(type, field, data, options) do
    custom_function_list = options |> Keyword.take([:f])
    options = options |> Keyword.drop([:f])

    cond do
      type == :number -> Type.Number.validate_field(field, data, options)
      type == :string -> Type.String.validate_field(field, data, options)
      type == :list -> Type.List.validate_field(field, data, options)
      type == :boolean -> Type.Boolean.validate_field(field, data, options)
      type == :datetime -> Type.DateTime.validate_field(field, data, options)
      type == :date -> Type.Date.validate_field(field, data, options)
      type -> {:error, "unknown type: #{type}"}
    end
    |> custom_validate(field, custom_function_list, options)
  end

  defp custom_validate({:ok, data}, field, fs, options) do
    custom_functions = Keyword.values(fs) |> Enum.filter(&is_function/1)

    if Keyword.get(options, :required) == false and is_nil(data[field]) do
      {:ok, data}
    else
      Custom.validate_field(field, data, custom_functions)
    end
  end

  defp custom_validate(other, _, _, _options) do
    other
  end
end
