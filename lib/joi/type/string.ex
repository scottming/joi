defmodule Joi.Type.String do
  @moduledoc false

  import Joi.Validator.Skipping
  import Joi.Util
  import Joi.Validator.Inclusion, only: [inclusion_validate: 4]

  @t :string

  @default_options [
    required: true,
    min_length: nil,
    max_length: 255,
    length: nil,
    regex: nil,
    uuid: nil
  ]

  def message(code, options) do
    field = options[:path] |> hd
    limit = options[:limit]

    %{
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.max_length" => "#{field} length must be less than or equal to #{limit} characters long",
      "#{@t}.min_length" => "#{field} length must be at least #{limit} characters long",
      "#{@t}.length" => "#{field} length must be #{limit} characters",
      # TODO: .format or .regex
      "#{@t}.format" => "#{field} must be in a valid format",
      "#{@t}.uuid" => "#{field} must be a uuid"
    }
    |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:string, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- inclusion_validate(:string, field, params, options),
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

  def convert(field, params, options) do
    value = params[field]

    cond do
      value == nil ->
        {:ok, params}

      is_binary(value) ->
        {:ok, params}

      is_number(value) or is_boolean(value) ->
        {:ok, Map.update!(params, field, &to_string/1)}

      true ->
        error("#{@t}.base", path: path(field, options), value: value)
    end
  end

  defp min_length_validate(field, params, %{min_length: min_length} = options)
       when is_integer(min_length) and min_length > 0 do
    if params[field] == nil or String.length(params[field]) < min_length do
      error("#{@t}.min_length",
        path: path(field, options),
        value: params[field],
        limit: min_length
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

  defp max_length_validate(field, params, %{max_length: max_length} = options)
       when is_integer(max_length) and max_length >= 0 do
    if Map.get(params, field) && String.length(params[field]) > max_length do
      error("#{@t}.max_length",
        path: path(field, options),
        value: params[field],
        limit: max_length
      )
    else
      {:ok, params}
    end
  end

  defp length_validate(field, params, %{length: length} = options)
       when is_integer(length) and length > 0 do
    if params[field] == nil || String.length(params[field]) != length do
      error("#{@t}.length", path: path(field, options), value: params[field], limit: length)
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

  defp regex_validate(field, params, %{regex: regex} = options) do
    if params[field] == nil or !Regex.match?(regex, params[field]) do
      error("#{@t}.format", path: path(field, options), value: params[field], regex: regex)
    else
      {:ok, params}
    end
  end

  defp uuid_validate(field, params, %{uuid: true} = options) do
    case UUID.info(params[field]) do
      {:ok, _} ->
        {:ok, params}

      _ ->
        error("#{@t}.uuid", path: path(field, options), value: params[field])
    end
  end

  defp uuid_validate(_field, params, %{uuid: _}) do
    {:ok, params}
  end
end

