defmodule Joi.Type.IntegerTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest Joi.Type.Integer, import: true

  import Joi.Type.Integer

  @t :integer
  @field :field

  use Joi.Support.Properties.Generators

  use Joi.Support.ConvertTestHelper,
    input: &random_input/0,
    incorrect_input: &random_incorrect_input/0,
    is_converted?: &is_value_integer?/1

  defp random_input() do
    [integer(), float(), integer_string(), float_string()] |> one_of()
  end

  defp random_incorrect_input() do
    [bitstring(), boolean()] |> one_of()
  end

  defp is_value_integer?(m) do
    m |> Map.get(@field) |> is_integer()
  end
end

