defmodule Joi.Validator.Max do
  def max_validate(type, field, params, options) do
    Joi.Validator.Compare.validate(type, field, params, options, :max)
  end
end

