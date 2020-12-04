defmodule Joi.Type.DateTime do
  @moduledoc false
  import Joi.Validator.Skipping
  import Joi.Util

  @default_options [
    required: true
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, data, options) do
    unless_skipping(:datetime, field, data, options) do
      with {:ok, data} <- convert(field, data, options) do
        {:ok, data}
      end
    end
  end

  defp convert(field, params, _options) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_binary(params[field]) ->
        case DateTime.from_iso8601(params[field]) do
          {:ok, date_time, _utc_offset} -> {:ok, Map.put(params, field, date_time)}
          {:error, _} -> error_tuple(field)
        end

      datetime?(params[field]) ->
        {:ok, params}

      true ->
        error_tuple(field)
    end
  end

  defp datetime?(%DateTime{}), do: true
  defp datetime?(_), do: false

  defp error_tuple(field) do
    error_message(field, "#{field} must be a valid ISO-8601 datetime", "datetime")
  end
end
