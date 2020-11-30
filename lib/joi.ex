defmodule Joi do
  @moduledoc """
  Joi is a data validation library for Elixir.
  """

  alias Joi.Type

  def validate(data, schema) do
    Enum.reduce_while(schema, {:ok, data}, fn {field, [type | options]}, {:ok, modified_data} ->
      case Type.validate(type, field, modified_data, options) do
        {:error, msg} ->
          {:halt, {:error, msg}}

        {:ok, new_data} ->
          {:cont, {:ok, new_data}}
      end
    end)
  end
end
