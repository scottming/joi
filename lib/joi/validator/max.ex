defmodule Joi.Validator.Max do
  import Joi.Util

  def max_validate(type, field, params, %{max: max})
      when type in [:float, :integer] and not is_nil(max) do
    raw_value = params[field]

    case raw_value <= max do
      true ->
        {:ok, params}

      false ->
        error_message(
          field,
          params,
          "#{field} must be less than or equal to #{max}",
          "#{type}.max",
          max
        )
    end
  end

  def max_validate(:decimal, field, params, %{max: max}) when not is_nil(max) do
    max = max |> to_decimal()
    value = params[field]

    case Decimal.compare(value, max) in [:lt, :eq] do
      true ->
        {:ok, params}

      false ->
        error_message(
          field,
          params,
          "#{field} must be less than or equal to #{max}",
          "decimal.max",
          max
        )
    end
  end

  def max_validate(_, _, params, %{max: nil}) do
    {:ok, params}
  end

  def to_decimal(i) when is_integer(i) do
    "#{i}.0" |> String.to_float() |> Decimal.from_float()
  end

  def to_decimal(f) do
    Decimal.from_float(f)
  end
end
