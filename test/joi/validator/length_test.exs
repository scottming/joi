defmodule Joi.Validator.LengthTest do
  use ExUnit.Case, async: true
  import Joi.Support.Util
  import Assertions

  @field :field
  @length 2
  @validator :length

  test "types that support #{@validator}" do
    assert_lists_equal(types_by(@validator), [:string, :list])
  end

  describe "validate length" do
    test "error: when type is `string`, length is #{@length}, and value is \"123\"" do
      data = %{@field => "123"}
      assert {:error, error} = apply(Joi.Type.String, :validate_field, [@field, data, [length: @length]])

      assert error == %Joi.Error{
               context: %{key: :field, limit: 2, value: "123"},
               message: "field length must be 2 characters",
               path: [:field],
               type: "string.length"
             }
    end

    test "error: when type is `list`, length is #{@length}, and value is [1, 2, 3]" do
      data = %{@field => [1, 2, 3]}
      assert {:error, error} = apply(Joi.Type.List, :validate_field, [@field, data, [length: @length]])

      assert error == %Joi.Error{
               context: %{key: :field, limit: 2, value: [1, 2, 3]},
               message: "field must contain 2 items",
               path: [:field],
               type: "list.length"
             }
    end
  end
end

