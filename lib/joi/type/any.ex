defmodule Joi.Type.Any do
  @moduledoc """
  This type provides validation for any type of value.

  ## Options

    * `:default` - Setting `:default` will populate a field with the provided
      value, assuming that it is not present already. If a field already has a
      value present, it will not be altered.

    * `:required` - Setting `:required` to `true` will cause a validation error
      when a field is not present or the value is `nil`. Allowed values for
      required are `true` and `false`. The default is `false`.

  ## Examples

      iex> schema = %{"id" => %Joi.Type.Any{required: true}}
      iex> Joi.validate(%{"id" => 1}, schema)
      {:ok, %{"id" => 1}}

      iex> schema = %{"id" => %Joi.Type.Any{default: "new_id"}}
      iex> Joi.validate(%{}, schema)
      {:ok, %{"id" => "new_id"}}

      iex> schema = %{"id" => %Joi.Type.Any{required: true}}
      iex> Joi.validate(%{}, schema)
      {:error, "id is required"}

      iex> schema = %{"id" => %Joi.Type.Any{required: true}}
      iex> Joi.validate(%{"id" => nil}, schema)
      {:error, "id is required"}

  """

  alias Joi.{Default, Required}

  defstruct default: Joi.Type.Any.NoDefault,
            required: false

  @type t :: %__MODULE__{
          default: any,
          required: boolean
        }

  @spec validate_field(t, term, map) :: {:ok, map} | {:error, String.t()}
  def validate_field(type, field, data) do
    case Required.validate(type, field, data) do
      {:ok, data} -> {:ok, data}
      {:ok_not_present, data} -> Default.validate(type, field, data)
      {:error, msg} -> {:error, msg}
    end
  end

  defimpl Joi.Type do
    alias Joi.Type

    @spec validate(Type.t(), term, map) :: {:ok, map} | {:error, String.t()}
    def validate(type, field, data), do: Type.Any.validate_field(type, field, data)
  end
end
