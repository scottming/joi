defmodule Joi.Type.List do
  @moduledoc false
  import Joi.Validator.Skipping
  import Joi.Util

  import Joi.Validator.MaxLength, only: [max_length_validate: 4]
  import Joi.Validator.MinLength, only: [min_length_validate: 4]
  import Joi.Validator.Length, only: [length_validate: 4]

  @t :list
  @default_options [
    required: true,
    type: :any,
    min_length: nil,
    max_length: nil,
    length: nil
  ]

  def message(code, options) do
    field = options[:path] |> hd
    # type = String.split(code, ".") |> List.last()
    limit = options[:limit]

    %{
      # atoms, numbers, :strings
      # "#{@t}.#{type}" => "#{field} must be a #{@t} of #{type}s",
      # "#{@t}.boolean" => "#{field} must be a #{@t} of boolean",
      "#{@t}.base" => "#{field} must be a #{@t}",
      "#{@t}.required" => "#{field} is required",
      "#{@t}.length" => "#{field} must contain #{limit} items",
      "#{@t}.max_length" => "#{field} must contain less than or equal to #{limit} items",
      "#{@t}.min_length" => "#{field} must contain at least #{limit} items"
    }
    |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(:list, field, params, options) do
      with {:ok, params} <- validate_list(field, params, options),
           {:ok, params} <- type_validate(field, params, options),
           {:ok, params} <- min_length_validate(@t, field, params, options),
           {:ok, params} <- max_length_validate(@t, field, params, options),
           {:ok, params} <- length_validate(@t, field, params, options) do
        {:ok, params}
      end
    end
  end

  def validate_list(field, params, options) do
    cond do
      params[field] == nil ->
        {:ok, params}

      is_list(params[field]) ->
        {:ok, params}

      true ->
        error("#{@t}.base", path: path(field, options), value: params[field])
    end
  end

  def type_validate(_field, params, %{type: _type}) do
    # TODO: support all types that Joi supported
    {:ok, params}
  end
end

