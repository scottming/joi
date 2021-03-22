defmodule Joi.Type.NumberTest do
  use ExUnit.Case, async: true

  alias Joi.Type

  describe "validate_field/3" do
    @tag :unit
    test "success: validates Type.Number fields in a schema" do
      data = %{id: 1}

      field = :id
      schema = %{id: [:number]}
      [_type | options] = schema[field]

      assert Type.Number.validate_field(field, data, options) == {:ok, data}
    end

    @tag :unit
    test "error: when field is nil" do
      data = %{}

      expected_error =
        {:error,
         %{
           constraint: true,
           field: :id,
           value: nil,
           message: "id is required",
           type: "number.required"
         }}

      field = :id
      schema = %{id: [:number]}
      [_type | options] = schema[field]

      assert Type.Number.validate_field(field, data, options) == expected_error
    end

    @tag :unit
    test "success: if the field is not provided and not required" do
      data = %{}

      field = :id
      schema = %{id: [:number, required: false]}
      [_type | options] = schema[field]

      assert Type.Number.validate_field(field, data, options) == {:ok, data}
    end
  end

  describe "convert string to number" do
    @tag :integration
    test "success: with modified value" do
      float_data = %{id: ".6"}
      integer_data = %{id: "6"}
      modified_float_data = %{id: 0.6}
      modified_integer_data = %{id: 6}

      integer_schema = %{
        id: [:number]
      }

      float_schema = %{
        id: [:number, integer: false]
      }

      assert Joi.validate(integer_data, integer_schema) == {:ok, modified_integer_data}
      assert Joi.validate(float_data, float_schema) == {:ok, modified_float_data}
    end

    @tag :integration
    test "error: if field type is neither number or stringified number" do
      invalid_number = %{id: "1.a"}
      boolean_data = %{id: true}

      schema = %{
        id: [:number]
      }

      assert Joi.validate(invalid_number, schema) ==
               {:error,
                [
                  %{
                    constraint: "number",
                    field: :id,
                    value: invalid_number[:id],
                    message: "id must be a number",
                    type: "number"
                  }
                ]}

      assert Joi.validate(boolean_data, schema) ==
               {:error,
                [
                  %{
                    constraint: "number",
                    field: :id,
                    value: boolean_data[:id],
                    message: "id must be a number",
                    type: "number"
                  }
                ]}
    end

    @tag :unit
    test "success: does not convert nil to a number" do
      field = :id
      data = %{id: nil}
      # The default required is true
      options = [required: false]

      assert Type.Number.validate_field(field, data, options) == {:ok, data}
    end
  end

  describe "minimum validation" do
    test "success: returns :ok when field is more than or equal to min value" do
      data = %{id: 6}

      schema = %{
        id: [:number, min: 3]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when field is less than min" do
      data = %{id: 1}

      schema = %{
        id: [:number, min: 3]
      }

      assert Joi.validate(data, schema) ==
               {:error,
                [
                  %{
                    constraint: 3,
                    field: :id,
                    value: data[:id],
                    message: "id must be greater than or equal to 3",
                    type: "number.min"
                  }
                ]}
    end
  end

  describe "maximum validation" do
    test "returns :ok when field is less than or equal to max" do
      data = %{id: 1}

      schema = %{
        id: [:number, max: 3]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when field is more than max" do
      data = %{id: 6}

      schema = %{
        id: [:number, max: 3]
      }

      assert Joi.validate(data, schema) ==
               {:error,
                [
                  %{
                    constraint: 3,
                    field: :id,
                    value: data[:id],
                    message: "id must be less than or equal to 3",
                    type: "number.max"
                  }
                ]}
    end
  end

  describe "integer type validation" do
    test "returns :ok when field is an integer and the schema property integer is set to true" do
      data = %{id: 1}

      schema = %{
        id: [:number]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when field is a float and the schema property integer is set to true" do
      data = %{id: 1.6}

      schema = %{
        id: [:number]
      }

      assert Joi.validate(data, schema) ==
               {:error,
                [
                  %{
                    constraint: true,
                    field: :id,
                    value: data[:id],
                    message: "id must be an integer",
                    type: "number.integer"
                  }
                ]}
    end
  end
end
