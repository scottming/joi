defmodule Joi.Type.Boolean do
  @moduledoc false

  @t :boolean
  @truthy_default [true, "true"]
  @falsy_default [false, "false"]

  @default_options [
    required: true,
    truthy: @truthy_default,
    falsy: @falsy_default
  ]

  import Joi.Validator.Skipping
  import Joi.Util

  def message(code, options) do
    field = options[:path] |> hd

    %{
      "#{@t}.required" => "#{field} is required",
      "#{@t}.base" => "#{field} must be a #{@t}"
    }
    |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, data, options) do
    unless_skipping(@t, field, data, options) do
      with {:ok, data} <- truthy_falsy_validate(field, data, options) do
        {:ok, data}
      end
    end
  end

  defp check_boolean_values(initial_value, additional_values, default_values)
       when is_binary(initial_value) do
    allowed_values =
      additional_values
      |> (&(&1 ++ default_values)).()
      |> Enum.uniq()
      |> Enum.map(fn item ->
        if is_binary(item) do
          String.downcase(item)
        end
      end)

    String.downcase(initial_value) in allowed_values
  end

  defp check_boolean_values(initial_value, additional_values, default_values) do
    initial_value in Enum.uniq(additional_values ++ default_values)
  end

  defp truthy_falsy_validate(field, params, %{falsy: falsy, truthy: truthy} = options) do
    value = params[field]

    cond do
      value == nil ->
        {:ok, params}

      check_boolean_values(value, truthy, @truthy_default) ->
        {:ok, Map.replace!(params, field, true)}

      check_boolean_values(value, falsy, @falsy_default) ->
        {:ok, Map.replace!(params, field, false)}

      true ->
        error("#{@t}.base", path: path(field, options), value: value)
    end
  end
end

