defmodule Joi.Type.DecimalTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  require Decimal
  import Joi.Type.Decimal

  @field :field
  @t :decimal

  use Joi.Support.ConvertTestHelper,
    input: &random_input/0,
    incorrect_input: &random_incorrect_input/0,
    is_converted?: &is_value_decimal?/1

  defp random_input() do
    integer_string = map(integer(), &Integer.to_string/1)
    float_string = map(float(), &Float.to_string/1)
    decimal = map(float(), &Decimal.from_float/1)

    [integer(), float(), integer_string, float_string, decimal] |> one_of()
  end

  defp random_incorrect_input() do
    [boolean(), bitstring()] |> one_of()
  end

  defp is_value_decimal?(m) do
    m |> Map.get(@field) |> Decimal.is_decimal()
  end
end

