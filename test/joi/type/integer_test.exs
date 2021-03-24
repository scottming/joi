defmodule Joi.Type.IntegerTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Joi.Support.Properties.Generators
  import Joi.Type.Integer

  @field :field

  property "check all input will convert to an integer" do
    check all value <- random_value(),
              data = %{@field => value} do
      assert {:ok, result} = validate_field(@field, data, [])
      assert is_value_integer?(result)
    end
  end

  defp random_value() do
    [integer(), float(), integer_string(), float_string()] |> one_of()
  end

  defp is_value_integer?(m) do
    m |> Map.get(@field) |> is_integer()
  end
end
