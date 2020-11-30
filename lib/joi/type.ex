defmodule Joi.Type do
  @moduledoc false

  alias __MODULE__

  def validate(type, field, data, option) do
    cond do
      type == :number -> Type.Number.validate_field(field, data, option)
      true -> {:ok, data}
    end
  end
end
