defmodule Joi.Type.ListTest do
  use ExUnit.Case, async: true
  import Joi.Type.List

  @field :field

  describe "validate field" do
    test "success: when sub type is :any" do
      data_list = [%{@field => [1]}, %{@field => ["1"]}, %{@field => []}]

      for d <- data_list do
        assert {:ok, d} == validate_field(@field, d, [])
      end
    end

    test "success: when sub type is supported" do
      data_list = [%{@field => [1]}, %{@field => ["1"]}, %{@field => []}]
      option_list = [[type: :integer], [type: :string], [type: :atom]]

      for {d, op} <- Enum.zip(data_list, option_list) do
        assert {:ok, d} == validate_field(@field, d, op)
      end
    end

    test "error: when sub type is not supported" do
      data = %{@field => [1]}
      assert {:error, error} = validate_field(@field, data, type: :unknown)

      assert error == %Joi.Error{
               context: %{key: :field, type: :unknown, value: [1]},
               message: "unknown not supported",
               path: [:field],
               type: "list.type"
             }
    end
  end

  @another_field :another_field

  describe "Joi.validate" do
    @tag :integration
    test "success: when sub schema is exist" do
      data = %{@field => [%{@field => 1}, %{@field => 1}], @another_field => 1}
      field_schema = %{@field => [:string]}
      schema = %{@field => [:list, schema: field_schema], @another_field => [:integer]}
      assert Joi.validate(data, schema) == {:ok, %{@field => [%{@field => "1"}, %{@field => "1"}], @another_field => 1}}
    end

    @tag :integration
    test "error: when sub schema is exist" do
      data = %{@field => [%{@field => 1}, %{@field => <<123>>}]}
      field_schema = %{@field => [:integer]}
      schema = %{@field => [:list, schema: field_schema]}

      assert {:error, errors} = Joi.validate(data, schema)

      assert errors == [
               %Joi.Error{
                 context: %{key: @field, value: <<123>>},
                 message: "#{@field} must be a integer",
                 path: [@field, 1, @field],
                 type: "integer.base"
               }
             ]
    end
  end
end

