defmodule Joi.Type.DateTest do
  use ExUnit.Case, async: true
  import Joi.Type.Date

  @t :date
  @field :field

  @correct_date_examples ["1990-05-30", ~D[1990-05-31]]

  for i <- @correct_date_examples do
    test "success: when input #{i}" do
      data = %{@field => unquote(i |> Macro.escape())}
      assert {:ok, result} = validate_field(@field, data, [])
      assert result[@field] in [~D[1990-05-31], ~D[1990-05-30]]
    end
  end

  @incorrect_date_examples ["2018-06-01T06:32:00Z", 1_622_443_538, ~U[2021-05-31 06:57:59.330819Z]]

  for i <- @incorrect_date_examples do
    test "error: when input #{i}" do
      value = unquote(Macro.escape(i))
      data = %{@field => value}

      assert {:error, error} = validate_field(@field, data, [])

      assert error == %Joi.Error{
               context: %{key: @field, value: value},
               message: "#{@field} must be a valid ISO-8601 date",
               path: [@field],
               type: "#{@t}.base"
             }
    end
  end
end

