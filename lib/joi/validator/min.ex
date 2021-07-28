defmodule Joi.Validator.Min do
  import Joi.Util
  import Joi.Validator.Max, only: [to_decimal: 1]

  def min_validate(type, field, params, %{min: min} = options)
      when type in [:float, :integer] and not is_nil(min) do
    value = params[field]

    case value >= min do
      true ->
        {:ok, params}

      false ->
        error("#{type}.min", path: path(field, options), value: value, limit: min)
    end
  end

  def min_validate(:decimal, field, params, %{min: min} = options) when not is_nil(min) do
    min = min |> to_decimal()
    value = params[field]

    case Decimal.compare(value, min) in [:gt, :eq] do
      true ->
        {:ok, params}

      false ->
        error("decimal.min", path: path(field, options), value: value, limit: min)
    end
  end

  def min_validate(_, _, params, %{min: nil}) do
    {:ok, params}
  end
end
