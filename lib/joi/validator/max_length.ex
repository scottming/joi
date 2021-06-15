defmodule Joi.Validator.MaxLength do
  import Joi.Util

  def max_length_validate(_type, _field, params, %{max_length: nil}) do
    {:ok, params}
  end

  def max_length_validate(type, field, params, %{max_length: max_length} = options)
       when is_integer(max_length) and max_length >= 0 do
    if Map.get(params, field) && len(params[field]) > max_length do
      error("#{type}.max_length",
        path: path(field, options),
        value: params[field],
        limit: max_length
      )
    else
      {:ok, params}
    end
  end
end

