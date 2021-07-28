defmodule Joi do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias Joi.Type

  @doc ~S"""
  Validate the data by schema

  Examples:
  
      iex> schema = %{
      ...>   id: [:string, uuid: true],
      ...>   username: [:string, min_length: 6],
      ...>   pin: [:integer, min: 1000, max: 9999],
      ...>   new_user: [:boolean, truthy: ["1"], falsy: ["0"], required: false],
      ...>   account_ids: [:list, type: :integer, max_length: 3],
      ...>   remember_me: [:boolean, required: false]
      ...> }
      %{
        account_ids: [:list, {:type, :integer}, {:max_length, 3}],
        id: [:string, {:uuid, true}],
        new_user: [:boolean, {:truthy, ["1"]}, {:falsy, ["0"]}, {:required, false}],
        pin: [:integer, {:min, 1000}, {:max, 9999}],
        remember_me: [:boolean, {:required, false}],
        username: [:string, {:min_length, 6}]
      }
      iex> data = %{id: "c8ce4d74-fab8-44fc-90c2-736b8d27aa30", username: "user@123", pin: 1234, new_user: "1", account_ids: [1, 3, 9]}
      %{
        account_ids: [1, 3, 9],
        id: "c8ce4d74-fab8-44fc-90c2-736b8d27aa30",
        new_user: "1",
        pin: 1234,
        username: "user@123"
      }
      iex> Joi.validate(data, schema)
      {:ok,
       %{
         account_ids: [1, 3, 9],
         id: "c8ce4d74-fab8-44fc-90c2-736b8d27aa30",
         new_user: true,
         pin: 1234,
         username: "user@123"
       }}
      iex> error_data = %{id: "1", username: "user", pin: 999, new_user: 1, account_ids: [1, 3, 9, 12]}
      %{account_ids: [1, 3, 9, 12], id: "1", new_user: 1, pin: 999, username: "user"}
      iex> Joi.validate(error_data, schema)
      {:error,
       [
         %Joi.Error{
           context: %{key: :username, limit: 6, value: "user"},
           message: "username length must be at least 6 characters long",
           path: [:username],
           type: "string.min_length"
         },
         %Joi.Error{
           context: %{key: :pin, limit: 1000, value: 999},
           message: "pin must be greater than or equal to 1000",
           path: [:pin],
           type: "integer.min"
         },
         %Joi.Error{
           context: %{key: :new_user, value: 1},
           message: "new_user must be a boolean",
           path: [:new_user],
           type: "boolean.base"
         },
         %Joi.Error{
           context: %{key: :id, value: "1"},
           message: "id must be a uuid",
           path: [:id],
           type: "string.uuid"
         },
         %Joi.Error{
           context: %{key: :account_ids, limit: 3, value: [1, 3, 9, 12]},
           message: "account_ids must contain less than or equal to 3 items",
           path: [:account_ids],
           type: "list.max_length"
         }
       ]}

  """
  @spec validate(map(), map()) :: {:error, list(Joi.Error.t())} | {:ok, map()}
  def validate(data, schema) do
    data |> Map.put(:joi_errors, []) |> validate_all_fields(schema) |> parse_result()
  end

  defp validate_all_fields(data, schema) do
    Enum.reduce(schema, {:ok, data}, fn {field, [type | options]}, {:ok, modified_data} ->
      case Type.validate(type, field, modified_data, options) do
        {:error, error} ->
          {:ok, %{modified_data | joi_errors: [error | modified_data.joi_errors]}}

        {:ok, new_data} ->
          {:ok, new_data}
      end
    end)
  end

  defp parse_result(result) do
    {:ok, data} = result

    case data.joi_errors do
      [] -> {:ok, Map.drop(data, [:joi_errors])}
      errors -> {:error, errors |> List.flatten()}
    end
  end
end

