defmodule Joi.Validator.CustomTest do
  use ExUnit.Case, async: true
  alias Joi.Validator.Custom

  describe "validate_field/3" do
    test "success: when single function in the function_list" do
      field = :username
      data = %{username: "scott"}
      expected_data = %{username: "SCOTT"}
      f = fn field, x -> {:ok, %{x | field => String.upcase(x[field])}} end
      assert Custom.validate_field(field, data, [f]) == {:ok, expected_data}
    end

    test "success: when multiple functions" do
      field = :id
      data = %{id: 2}
      expected_data = %{id: 6}

      f1 = fn field, x -> {:ok, %{x | field => x[field] + 1}} end
      f2 = fn field, x -> {:ok, %{x | field => x[field] * 2}} end

      assert Custom.validate_field(field, data, [f1, f2]) == {:ok, expected_data}
    end
  end

  describe "Joi.validate/2" do
    test "success: multiple custom functions and multiple fields" do
      data = %{id: 2, username: "scott"}
      expected_data = %{id: 6, username: "SCOTT"}

      f1 = fn field, x -> {:ok, %{x | field => x[field] + 1}} end
      f2 = fn field, x -> {:ok, %{x | field => x[field] * 2}} end
      f3 = fn field, x -> {:ok, %{x | field => String.upcase(x[field])}} end
      schema = %{id: [:integer, f: f1, f: f2], username: [:string, f: f3]}

      assert Joi.validate(data, schema) == {:ok, expected_data}
    end

    defp custom_function(field, x, options \\ []) do
      case is_list(x[field]) and x[field] |> Enum.uniq() == x[field] do
        true ->
          {:ok, x}

        false ->
          if message = Keyword.get(options, :message) do
            {:error, message}
          else
            {:error, "#{x[field]} must be uniq"}
          end
      end
    end

    test "error: custom function with empty options" do
      data = %{l: [1, 2, 2]}
      expected = "#{data[:l]} must be uniq"
      # TODO: modify number
      schema = %{l: [:list, type: :integer, f: &custom_function/2]}

      assert Joi.validate(data, schema) == {:error, [expected]}
    end

    test "error: custom function with options" do
      data = %{l: [1, 2, 2]}
      expected = "uniq_error"
      # TODO: modify number
      schema = %{l: [:list, type: :integer, f: &custom_function(&1, &2, message: "uniq_error")]}

      assert Joi.validate(data, schema) == {:error, [expected]}
    end

    test "success: custom function will called when data[field] exist" do
      data = %{id: 1}
      f = fn field, x -> {:ok, %{x | field => x[field] * 2}} end
      schema = %{id: [:integer, required: false, f: f]}
      assert Joi.validate(data, schema) == {:ok, %{id: 2}}
    end

    test "success: custom function will not be called when data[field] isn't exist" do
      data = %{id: 1}
      f = fn field, x -> {:ok, %{x | field => x[field] * 2}} end
      schema = %{false_id: [:integer, required: false, f: f]}
      assert Joi.validate(data, schema) == {:ok, %{id: 1}}
    end
  end
end
