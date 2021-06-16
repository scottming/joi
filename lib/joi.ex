defmodule Joi do
  @moduledoc """
  Joi is a data validation library for Elixir.
  """

  alias Joi.Type

  def validate(data, schema) do
    data |> Map.put(:joi_errors, []) |> validate_all_fields(schema) |> parse_result()
  end

  def validate_all_fields(data, schema) do
    Enum.reduce(schema, {:ok, data}, fn {field, [type | options]}, {:ok, modified_data} ->
      case Type.validate(type, field, modified_data, options) do
        {:error, error} ->
          {:ok, %{modified_data | joi_errors: [error | modified_data.joi_errors]}}

        {:ok, new_data} ->
          {:ok, new_data}
      end
    end)
  end

  def parse_result(result) do
    {:ok, data} = result

    case data.joi_errors do
      [] -> {:ok, Map.drop(data, [:joi_errors])}
      errors -> {:error, errors |> List.flatten()}
    end
  end
end

