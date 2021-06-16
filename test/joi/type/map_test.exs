defmodule Joi.Type.MapTest do
  use ExUnit.Case, async: true

  describe "validate nested types" do
    test "success: with sub schema" do
      data = %{m: %{id: 1}}
      sub_schema = %{id: [:integer, max: 3]}
      schema = %{m: [:map, schema: sub_schema]}

      assert {:ok, data} == Joi.validate(data, schema)
    end

    test "error: with sub schema" do
      raw_data = %{m: %{id: 4}}
      sub_schema = %{id: [:integer, max: 3]}
      schema = %{m: [:map, schema: sub_schema]}
      assert {:error, errors} = Joi.validate(raw_data, schema)

      assert errors == [
               %Joi.Error{
                 context: %{key: :id, limit: 3, value: 4},
                 message: "id must be less than or equal to 3",
                 path: [:m, :id],
                 type: "integer.max"
               }
             ]
    end

    test "success: when schema is nil and value is a map" do
      data = %{m: %{}}
      schema = %{m: [:map]}
      assert {:ok, data} == Joi.validate(data, schema)
    end

    test "error: when schema is nil and value is not a map" do
      data = %{m: 1}
      schema = %{m: [:map]}
      assert {:error, errors} = Joi.validate(data, schema)

      assert errors == [
               %Joi.Error{
                 context: %{key: :m, value: 1},
                 message: "m must be a map",
                 path: [:m],
                 type: "map.base"
               }
             ]
    end
  end
end

