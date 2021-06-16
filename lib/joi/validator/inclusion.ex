defmodule Joi.Validator.Inclusion do
  import Joi.Util

  def inclusion_validate(type, field, params, %{inclusion: inclusion} = options) do
    value = params[field]

    case value in inclusion do
      true ->
        {:ok, params}

      false ->
        error("#{type}.inclusion", path: path(field, options), value: value, inclusion: inclusion)
    end
  end

  def inclusion_validate(_type, _field, params, _) do
    {:ok, params}
  end
end
