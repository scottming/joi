defmodule Joi.Type.Number do
  import Joi.Validator.Skipping
  import Joi.Util

  @default_options [
    required: true,
    integer: true,
    min: nil,
    max: nil
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:number, field, params, options) do
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
        error_message(field, "#{field} must be a number", "number")
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

  defp integer_validate(_field, params, %{integer: false}) do
    {:ok, params}
  end

  defp integer_validate(field, params, %{integer: true}) do
    if is_integer(params[field]) do
      {:ok, params}
    else
      error_message(field, "#{field} must be an integer", "number.integer", true)
    end
  end

  defp min_validate(_field, params, %{min: nil}) do
    {:ok, params}
  end

  defp min_validate(field, params, %{min: min}) when is_number(min) do
    if params[field] < min do
      error_message(field, "#{field} must be greater than or equal to #{min}", "number.min", min)
    else
      {:ok, params}
    end
  end

  defp max_validate(_field, params, %{max: nil}) do
    {:ok, params}
  end

  defp max_validate(field, params, %{max: max}) when is_number(max) do
    if params[field] > max do
      error_message(field, "#{field} must be less than or equal to #{max}", "number.max", max)
    else
      {:ok, params}
    end
  end
end
