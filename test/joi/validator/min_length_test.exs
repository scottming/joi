defmodule Joi.Validator.MinLengthTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Joi.Support.Util
  import Assertions

  @field :field
  @min_length 3
  @validator :min_length

  test "types that support #{@validator}" do
    assert_lists_equal(types_by(@validator), [:string, :list])
  end

  describe "validate min_length" do
    for {t, value} <- [string: "12", list: [1, 2]] do
      test "error: when type is #{t}, min_length is #{@min_length}, and value is #{inspect(value)}" do
        data = %{@field => unquote(value)}
        type_module = atom_type_to_mod(unquote(t))
        assert {:error, error} = apply(type_module, :validate_field, [@field, data, [min_length: @min_length]])
        assert error.type == "#{unquote(t)}.#{@validator}"
      end
    end
  end
end

