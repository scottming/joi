defmodule Joi.Type.DateTest do
  use ExUnit.Case, async: true
  alias Joi.Type

  @field "start_date"
  describe "validate_field/3" do
    test "convert a string to a date" do
      data = %{@field => "1990-05-01"}
      {:ok, expected_date} = Date.from_iso8601(data[@field])
      expected_data = %{@field => expected_date}
      options = []
      assert Type.Date.validate_field(@field, data, options) == {:ok, expected_data}
    end

    test "does not alter nil" do
      data = %{@field => nil}
      options = [required: false]

      assert Type.Date.validate_field(@field, data, options) == {:ok, data}
    end

    test "allows Date" do
      {:ok, date} = Date.from_iso8601("1999-01-05")
      data = %{@field => date}
      options = []

      assert Type.Date.validate_field(@field, data, options) == {:ok, data}
    end

    test "errors when required date is not provided" do
      data = %{}

      options = []

      assert Type.Date.validate_field(@field, data, options) ==
               {:error,
                %{
                  constraint: true,
                  field: "start_date",
                  message: "start_date is required",
                  type: "date.required"
                }}
    end

    test "errors when the value is not a string" do
      data = %{@field => 1234}

      options = []

      assert Type.Date.validate_field(@field, data, options) ==
               {:error,
                %{
                  constraint: "date",
                  field: @field,
                  message: "start_date must be a valid ISO-8601 date",
                  type: "date"
                }}
    end

    test "errors when the value is not in an ISO-8601 date with timezone format" do
      data = %{@field => "2018-06-01T06:32:00Z"}

      options = []

      assert Type.Date.validate_field(@field, data, options) ==
               {:error,
                %{
                  constraint: "date",
                  field: @field,
                  message: "start_date must be a valid ISO-8601 date",
                  type: "date"
                }}
    end

    test "does not error if the field is not provided and not required" do
      field = "id"
      data = %{}
      options = [required: false]
      assert Type.Date.validate_field(field, data, options) == {:ok, data}
    end
  end
end
