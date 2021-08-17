defmodule Joi.Validator.Less do
  def max_validate(type, field, params, options) do
    Joi.Validator.Compare.validate(type, field, params, options, :less)
  end
end
