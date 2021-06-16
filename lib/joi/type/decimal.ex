defmodule Joi.Type.Decimal do
  require Decimal
  import Joi.Util
  import Joi.Validator.Skipping
  import Joi.Validator.Inclusion, only: [inclusion_validate: 4]
  import Joi.Validator.Max, only: [max_validate: 4]
  import Joi.Validator.Min, only: [min_validate: 4]

  @t :decimal

  @default_options [
    required: true,
    min: nil,
    max: nil
  ]

  def message(code, options) do
    field = options[:path] |> List.last
    limit = options[:limit]

    %{
      "#{@t}.required" => "#{field} is required",
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.max" => "#{field} must be less than or equal to #{limit}",
      "#{@t}.min" => "#{field} must be greater than or equal to #{limit}"
    }
    |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:decimal, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- inclusion_validate(:decimal, field, params, options),
           {:ok, params} <- max_validate(:decimal, field, params, options),
           {:ok, params} <- min_validate(:decimal, field, params, options) do
        {:ok, params}
      end
    end
  end

  def convert(field, params, options) do
    raw_value = params[field]

    cond do
      raw_value == nil ->
        {:ok, params}

      Decimal.is_decimal(raw_value) ->
        {:ok, params}

      is_float(raw_value) ->
        {:ok, Map.put(params, field, Decimal.from_float(raw_value))}

      is_integer(raw_value) ->
        value = raw_value |> Integer.to_string() |> string_to_float() |> Decimal.from_float()
        {:ok, Map.put(params, field, value)}

      String.valid?(raw_value) && string_to_float(raw_value) ->
        value = string_to_float(raw_value) |> Decimal.from_float()
        {:ok, Map.put(params, field, value)}

      true ->
        error("#{@t}.base", path: path(field, options), value: raw_value)
    end
  end
end
