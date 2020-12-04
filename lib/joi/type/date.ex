defmodule Joi.Type.Date do
  import Joi.Validator.Skipping
  import Joi.Util

  @default_options [
    required: true
  ]

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:date, field, params, options) do
      case convert(field, params, options) do
        {:ok, params} -> {:ok, params}
        other -> other
      end
    end
  end

  def convert(field, params, _options) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_binary(params[field]) ->
        case Date.from_iso8601(params[field]) do
          {:ok, date} -> {:ok, %{params | field => date}}
          _ -> error_tuple(field)
        end

      date?(params[field]) ->
        {:ok, params}

      true ->
        error_tuple(field)
    end
  end

  defp date?(%Date{}), do: true

  defp date?(_), do: false

  defp error_tuple(field) do
    error_message(field, "#{field} must be a valid ISO-8601 date", "date")
  end
end
