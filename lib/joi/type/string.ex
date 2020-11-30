defmodule Joi.Type.String do
  @moduledoc false

  import Joi.Validator.Skipping

  @default_options [required: true, max_length: 255]

  def validate_field(field, params, options) do
    options = Keyword.merge(@default_options, options)

    unless_skipping(field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- min_length_validate(field, params, options),
           {:ok, params} <- max_length_validate(field, params, options),
           {:ok, params} <- length_validate(field, params, options),
           {:ok, params} <- regex_validate(field, params, options) do
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
        {:error, "#{field} must be a string"}
    end
  end

  defp min_length_validate(field, params, options) when is_list(options) do
    min_length = Keyword.get(options, :min_length)

    case min_length > 0 and is_integer(min_length) do
      true -> min_length_validate(field, params, min_length)
      _ -> {:ok, params}
    end
  end

  defp min_length_validate(field, params, min_length) do
    if params[field] == nil or String.length(params[field]) < min_length do
      {:error, "#{field} length must be greater than or equal to #{min_length} characters"}
    else
      {:ok, params}
    end
  end

  defp max_length_validate(field, params, options) when is_list(options) do
    max_length = Keyword.get(options, :max_length)

    case max_length > 0 and is_integer(max_length) do
      true -> max_length_validate(field, params, max_length)
      _ -> {:ok, params}
    end
  end

  defp max_length_validate(field, params, max_length) do
    if Map.get(params, field) && String.length(params[field]) > max_length do
      {:error, "#{field} length must be less than or equal to #{max_length} characters"}
    else
      {:ok, params}
    end
  end

  defp length_validate(field, params, options) when is_list(options) do
    length = Keyword.get(options, :length)

    if is_integer(length) and length > 0 do
      length_validate(field, params, length)
    else
      {:ok, params}
    end
  end

  defp length_validate(field, params, length) do
    if params[field] == nil || String.length(params[field]) != length do
      {:error, "#{field} length must be #{length} characters"}
    else
      {:ok, params}
    end
  end

  defp regex_validate(field, params, options) when is_list(options) do
    regex = Keyword.get(options, :regex)

    if is_nil(regex) do
      {:ok, params}
    else
      regex_validate(field, params, regex)
    end
  end

  defp regex_validate(field, params, regex) do
    if params[field] == nil or !Regex.match?(regex, params[field]) do
      {:error, "#{field} must be in a valid format"}
    else
      {:ok, params}
    end
  end
end
