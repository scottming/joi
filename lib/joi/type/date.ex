defmodule Joi.Type.Date do
  import Joi.Validator.Skipping
  import Joi.Util

  @t :date

  @default_options [
    required: true,
    format: "iso8601"
  ]

  def message_map(options) do
    field = options[:path] |> List.last()

    %{
      "#{@t}.required" => "#{field} is required",
      "#{@t}.base" => "#{field} must be a valid ISO-8601 date"
    }
  end

  def message(code, options) do
    message_map(options) |> Map.get(code)
  end

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

  def convert(field, params, options) do
    value = params[field]

    cond do
      value == nil ->
        {:ok, params}

      is_binary(value) ->
        case Date.from_iso8601(value) do
          {:ok, date} ->
            {:ok, %{params | field => date}}

          _ ->
            error("#{@t}.base", path: path(field, options), value: value)
        end

      date?(value) ->
        {:ok, params}

      true ->
        error("#{@t}.base", path: path(field, options), value: value)
    end
  end

  defp date?(%Date{}), do: true

  defp date?(_), do: false
end
