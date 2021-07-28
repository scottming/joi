defmodule Joi.Type.BooleanTest do
  use ExUnit.Case, async: true
  import Joi.Type.Boolean

  @t :boolean
  @field :field

  describe "truthy validation" do
    test "success: when truthy is default" do
      data = %{@field => "true"}
      assert {:ok, %{@field => true}} == validate_field(@field, data, [])
    end

    test "success: when custom truthy" do
      data = %{@field => 1}
      assert {:ok, %{@field => true}} == validate_field(@field, data, truthy: [1])
    end

    test "error: when value is not in truthy" do
      data = %{@field => 1}
      assert {:error, error} = validate_field(@field, data, [])

      assert error == %Joi.Error{
               context: %{key: @field, value: 1},
               message: "#{@field} must be a #{@t}",
               path: [@field],
               type: "#{@t}.base"
             }
    end
  end

  describe "falsy validation" do
    test "success: when falsy is default" do
      data = %{@field => "false"}
      assert {:ok, %{@field => false}} == validate_field(@field, data, [])
    end

    test "success: when custom falsy" do
      data = %{@field => 1}
      assert {:ok, %{@field => false}} == validate_field(@field, data, falsy: [1])
    end

    test "error: when value is not in falsy" do
      data = %{@field => 1}
      assert {:error, error} = validate_field(@field, data, [])
      assert error == %Joi.Error{
               context: %{key: @field, value: 1},
               message: "#{@field} must be a #{@t}",
               path: [@field],
               type: "#{@t}.base"
             }
    end
  end
end

