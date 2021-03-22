defmodule Joi.Type.String do
  @moduledoc false

  import Joi.Validator.Skipping
  import Joi.Util

  @default_options [
    required: true,
    min_length: nil,
    max_length: 255,
    length: nil,
    regex: nil,
    uuid: nil
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:string, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- min_length_validate(field, params, options),
           {:ok, params} <- max_length_validate(field, params, options),
           {:ok, params} <- length_validate(field, params, options),
           {:ok, params} <- regex_validate(field, params, options),
           {:ok, params} <-
             uuid_validate(field, params, options) do
        {:ok, params}
      end
    end
  end

  def convert(field, params, _options) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_binary(params[field]) ->
        {:ok, params}

      is_number(params[field]) or is_boolean(params[field]) ->
        {:ok, Map.update!(params, field, &to_string/1)}

      true ->
        error_message(field, params, "#{field} must be a string", "string")
    end
  end

  defp min_length_validate(field, params, %{min_length: min_length})
       when is_integer(min_length) and min_length > 0 do
    if params[field] == nil or String.length(params[field]) < min_length do
      error_message(
        field,
        params,
        "#{field} length must be greater than or equal to #{min_length} characters",
        "string.min_length",
        min_length
      )
    else
      {:ok, params}
    end
  end

  defp min_length_validate(_field, params, %{}) do
    {:ok, params}
  end

  defp max_length_validate(_field, params, %{max_length: nil}) do
    {:ok, params}
  end

  defp max_length_validate(field, params, %{max_length: max_length})
       when is_integer(max_length) and max_length >= 0 do
    if Map.get(params, field) && String.length(params[field]) > max_length do
      error_message(
        field,
        params,
        "#{field} length must be less than or equal to #{max_length} characters",
        "string.max_length",
        max_length
      )
    else
      {:ok, params}
    end
  end

  defp length_validate(field, params, %{length: length}) when is_integer(length) and length > 0 do
    if params[field] == nil || String.length(params[field]) != length do
      error_message(
        field,
        params,
        "#{field} length must be #{length} characters",
        "string.length",
        length
      )
    else
      {:ok, params}
    end
  end

  defp length_validate(_field, params, %{length: _}) do
    {:ok, params}
  end

  defp regex_validate(_field, params, %{regex: nil}) do
    {:ok, params}
  end

  defp regex_validate(field, params, %{regex: regex}) do
    if params[field] == nil or !Regex.match?(regex, params[field]) do
      error_message(field, params, "#{field} must be in a valid format", "string.regex", regex)
    else
      {:ok, params}
    end
  end

  defp uuid_validate(field, params, %{uuid: true}) do
    case UUID.info(params[field]) do
      {:ok, _} ->
        {:ok, params}

      _ ->
        error_message(field, params, "#{field} is not a valid uuid", "string.uuid", true)
    end
  end

  defp uuid_validate(_field, params, %{uuid: _}) do
    {:ok, params}
  end
end
