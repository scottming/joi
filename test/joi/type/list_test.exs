defmodule Joi.Type.ListTest do
  use ExUnit.Case, async: true
  alias Joi.Type

  describe "validate_field/3" do
    test "validates property values of data based on their List schema definition in Type.List module" do
      field = :id
      data = %{id: ["1"]}

      assert Type.List.validate_field(field, data, []) == {:ok, data}
    end

    test "does not convert nil to a list" do
      field = :id
      data = %{id: nil}

      options = [required: false]

      assert Type.List.validate_field(field, data, options) == {:ok, data}
    end

    test "does not error if the field is not provided and not required" do
      field = :id
      data = %{}

      options = [length: 3, type: :boolean, required: false]

      assert Type.List.validate_field(field, data, options) == {:ok, data}
    end
  end

  describe "check if field is list" do
    test "returns :ok with params if field is a list" do
      data = %{id: [1, 2, 3]}
      schema = %{id: [:list, type: :number]}
      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors if field is not a list" do
      data = %{id: "1, 2, 3"}
      schema = %{id: [:list]}
      assert Joi.validate(data, schema) == {:error, ["id must be a list"]}
    end
  end

  describe "minimum length validation" do
    test "returns :ok when field list length is more than or equal to min_length" do
      data = %{id: [1, 2, 3]}

      schema = %{
        id: [:list, type: :number, min_length: 3]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when field list length is less than min_length" do
      data = %{id: [1, 2]}

      schema = %{
        id: [:list, type: :number, min_length: 3]
      }

      assert Joi.validate(data, schema) == {:error, ["id must not be below length of 3"]}
    end
  end

  describe "maximum length validation" do
    test "returns :ok when field list length is less than or equal to max_length" do
      data = %{id: [1, 2, 3]}

      schema = %{
        id: [:list, type: :number, max_length: 3]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when field list length is more than max_length" do
      data = %{id: [1, 2, 3, 4]}

      schema = %{
        id: [:list, type: :number, max_length: 3]
      }

      assert Joi.validate(data, schema) == {:error, ["id must not exceed length of 3"]}
    end
  end

  describe "exact length validation" do
    test "returns :ok when field list length is equal to length" do
      data = %{id: [1, 2, 3]}

      schema = %{
        id: [:list, type: :number, length: 3]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when field list length is not equal to length" do
      data = %{id: [1, 2]}

      schema = %{
        id: [:list, type: :number, length: 3]
      }

      assert Joi.validate(data, schema) == {:error, ["id length must be of 3 length"]}
    end
  end

  describe "list element type validation" do
    test "returns :ok with params if field elements are of any type if no type specified" do
      data = %{id: [1, "2", 3]}

      schema = %{
        id: [:list, type: :any]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok with params if field elements are of the type specified" do
      data = %{
        "id_atom" => [:a, :b],
        "id_boolean" => [true, false],
        "id_number" => [1, 2],
        "id_string" => ["a", "b"],
        "id_any" => [1, "a"]
      }

      schema = %{
        "id_atom" => [:list, type: :atom],
        "id_boolean" => [:list, type: :boolean],
        "id_number" => [:list, type: :number],
        "id_string" => [:list, type: :string],
        "id_any" => [:list, type: :any]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors if field elements are not of the type specified" do
      data = %{id: [1, 2, "3", :a, true]}

      schema_atom = %{id: [:list, type: :atom]}
      schema_boolean = %{id: [:list, type: :boolean]}
      schema_number = %{id: [:list, type: :number]}
      schema_string = %{id: [:list, type: :string]}

      assert Joi.validate(data, schema_atom) == {:error, ["id must be a list of atoms"]}
      assert Joi.validate(data, schema_boolean) == {:error, ["id must be a list of boolean"]}
      assert Joi.validate(data, schema_number) == {:error, ["id must be a list of numbers"]}
      assert Joi.validate(data, schema_string) == {:error, ["id must be a list of strings"]}
    end
  end
end
