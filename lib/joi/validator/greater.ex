defmodule Joi.Validator.Greater do
  def greater_validate(type, field, params, options) do
    Joi.Validator.Compare.validate(type, field, params, options, :greater)
  end
end

