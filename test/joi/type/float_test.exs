defmodule Joi.Type.FloatTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Joi.Support.Properties.Generators
  import Joi.Type.Float

  @field :field
  @t :float

  use Joi.Support.ConvertTestHelper,
    input: &random_input/0,
    incorrect_input: &random_incorrect_input/0,
    is_converted?: &is_value_float?/1

  defp random_input() do
    [integer(), float(), decimal(), integer_string(), float_string()] |> one_of()
  end

  defp random_incorrect_input() do
    [boolean(), bitstring() |> reject(&is_integer_string?/1)] |> one_of()
  end

  defp is_value_float?(m) do
    m |> Map.get(@field) |> is_float()
  end
end

