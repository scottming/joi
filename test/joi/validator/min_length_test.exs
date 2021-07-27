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
    for {type, value} <- [string: "12", list: [1, 2]] do
      test "error: when type is #{type}, min_length is #{@min_length}, and value is #{inspect(value)}" do
        data = %{@field => unquote(value)}
        type_module = atom_type_to_mod(unquote(type))
        assert {:error, error} = apply(type_module, :validate_field, [@field, data, [min_length: @min_length]])

        assert %Joi.Error{
                 context: %{key: :field, limit: 3, value: _value},
                 message: message,
                 path: [:field],
                 type: error_type
               } = error

        assert error_type == "#{unquote(type)}.min_length"

        assert message ==
                 if(error_type == "list.min_length",
                   do: "field must contain at least 3 items",
                   else: "field length must be at least 3 characters long"
                 )
      end
    end
  end
end

