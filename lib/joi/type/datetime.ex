defmodule Joi.Type.Datetime do
  @moduledoc false
  import Joi.Validator.Skipping
  import Joi.Util

  @t :datetime

  @default_options [
    required: true
  ]

  def message(code, options) do
    field = options[:path] |> hd

    %{
      "#{@t}.required" => "#{field} is required",
      "#{@t}.base" => "#{field} must be a valid ISO-8601 datetime"
    }
    |> Map.get(code)
  end

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

  defp convert(field, params, options) do
    value = params[field]

    cond do
      value == nil ->
        {:ok, params}

      is_binary(value) ->
        case DateTime.from_iso8601(value) do
          {:ok, date_time, _utc_offset} ->
            {:ok, Map.put(params, field, date_time)}

          {:error, _} ->
            error("#{@t}.base", path: path(field, options), value: value)
        end

      datetime?(value) ->
        {:ok, params}

      true ->
        error("#{@t}.base", path: path(field, options), value: value)
    end
  end

  defp datetime?(%DateTime{}), do: true
  defp datetime?(_), do: false
end

