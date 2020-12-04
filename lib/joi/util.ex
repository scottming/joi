defmodule Joi.Util do
  def error_message(field, message, type) do
    {:error, %{field: field, message: message, type: type, constraint: type}}
  end

  def error_message(field, message, type, constraint) do
    {:error, %{field: field, message: message, type: type, constraint: constraint}}
  end
end
