defmodule Joi.Type.FloatTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Joi.Type.Float

  @field :field

  property "check all input will convert to an float" do
    check all value <- random_value(),
              data = %{@field => value} do
      assert {:ok, result} = validate_field(@field, data, [])
      assert is_value_float?(result)
    end
  end

  defp random_value() do
    integer_string = map(integer(), &Integer.to_string/1)
    float_string = map(float(), &Float.to_string/1)

    [integer(), float(), integer_string, float_string] |> one_of()
  end

  defp is_value_float?(m) do
    m |> Map.get(@field) |> is_float()
  end
end
