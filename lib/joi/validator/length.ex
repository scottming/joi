defmodule Joi.Validator.Length do
  import Joi.Util

  def length_validate(type, field, params, %{length: length} = options) when is_integer(length) and length > 0 do
    if params[field] == nil || len(params[field]) != length do
      error("#{type}.length", path: path(field, options), value: params[field], limit: length)
    else
      {:ok, params}
    end
  end

  def length_validate(_type, _field, params, %{length: _}) do
    {:ok, params}
  end
end
