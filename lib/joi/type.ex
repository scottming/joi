defmodule Joi.Type do
  @moduledoc false

  alias __MODULE__

  def validate(type, field, data, options) do
    cond do
      type == :number -> Type.Number.validate_field(field, data, options)
      type == :string -> Type.String.validate_field(field, data, options)
      type == :list -> Type.List.validate_field(field, data, options)
      type == :boolean -> Type.Boolean.validate_field(field, data, options)
      type == :datetime -> Type.DateTime.validate_field(field, data, options)
      type == :date -> Type.Date.validate_field(field, data, options)
      true -> {:ok, data}
    end
  end
end
