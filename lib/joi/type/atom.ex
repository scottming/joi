defmodule Joi.Type.Atom do
  @moduledoc false

  import Joi.Util
  import Joi.Validator.Skipping
  import Joi.Validator.Inclusion, only: [inclusion_validate: 4]

  @t :atom

  @default_options [
    required: true
  ]

  def message(code, options) do
    field = options[:path] |> List.last
    inclusion = options[:inclusion]

    %{
      "#{@t}.base" => "#{field} must be an #{@t}",
      "#{@t}.required" => "#{field} is required",
      "#{@t}.inclusion" => "#{field} must be one of #{inspect(inclusion)}"
    }
    |> Map.get(code)
  end

  def validate_field(field, params, options) when is_list(options) do
    options = Keyword.merge(@default_options, options) |> Enum.into(%{})
    validate_field(field, params, options)
  end

  def validate_field(field, params, options) do
    unless_skipping(@t, field, params, options) do
      with {:ok, params} <- convert(field, params, options),
           {:ok, params} <- inclusion_validate(@t, field, params, options) do
        {:ok, params}
      end
    end
  end

  @doc """
  Returns {:ok, atom} when convert is true

  These types of conversions are supported:
    * string
    * boolean
    * atom
  """
  def convert(field, params, options) do
    value = params[field]

    cond do
      value == nil ->
        {:ok, params}

      String.valid?(value) ->
        {:ok, Map.update!(params, field, &string_to_atom/1)}

      is_boolean(value) ->
        {:ok, params}

      is_atom(value) ->
        {:ok, params}

      true ->
        error("#{@t}.base", path: path(field, options), value: value)
    end
  end

  defp string_to_atom(s) do
    String.to_atom(s)
  end
end
