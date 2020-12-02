defmodule Joi.Validator.Custom do
  def custom_validate(field, data, functions) do
    Enum.reduce_while(functions, {:ok, data}, fn {:f, f}, {:ok, modified_data} ->
      case f.(field, modified_data) do
        {:error, msg} ->
          {:halt, {:error, msg}}

        {:ok, new_data} ->
          {:cont, {:ok, new_data}}
      end
    end)
  end
end
