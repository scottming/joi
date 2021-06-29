defmodule Joi.Type.Integer do
  import Joi.Validator.Skipping
  import Joi.Util
  import Joi.Validator.Max, only: [max_validate: 4]
  import Joi.Validator.Min, only: [min_validate: 4]
  import Joi.Validator.Inclusion, only: [inclusion_validate: 4]

  @t :integer

  @default_options [
    required: true,
    min: nil,
    max: nil
  ]

  def message(code, options) do
    field = options[:label] || options[:path] |> List.last()
    limit = options[:limit]
    inclusion = options[:inclusion]

    %{
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.required" => "#{field} is required",
      "#{@t}.max" => "#{field} must be less than or equal to #{limit}",
      "#{@t}.min" => "#{field} must be greater than or equal to #{limit}",
      "#{@t}.inclusion" => "#{field} must be one of #{inspect(inclusion)}"
    }
    |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:integer, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- inclusion_validate(:integer, field, params, options),
           {:ok, params} <- min_validate(:integer, field, params, options),
           {:ok, params} <-
             max_validate(:integer, field, params, options) do
        {:ok, params}
      else
        {:error, msg} -> {:error, msg}
      end
    end
  end

  defp convert(field, params, options) do
    # NOTE: do not convert decimal
    raw_value = params[field]

    cond do
      raw_value == nil ->
        {:ok, params}

      is_float(raw_value) ->
        {:ok, Map.put(params, field, round(raw_value))}

      is_integer(raw_value) ->
        {:ok, params}

      String.valid?(raw_value) && string_to_integer(raw_value) ->
        {:ok, Map.put(params, field, string_to_integer(raw_value))}

      true ->
        error("#{@t}.base", path: path(field, options), value: raw_value)
    end
  end

  defp string_to_integer(str) do
    case Integer.parse(str) do
      {num, _} -> num
      _ -> nil
    end
  end
end

