defmodule Joi.Type.List do
  @moduledoc false
  import Joi.Validator.Skipping
  import Joi.Util

  @default_options [
    required: true,
    type: :string,
    min_length: nil,
    max_length: nil,
    length: nil
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:list, field, params, options) do
      with {:ok, params} <- validate_list(field, params),
           {:ok, params} <- type_validate(field, params, options),
           {:ok, params} <- min_length_validate(field, params, options),
           {:ok, params} <- max_length_validate(field, params, options),
           {:ok, params} <- length_validate(field, params, options) do
        {:ok, params}
      end
    end
  end

  def validate_list(field, params) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_list(params[field]) ->
        {:ok, params}

      true ->
        error_message(field, "#{field} must be a list", "list")
    end
  end

  def type_validate(field, params, %{type: type}) do
    case type do
      :boolean -> validate_boolean(params, field)
      :number -> validate_number(params, field)
      :string -> validate_string(params, field)
      :atom -> validate_atom(params, field)
      :any -> {:ok, params}
    end
  end

  defp validate_atom(params, field) do
    if Enum.all?(params[field], &is_atom/1) do
      {:ok, params}
    else
      error_message(field, "#{field} must be a list of atoms", "list.type", "atom")
    end
  end

  defp validate_boolean(params, field) do
    if Enum.all?(params[field], &is_boolean/1) do
      {:ok, params}
    else
      error_message(field, "#{field} must be a list of boolean", "list.type", "boolean")
    end
  end

  defp validate_number(params, field) do
    if Enum.all?(params[field], &is_number/1) do
      {:ok, params}
    else
      error_message(field, "#{field} must be a list of numbers", "list.type", "number")
    end
  end

  defp validate_string(params, field) do
    if Enum.all?(params[field], &is_binary/1) do
      {:ok, params}
    else
      error_message(field, "#{field} must be a list of strings", "list.type", "string")
    end
  end

  defp min_length_validate(_field, params, %{min_length: nil}) do
    {:ok, params}
  end

  defp min_length_validate(field, params, %{min_length: min_length})
       when is_integer(min_length) and min_length >= 0 do
    if length(params[field]) < min_length do
      error_message(
        field,
        "#{field} must not be below length of #{min_length}",
        "list.min_length",
        min_length
      )
    else
      {:ok, params}
    end
  end

  defp max_length_validate(_field, params, %{max_length: nil}) do
    {:ok, params}
  end

  defp max_length_validate(field, params, %{max_length: max_length})
       when is_integer(max_length) and max_length >= 0 do
    if length(params[field]) > max_length do
      error_message(
        field,
        "#{field} must not exceed length of #{max_length}",
        "list.max_length",
        max_length
      )
    else
      {:ok, params}
    end
  end

  defp length_validate(_field, params, %{length: nil}) do
    {:ok, params}
  end

  defp length_validate(field, params, %{length: length})
       when is_integer(length) and length >= 0 do
    if length(params[field]) != length do
      error_message(field, "#{field} length must be of #{length} length", "list.length", length)
    else
      {:ok, params}
    end
  end
end
