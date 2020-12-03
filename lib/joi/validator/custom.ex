defmodule Joi.Validator.Custom do
  def validate_field(field, data, functions) when is_list(functions) do
    Enum.reduce_while(functions, {:ok, data}, fn f, {:ok, modified_data} ->
      case f.(field, modified_data) do
        {:error, msg} ->
          {:halt, {:error, msg}}

        {:ok, new_data} ->
          {:cont, {:ok, new_data}}
      end
    end)
  end
end
