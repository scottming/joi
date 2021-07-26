defmodule Joi.Type.AtomTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Joi.Type.Atom

  @t :atom
  @field :field

  use Joi.Support.ConvertTestHelper,
    input: &random_correct_input/0,
    incorrect_input: &random_incorrect_input/0,
    is_converted?: &is_value_atom?/1

  defp random_correct_input() do
    [string(:alphanumeric), boolean(), atom(:alphanumeric)] |> one_of()
  end

  defp random_incorrect_input() do
    [float(), integer()] |> one_of()
  end

  defp is_value_atom?(map) when is_map(map) do
    value = Map.get(map, @field)
    is_atom(value)
  end
end

