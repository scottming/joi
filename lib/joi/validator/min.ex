defmodule Joi.Validator.Min do
  import Joi.Util
  import Joi.Validator.Max, only: [to_decimal: 1]

  def min_validate(type, field, params, %{min: min})
      when type in [:float, :integer] and not is_nil(min) do
    raw_value = params[field]

    case raw_value >= min do
      true ->
        {:ok, params}

      false ->
        error_message(
          field,
          params,
          "#{field} must be gather than or equal to #{min}",
          "#{type}.min",
          min
        )
    end
  end

  def min_validate(:decimal, field, params, %{min: min}) when not is_nil(min) do
    min = min |> to_decimal()
    value = params[field]

    case Decimal.compare(value, min) in [:gt, :eq] do
      true ->
        {:ok, params}

      false ->
        error_message(
          field,
          params,
          "#{field} must be gather than or equal to #{min}",
          "decimal.min",
          min
        )
    end
  end

  def min_validate(_, _, params, %{min: nil}) do
    {:ok, params}
  end
end
