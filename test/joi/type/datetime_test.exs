defmodule Joi.Type.DatetimeTest do
  use ExUnit.Case, async: true

  import Joi.Type.Datetime

  @t :datetime
  @field :field

  @correct_datetime_examples [~U[2021-05-31 06:57:59.330819Z], "2021-05-31 06:57:59.330818Z"]

  for i <- @correct_datetime_examples do
    test "success: when input #{i}" do
      data = %{@field => unquote(Macro.escape(i))}
      assert {:ok, result} = validate_field(@field, data, [])
      assert result[@field] in [~U[2021-05-31 06:57:59.330819Z], ~U[2021-05-31 06:57:59.330818Z]]
    end
  end

  @incorrect_datetime_examples ["1990-05-30", ~D[1990-05-31], 1_622_443_538, "2021-05-31 06:57:59"]

  for i <- @incorrect_datetime_examples do
    test "error: when input #{i}" do
      value = unquote(Macro.escape(i))
      data = %{@field => value}
      assert {:error, error} = validate_field(@field, data, [])

      assert error == %Joi.Error{
               context: %{key: @field, value: value},
               message: "#{@field} must be a valid ISO-8601 datetime",
               path: [@field],
               type: "#{@t}.base"
             }
    end
  end
end

