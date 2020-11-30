defmodule Joi.Type.Number do
  import Joi.Validator.Skipping

  @default_options [integer: true, required: true]

  def validate_field(field, params, options) do
    options = Keyword.merge(@default_options, options)

    unless_skipping(field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- integer_validate(field, params, options),
           {:ok, params} <- min_validate(field, params, options),
           {:ok, params} <-
             max_validate(field, params, options) do
        {:ok, params}
      else
        {:error, msg} -> {:error, msg}
      end
    end
  end

  defp convert(field, params, _option) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_number(params[field]) ->
        {:ok, params}

      is_binary(params[field]) && string_to_number(params[field]) ->
        modified_value = string_to_number(params[field])
        {:ok, Map.put(params, field, modified_value)}

      true ->
        {:error, "#{field} must be a number"}
    end
  end

  defp string_to_number(str) do
    str = if String.starts_with?(str, "."), do: "0" <> str, else: str

    cond do
      int = string_to_integer(str) -> int
      float = string_to_float(str) -> float
      true -> nil
    end
  end

  defp string_to_integer(str) do
    case Integer.parse(str) do
      {num, ""} -> num
      _ -> nil
    end
  end

  defp string_to_float(str) do
    case Float.parse(str) do
      {num, ""} -> num
      _ -> nil
    end
  end

  defp integer_validate(field, params, options) when is_list(options) do
    case Keyword.get(options, :integer) do
      false -> integer_validate(field, params, false)
      _ -> integer_validate(field, params, true)
    end
  end

  defp integer_validate(_field, params, false) do
    {:ok, params}
  end

  defp integer_validate(field, params, true) do
    if is_integer(params[field]) do
      {:ok, params}
    else
      {:error, "#{field} must be an integer"}
    end
  end

  defp min_validate(field, params, options) when is_list(options) do
    min = Keyword.get(options, :min)

    case is_number(min) do
      true -> min_validate(field, params, min)
      # when nil or not number
      false -> {:ok, params}
    end
  end

  defp min_validate(field, params, min) do
    if params[field] < min do
      {:error, "#{field} must be greater than or equal to #{min}"}
    else
      {:ok, params}
    end
  end

  defp max_validate(field, params, options) when is_list(options) do
    max = Keyword.get(options, :max)

    case is_number(max) do
      true -> max_validate(field, params, max)
      # when nil or not number
      false -> {:ok, params}
    end
  end

  defp max_validate(field, params, max) do
    if params[field] > max do
      {:error, "#{field} must be less than or equal to #{max}"}
    else
      {:ok, params}
    end
  end
end
