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
    for {type, value} <- [string: "1234", list: [1, 2, 3, 4]] do
      test "error: when type is #{type}, max_length is #{@max_length}, value is #{inspect(value)}" do
        data = %{@field => unquote(value)}
        type_module = atom_type_to_mod(unquote(type))
        assert {:error, error} = apply(type_module, :validate_field, [@field, data, [max_length: @max_length]])

        assert %Joi.Error{
                 context: %{key: :field, limit: 3, value: _value},
                 message: message,
                 path: [:field],
                 type: error_type
               } = error

        assert error_type == "#{unquote(type)}.max_length"

        assert message ==
                 if(error_type == "list.max_length",
                   do: "field must contain less than or equal to 3 items",
                   else: "field length must be less than or equal to 3 characters long"
                 )
      end
    end
  end
end

