defmodule Joi.Type.Map do
  import Joi.Validator.Skipping
  import Joi.Util

  @t :map
  @default_options required: true, schema: nil

  def message_map(options) do
    field = options[:path] |> List.last()

    %{
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.required" => "#{field} is required"
    }
  end

  def message(code, options) do
    message_map(options) |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:map, field, params, options) do
      with {:ok, value} <- validate_by_field_schema(field, params, options) do
        {:ok, %{params | field => value}}
      end
    end
  end

  def validate_by_field_schema(field, params, %{schema: nil} = options) do
    case is_map(params[field]) do
      true -> {:ok, params[field]}
      false -> error("#{@t}.base", path: path(field, options), value: params[field])
    end
  end

  def validate_by_field_schema(field, params, %{schema: schema} = options) do
    parent_path = parent_path(field, options)
    field_schema = append_parent_path_to(schema, parent_path)

    case Joi.validate(params[field], field_schema) do
      {:ok, value} -> {:ok, value}
      other -> other
    end
  end
end
