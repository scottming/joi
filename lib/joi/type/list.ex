defmodule Joi.Type.List do
  @moduledoc false
  import Joi.Validator.Skipping
  import Joi.Util

  import Joi.Validator.MaxLength, only: [max_length_validate: 4]
  import Joi.Validator.MinLength, only: [min_length_validate: 4]
  import Joi.Validator.Length, only: [length_validate: 4]

  @t :list
  @default_options [
    required: true,
    type: :any,
    min_length: nil,
    max_length: nil,
    length: nil
  ]

  def message(code, options) do
    field = options[:path] |> List.last()
    limit = options[:limit]
    custom_type = options[:type]
    schema = options[:schema]

    if sub_type(code) do
      "#{field} must be a list of #{sub_type(code)}"
    else
      %{
        "#{@t}.base" => "#{field} must be a #{@t}",
        "#{@t}.required" => "#{field} is required",
        "#{@t}.length" => "#{field} must contain #{limit} items",
        "#{@t}.max_length" => "#{field} must contain less than or equal to #{limit} items",
        "#{@t}.min_length" => "#{field} must contain at least #{limit} items",
        "#{@t}.type" => "#{custom_type} not supported",
        "#{@t}.schema" => "#{schema} is invalid"
      }
      |> Map.get(code)
    end
  end

  defp sub_type(code) do
    last = String.split(code, ",") |> List.last()

    if last in all_types() do
      last
    end
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(@t, field, params, options) do
      with {:ok, params} <- validate_list(field, params, options),
           {:ok, params} <- type_validate(field, params, options),
           {:ok, params} <- min_length_validate(@t, field, params, options),
           {:ok, params} <- max_length_validate(@t, field, params, options),
           {:ok, params} <- length_validate(@t, field, params, options) do
        {:ok, params}
      end
    end
  end

  def validate_list(field, params, options) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_list(params[field]) ->
        {:ok, params}

      true ->
        error("#{@t}.base", path: path(field, options), value: params[field])
    end
  end

  def type_validate(field, params, %{schema: schema} = options) do
    case is_schema(schema) do
      true ->
        results =
          for {value, index} <- Enum.with_index(params[field]) do
            field_schema = append_parent_path_to(schema, parent_path([field, index], options))
            Joi.validate(value, field_schema)
          end

        if all_results_ok?(results) do
          {:ok, %{params | field => pluck_value(results)}}
        else
          {:error, pluck_error(results)}
        end

      false ->
        error("#{@t}.schema", path: path(field, options), value: params[field], schema: schema)
    end
  end

  def type_validate(_field, params, %{type: :any}) do
    {:ok, params}
  end

  def type_validate(field, params, %{type: type} = options) do
    case type in all_types() do
      true ->
        if params[field] |> validate_all_items_by(type) |> all_results_ok?() do
          {:ok, params}
        else
          error("#{@t}.#{type}", path: path(field, options), value: params[field])
        end

      false ->
        error("#{@t}.type", path: path(field, options), value: params[field], type: type)
    end
  end

  defp validate_all_items_by(value, type) do
    mod = Module.safe_concat(Joi.Type, type |> Atom.to_string() |> Macro.camelize())

    value
    |> Enum.with_index()
    |> Enum.map(fn {element, index} ->
      apply(mod, :validate_field, [index, %{index => element}, []])
    end)
  end

  defp all_results_ok?(results) do
    results |> Enum.all?(fn {k, _} -> k == :ok end)
  end

  defp pluck_error(list) do
    for {k, value} when k == :error <- list, do: value
  end

  defp pluck_value(list) do
    for {k, value} when k == :ok <- list, do: value
  end
end

