defmodule Joi.Type.DecimalTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  require Decimal
  import Joi.Type.Decimal

  @field :field

  property "check all input will convert to an float" do
    check all(
            value <- random_value(),
            data = %{@field => value}
          ) do
      assert {:ok, result} = validate_field(@field, data, [])
      assert is_value_decimal?(result)
    end
  end

  defp random_value() do
    integer_string = map(integer(), &Integer.to_string/1)
    float_string = map(float(), &Float.to_string/1)
    decimal = map(float(), &Decimal.from_float/1)

    [integer(), float(), integer_string, float_string, decimal] |> one_of()
  end

  defp is_value_decimal?(m) do
    m |> Map.get(@field) |> Decimal.is_decimal()
  end
end
