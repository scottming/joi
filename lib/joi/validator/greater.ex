defmodule Joi.Validator.Greater do
  import Joi.Util
  require Decimal

  def greater_validate(type, field, params, %{greater: greater} = options)
      when type in [:float, :integer] and not is_nil(greater) do
    value = params[field]

    case value > greater do
      true ->
        {:ok, params}

      false ->
        error("#{type}.greater", path: path(field, options), value: value, limit: greater)
    end
  end

  def greater_validate(:decimal = type, field, params, %{greater: greater} = options) when not is_nil(greater) do
    greater = greater |> Joi.Validator.Max.to_decimal()
    value = params[field]

    case Decimal.compare(value, greater) == :gt do
      true ->
        {:ok, params}

      false ->
        error("#{type}.greater", path: path(field, options), value: value, limit: greater)
    end
  end

  def greater_validate(_, _, params, %{greater: nil}) do
    {:ok, params}
  end
end
