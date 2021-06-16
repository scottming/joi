defmodule Joi.Validator.MinLength do
  import Joi.Util

  def min_length_validate(type, field, params, %{min_length: min_length} = options)
      when is_integer(min_length) and min_length > 0 do
    if params[field] == nil or len(params[field]) < min_length do
      error("#{type}.min_length",
        path: path(field, options),
        value: params[field],
        limit: min_length
      )
    else
      {:ok, params}
    end
  end

  def min_length_validate(_type, _field, params, %{}) do
    {:ok, params}
  end
end
