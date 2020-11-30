defmodule Joi.Validator.Skipping do
  defmacro unless_skipping(field, params, options, do: unskipped) do
    quote do
      cond do
        skip?(unquote(options)) ->
          {:ok, unquote(params)}

        unless_field_not_nil(unquote(field), unquote(params)) ->
          unquote(unskipped)

        true ->
          {:error, "#{unquote(field)} is required"}
      end
    end
  end

  def skip?(options) do
    Keyword.get(options, :required) == false
  end

  def unless_field_not_nil(field, params) do
    Map.has_key?(params, field) && params[field] != nil
  end
end
