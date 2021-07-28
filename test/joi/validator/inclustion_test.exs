defmodule Joi.Validator.InclusionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Joi.Support.Util
  import Assertions

  @field :field
  @inclusion [:fake_inclusion]
  @validator :inclusion

  test "types that support #{@validator}" do
    assert_lists_equal(types_by(@validator), [:atom, :string, :integer, :float, :decimal])
  end

  describe "validate inclusion" do
    for type <- types_by("inclusion") do
      test "error: when type is #{type}, inclusion is #{inspect(@inclusion)}" do
        data = %{@field => "1"}
        type_module = atom_type_to_mod(unquote(type))
        assert {:error, error} = apply(type_module, :validate_field, [@field, data, [inclusion: @inclusion]])

        assert %Joi.Error{
                 context: %{inclusion: @inclusion, key: :field, value: _value},
                 message: "field must be one of [:fake_inclusion]",
                 path: [:field],
                 type: error_type
               } = error

        assert error_type == "#{unquote(type)}.inclusion"
      end
    end
  end
end

