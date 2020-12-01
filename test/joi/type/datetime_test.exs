defmodule Joi.Type.DateTimeTest do
  use ExUnit.Case, async: true

  alias Joi.Type

  @field "start_datetime"

  describe "validate_field/3" do
    test "converts a string to a datetime" do
      data = %{@field => "1990-05-01T06:32:00Z"}

      {:ok, expected_date_time, _} = DateTime.from_iso8601(data[@field])
      expected_data = %{@field => expected_date_time}

      options = []

      assert Type.DateTime.validate_field(@field, data, options) == {:ok, expected_data}
    end

    test "does not alter nil" do
      data = %{@field => nil}
      options = [required: false]

      assert Type.DateTime.validate_field(@field, data, options) == {:ok, data}
    end

    test "allows DateTimes" do
      {:ok, datetime, _} = DateTime.from_iso8601("1999-01-05T05:00:00Z")
      data = %{@field => datetime}

      options = []

      assert Type.DateTime.validate_field(@field, data, options) == {:ok, data}
    end

    test "errors when required datetime is not provided" do
      data = %{}

      options = []

      assert Type.DateTime.validate_field(@field, data, options) ==
               {:error, "start_datetime is required"}
    end

    test "errors when the value is not a string" do
      data = %{@field => 1234}

      options = []

      assert Type.DateTime.validate_field(@field, data, options) ==
               {:error, "start_datetime must be a valid ISO-8601 datetime"}
    end

    test "errors when the value is not in an ISO-8601 datetime with timezone format" do
      data = %{@field => "2018-06-01"}

      options = []

      assert Type.DateTime.validate_field(@field, data, options) ==
               {:error, "start_datetime must be a valid ISO-8601 datetime"}
    end

    test "does not error if the field is not provided and not required" do
      field = "id"
      data = %{}
      options = [required: false]
      assert Type.DateTime.validate_field(field, data, options) == {:ok, data}
    end
  end
end
