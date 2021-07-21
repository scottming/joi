defmodule Joi.Validator.Max do
  import Joi.Util
  require Decimal

  def max_validate(type, field, params, %{max: max} = options)
      when type in [:float, :integer] and not is_nil(max) do
    value = params[field]

    case value <= max do
      true ->
        {:ok, params}

      false ->
        error("#{type}.max", path: path(field, options), value: value, limit: max)
    end
  end

  def max_validate(:decimal = type, field, params, %{max: max} = options) when not is_nil(max) do
    max = max |> to_decimal()
    value = params[field]

    case Decimal.compare(value, max) in [:lt, :eq] do
      true ->
        {:ok, params}

      false ->
        error("#{type}.max", path: path(field, options), value: value, limit: max)
    end
  end

  def max_validate(_, _, params, %{max: nil}) do
    {:ok, params}
  end

  def to_decimal(i) when is_integer(i) do
    Decimal.new(i)
  end

  def to_decimal(f) when is_float(f) do
    Decimal.from_float(f)
  end

  def to_decimal(d) do
    case Decimal.is_decimal(d) do
      true -> d
      false -> raise "can not convert #{inspect(d)} to decimal"
    end
  end
end
