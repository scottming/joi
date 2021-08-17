defmodule Joi.Validator.Min do
  def min_validate(type, field, params, options) do
    Joi.Validator.Compare.validate(type, field, params, options, :min)
  end
end

