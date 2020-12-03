defmodule Joi.Validator.CustomTest do
  use ExUnit.Case, async: true
  alias Joi.Validator.Custom

  describe "validate_field/3" do
    test "when single function in the function_list" do
      field = :username
      data = %{username: "scott"}
      expected_data = %{username: "SCOTT"}
      f = fn field, x -> {:ok, %{x | field => String.upcase(x[field])}} end
      assert Custom.validate_field(field, data, [f]) == {:ok, expected_data}
    end

    test "when multiple functions" do
      field = :id
      data = %{id: 2}
      expected_data = %{id: 6}

      f1 = fn field, x -> {:ok, %{x | field => x[field] + 1}} end
      f2 = fn field, x -> {:ok, %{x | field => x[field] * 2}} end

      assert Custom.validate_field(field, data, [f1, f2]) == {:ok, expected_data}
    end
  end

  describe "Joi.validate/2" do
    test "multiple custom functions and multiple fields" do
      data = %{id: 2, username: "scott"}
      expected_data = %{id: 6, username: "SCOTT"}

      f1 = fn field, x -> {:ok, %{x | field => x[field] + 1}} end
      f2 = fn field, x -> {:ok, %{x | field => x[field] * 2}} end
      f3 = fn field, x -> {:ok, %{x | field => String.upcase(x[field])}} end
      schema = %{id: [:number, f: f1, f: f2], username: [:string, f: f3]}

      assert Joi.validate(data, schema) == {:ok, expected_data}
    end
  end
end
