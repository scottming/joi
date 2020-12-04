defmodule Joi.Validator.Skipping do
  import Joi.Util

  defmacro unless_skipping(type, field, params, options, do: unskipped) do
    quote do
      cond do
        skip?(unquote(options)) ->
          {:ok, unquote(params)}

        unless_field_not_nil(unquote(field), unquote(params)) ->
          unquote(unskipped)

        true ->
          full_type = Atom.to_string(unquote(type)) <> "." <> "required"
          error_message(unquote(field), "#{unquote(field)} is required", full_type, true)
      end
    end
  end

  def skip?(options) when is_list(options) do
    Keyword.get(options, :required) == false
  end

  def skip?(%{required: required}) do
    required == false
  end

  def unless_field_not_nil(field, params) do
    Map.has_key?(params, field) && params[field] != nil
  end
end
