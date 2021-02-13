defmodule Joi.Type.Map do
  import Joi.Validator.Skipping
  import Joi.Util

  @default_options required: true

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:map, field, params, options) do
      with {:ok, params} <- validate_schema(field, params, options),
           {:ok, value} <- Joi.validate(params[field], options.schema) do
        {:ok, %{params | field => value}}
      end
    end
  end

  def validate_schema(field, params, options) do
    schema = Map.get(options, :schema) || raise "not found schema when validate #{field}"

    case is_schema(schema) do
      true -> {:ok, params}
      false -> {:error, "invalid schema when validate #{field}"}
    end
  end
end
