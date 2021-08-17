defmodule Joi.Validator.Compare do
  import Joi.Util
  require Decimal

  def validate(type, field, params, %{less: target} = options, :less = cmp) when not is_nil(target) do
    value = params[field] 
    target = target(target, type)

    case compare(type, value, target) == :lt do
      true -> {:ok, params}
      false -> error("#{type}.#{cmp}", path: path(field, options), value: value, limit: target)
    end
  end

  def validate(type, field, params, %{greater: target} = options, :greater = cmp) when not is_nil(target) do
    value = params[field]
    target = target(target, type)

    case compare(type, value, target) == :gt do
      true -> {:ok, params}
      false -> error("#{type}.#{cmp}", path: path(field, options), value: value, limit: target)
    end
  end

  def validate(type, field, params, %{min: target} = options, :min = cmp) when not is_nil(target) do
    value = params[field]
    target = target(target, type)

    case compare(type, value, target) in [:eq, :gt] do
      true -> {:ok, params}
      false -> error("#{type}.#{cmp}", path: path(field, options), value: value, limit: target)
    end
  end

  def validate(type, field, params, %{max: target} = options, :max = cmp) when not is_nil(target) do
    value = params[field] 
    target = target(target, type)

    case compare(type, value, target) in [:eq, :lt] do
      true -> {:ok, params}
      false -> error("#{type}.#{cmp}", path: path(field, options), value: value, limit: target)
    end
  end

  def validate(_, _, params, _options, _) do
    {:ok, params}
  end

  defp compare(:decimal, value, target) do
    Decimal.compare(value, target)
  end

  defp compare(_type, value, target) do
    cond do
      value < target -> :lt
      value > target -> :gt
      true -> :eq
    end
  end

  defp target(target, :decimal) do
    to_decimal(target)
  end

  defp target(target, _type) do
    target
  end

  defp to_decimal(i) when is_integer(i) do
    Decimal.new(i)
  end

  defp to_decimal(f) when is_float(f) do
    Decimal.from_float(f)
  end

  defp to_decimal(d) do
    case Decimal.is_decimal(d) do
      true -> d
      false -> raise "can not convert #{inspect(d)} to decimal"
    end
  end
end

