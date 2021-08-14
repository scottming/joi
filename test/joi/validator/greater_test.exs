defmodule Joi.Validator.GreaterTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Joi.Support.Util
  import Assertions

  @field :field
  @validator :greater
  # TODO: support :integer and :float
  @types [:decimal]

  test "types that support #{@validator}" do
    assert_lists_equal(types_by(@validator), @types)
  end

  describe "max validation" do
    property "success: with valid attrs when validate min" do
      check all value <- positive_integer(), type <- member_of(@types) do
        data = %{@field => value}
        options = [greater: 0]

        module = atom_type_to_mod(type)
        assert {:ok, _} = apply(module, :validate_field, [@field, data, options])
      end
    end

    property "errors: with invalid attrs when validate min" do
      check all value <- negative_integer(), type <- member_of(@types) do
        data = %{@field => value}
        options = [greater: 0]

        module = atom_type_to_mod(type)
        assert {:error, error} = apply(module, :validate_field, [@field, data, options])

        assert %Joi.Error{
                 context: %{key: :field, limit: limit, value: _value},
                 message: "field must be greater than 0",
                 path: [:field],
                 type: error_type
               } = error

        assert limit in [Decimal.new(0), 0]
        assert error_type == "#{type}.#{@validator}"
      end
    end
  end

  defp negative_integer() do
    map(positive_integer(), &(&1 / -1))
  end
end
