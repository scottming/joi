defmodule Joi.Validator.Skipping do
  import Joi.Util

  @doc """
  When [required: false] and params[field] == nil, skip validating.
  """
  defmacro unless_skipping(type, field, params, options, do: unskipped) do
    quote do
      cond do
        unless_field_not_nil(unquote(field), unquote(params)) ->
          unquote(unskipped) 

        skip?(unquote(options)) ->
          {:ok, unquote(params)}

        true ->
          full_type = Atom.to_string(unquote(type)) <> "." <> "required"

          error(
            full_type,
            path: path(unquote(field), unquote(options)),
            value: nil
          )
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
