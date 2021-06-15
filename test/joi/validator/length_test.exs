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
    for {t, value} <- [string: "123", list: [1, 2, 3]] do
      test "error: when type is #{t}, length is #{@length}, and value is #{inspect(value)}" do
        data = %{@field => unquote(value)}
        type_module = atom_type_to_mod(unquote(t))
        assert {:error, error} = apply(type_module, :validate_field, [@field, data, [length: @length]])
        assert error.type == "#{unquote(t)}.#{@validator}"
      end
    end
  end
end

