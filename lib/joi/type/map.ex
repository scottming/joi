defmodule Joi.Type.Map do
  import Joi.Validator.Skipping
  import Joi.Util

  @t :map
  @default_options required: true, schema: nil

  def message(code, options) do
    field = options[:path] |> List.last()

    %{
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.required" => "#{field} is required",
    }
    |> Map.get(code)
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

  defp append_parent_path_to_fields(schema, parent_path) do
    for {k, opts} <- schema do
      {k, opts ++ [parent_path: parent_path]}
    end
    |> Enum.into(%{})
  end

  defp parent_path(field, options) do
    if Map.get(options, :parent_path) do
      options.parent_path ++ [field]
    else
      [field]
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
    field_schema = append_parent_path_to_fields(schema, parent_path)

    case Joi.validate(params[field], field_schema) do
      {:ok, value} -> {:ok, value}
      other -> other
    end
  end
end

