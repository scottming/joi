defmodule Joi.Type.StringTest do
  use ExUnit.Case, async: true
  import Joi.Type.String
  use ExUnitProperties
  use Joi.Support.Properties.Generators

  @t :string
  @field :field

  use Joi.Support.ConvertTestHelper,
    input: &random_input/0,
    incorrect_input: &random_incorrect_input/0,
    is_converted?: &is_value_string?/1

  defp random_input() do
    printable_string = StreamData.string(:printable, min_length: 0, max_length: 9)
    [integer(), float(), boolean(), atom(:alphanumeric), printable_string] |> one_of()
  end

  defp random_incorrect_input() do
    [tuple({integer(), float()}), list_of(binary())] |> one_of()
  end

  defp is_value_string?(data) do
    String.valid?(data[@field])
  end

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

      assert error == %Joi.Error{
               context: %{key: @field, regex: ~r/^[a-zA-Z0-9_]*$/, value: "x@##1"},
               message: "#{@field} must be in a valid format",
               path: [@field],
               type: "string.format"
             }
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

      assert error == %Joi.Error{
               context: %{key: @field, value: "12345"},
               message: "#{@field} must be a uuid",
               path: [@field],
               type: "string.uuid"
             }
    end
  end
end

