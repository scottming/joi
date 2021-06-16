defmodule Joi.UtilTest do
  use ExUnit.Case, async: true
  import Joi.Util

  describe "is_schema/1" do
    test "when value is not list" do
      schema = %{id: :string}
      assert is_schema(schema) == false
    end

    test "when type is not support" do
      schema = %{id: [:string], email: [:email]}
      assert is_schema(schema) == false
    end

    test "when tail options is not a keyword list" do
      schema = %{id: [:string, :string]}
      assert is_schema(schema) == false
    end

    test "success: when with valid attrs" do
      schema = %{id: [:string, max_length: 10], age: [:integer, required: true]}
      assert is_schema(schema) == true
    end
  end
end
