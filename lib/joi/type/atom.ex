defmodule Joi.Type.Atom do
  @moduledoc false

  import Joi.Validator.Skipping
  import Joi.Util

  alias Joi.Validator.Inclusion

  @default_options [
    required: true
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:string, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- Inclusion.validate_field(:atom, field, params, options) do
        {:ok, params}
      end
    end
  end

  def convert(field, params, _options) do
    cond do
      params[field] == nil ->
        {:ok, params}

      String.valid?(params[field]) ->
        {:ok, Map.update!(params, field, &string_to_atom/1)}

      is_number(params[field]) ->
        {:ok, Map.update!(params, field, &(&1 |> to_string() |> string_to_atom()))}

      is_boolean(params[field]) ->
        {:ok, params}

      is_atom(params[field]) ->
        {:ok, params}

      true ->
        error_message(field, params, "#{field} must be a atom", "atom")
    end
  end

  defp string_to_atom(s) do
    String.to_atom(s)
  end
end
