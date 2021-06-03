defmodule Joi.Type.StringTest do
  use ExUnit.Case, async: true
  import Joi.Type.String

  @field :field

  describe "regex validation" do
    test "success: when value matches the regex pattern" do
      data = %{@field => "user123"}
      options = [regex: ~r/^[a-zA-Z0-9_]*$/]
      assert {:ok, data} == validate_field(@field, data, options)
    end

    test "error: when value does not match regex pattern" do
      data = %{@field => "x@##1"}
      options = [regex: ~r/^[a-zA-Z0-9_]*$/]
      assert {:error, error} = validate_field(@field, data, options)
      assert error.message == "#{@field} must be in a valid format"
    end
  end

  describe "uuid validation" do
    test "success: when is a valid UUID" do
      data = %{@field => UUID.uuid4()}
      options = [uuid: true]
      assert {:ok, data} == validate_field(@field, data, options)
    end

    test "error: when is not a valid UUID" do
      data = %{field: "12345"}
      options = [uuid: true]
      assert {:error, error} = validate_field(@field, data, options)
      assert error.message == "#{@field} must be a uuid"
    end
  end
end

