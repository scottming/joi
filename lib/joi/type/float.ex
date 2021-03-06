defmodule Joi.Type.Float do
  import Joi.Validator.Skipping
  import Joi.Util
  import Joi.Validator.Max, only: [max_validate: 4]
  import Joi.Validator.Min, only: [min_validate: 4]
  import Joi.Validator.Inclusion, only: [inclusion_validate: 4]
  require Decimal

  @default_options [
    required: true,
    min: nil,
    max: nil
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:float, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- inclusion_validate(:float, field, params, options),
           {:ok, params} <- min_validate(:float, field, params, options),
           {:ok, params} <-
             max_validate(:float, field, params, options) do
        {:ok, params}
      else
        {:error, msg} -> {:error, msg}
      end
    end
  end

  defp convert(field, params, _option) do
    raw_value = params[field]

    cond do
      raw_value == nil ->
        {:ok, params}

      Decimal.is_decimal(raw_value) ->
        {:ok, Map.put(params, field, Decimal.to_float(raw_value))}

      is_float(raw_value) ->
        {:ok, params}

      is_integer(raw_value) ->
        value = raw_value |> Integer.to_string() |> string_to_float()
        {:ok, Map.put(params, field, value)}

      String.valid?(raw_value) && string_to_float(raw_value) ->
        {:ok, Map.put(params, field, string_to_float(raw_value))}

      true ->
        error_message(field, params, "#{field} must be a float", "float")
    end
  end
end
