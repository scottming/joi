defmodule Joi.Type.IntegerTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use Joi.Support.Properties.Generators
  import Joi.Type.Integer

  @t :integer
  @field :field

  property "check all input will convert to an integer" do
    check all value <- random_value(),
              data = %{@field => value} do
      assert {:ok, result} = validate_field(@field, data, [])
      assert is_value_integer?(result)
    end
  end

  @tag :unit
  test "can not convert some binary to string" do
    data = %{@field => <<123>>}
    assert {:error, error} = validate_field(@field, data, [])

    assert error == %Joi.Error{
             type: "integer.base",
             message: "field must be a #{@t}",
             path: [:field],
             context: %{key: :field, value: <<123>>}
           }
  end

  @tag :unit
  test "validates with min" do
    data = %{@field => 1}
    assert {:error, error} = validate_field(@field, data, required: true, min: 3)

    assert error == %Joi.Error{
             context: %{key: :field, value: 1, limit: 3},
             message: "field must be greater than or equal to 3",
             path: [:field],
             type: "integer.min"
           }
  end

  @tag :unit
  test "validates with inclusion" do
    inclusion = [1, 2]
    data = %{@field => 0}
    assert {:error, error} = validate_field(@field, data, required: true, inclusion: inclusion)

    assert error == %Joi.Error{
             context: %{key: @field, value: 0, inclusion: inclusion},
             message: "field must be one of #{inspect(inclusion)}",
             path: [@field],
             type: "integer.inclusion"
           }
  end

  defp random_value() do
    [integer(), float(), integer_string(), float_string()] |> one_of()
  end

  defp is_value_integer?(m) do
    m |> Map.get(@field) |> is_integer()
  end
end

