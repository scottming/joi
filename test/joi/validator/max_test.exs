defmodule Joi.Validator.MaxTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Joi.Support.Util

  @validator :max
  @field :field
  @types [:integer, :float, :decimal]

  describe "max validation" do
    property "success: with valid attrs when validate max" do
      check all value <- negative_integer(), type <- member_of(@types) do
        data = %{@field => value}
        options = [max: -1]

        module = atom_type_to_mod(type)
        assert {:ok, _} = apply(module, :validate_field, [@field, data, options])
      end
    end

    property "errors: with invalid attrs when validate max" do
      check all value <- positive_integer(), type <- member_of(@types) do
        data = %{@field => value}
        options = [max: 0]

        module = atom_type_to_mod(type)
        assert {:error, error} = apply(module, :validate_field, [@field, data, options])

        assert %Joi.Error{
                 context: %{key: :field, limit: limit, value: _value},
                 message: "field must be less than or equal to 0",
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

