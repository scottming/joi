defmodule Joi.Validator.MaxLengthTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Joi.Support.Util
  import Assertions

  @field :field
  @max_length 3
  @validator :max_length

  test "types that support #{@validator}" do
    assert_lists_equal(types_by(@validator), [:string, :list])
  end

  describe "validate max_length" do
    for {t, value} <- [string: "1234", list: [1, 2, 3, 4]] do
      test "error: when type is #{t}, max_length is #{@max_length}, value is #{inspect(value)}" do
        data = %{@field => unquote(value)}
        type_module = atom_type_to_mod(unquote(t))
        assert {:error, error} = apply(type_module, :validate_field, [@field, data, [max_length: @max_length]])
        assert error.type == "#{unquote(t)}.#{@validator}"
      end
    end
  end
end
