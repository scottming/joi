defmodule Joi.Type.Integer do
  @moduledoc false
  
  import Joi.Validator.Skipping
  import Joi.Util
  import Joi.Validator.Max, only: [max_validate: 4]
  import Joi.Validator.Min, only: [min_validate: 4]
  import Joi.Validator.Inclusion, only: [inclusion_validate: 4]
  import Joi.Validator.Greater, only: [greater_validate: 4]
  import Joi.Validator.Less, only: [less_validate: 4]

  @t :integer

  @default_options [
    required: true,
    min: nil,
    max: nil,
    greater: nil,
    less: nil
  ]

  def message_map(options) do
    field = options[:label] || options[:path] |> List.last()
    limit = options[:limit]
    inclusion = options[:inclusion]

    %{
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.required" => "#{field} is required",
      "#{@t}.max" => "#{field} must be less than or equal to #{limit}",
      "#{@t}.min" => "#{field} must be greater than or equal to #{limit}",
      "#{@t}.inclusion" => "#{field} must be one of #{inspect(inclusion)}",
      "#{@t}.greater" => "#{field} must be greater than #{limit}",
      "#{@t}.less" => "#{field} must be less than #{limit}"
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
    unless_skipping(:integer, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- inclusion_validate(:integer, field, params, options),
           {:ok, params} <- min_validate(:integer, field, params, options),
           {:ok, params} <-
             max_validate(:integer, field, params, options),
           {:ok, params} <- greater_validate(:integer, field, params, options),
           {:ok, params} <- less_validate(:integer, field, params, options) do
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

  @doc """
  Returns a integer when input a integer string or float string, others, Returns `nil`

  Examples:
    iex> string_to_integer("1")
    1
    iex> string_to_integer("01")
    1
    iex> string_to_integer("01k")
    nil
    iex> string_to_integer("1k")
    nil
    iex> string_to_integer("1.1")
    1
    iex> string_to_integer("1.1k")
    nil
  """
  def string_to_integer(str) do
    case Integer.parse(str) do
      # integer string, like "1", "2"
      {num, ""} ->
        num

      {num, maybe_float} ->
        case Float.parse("0" <> maybe_float) do
          {float, ""} when is_float(float) -> num
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
