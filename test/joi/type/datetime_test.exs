defmodule Joi.Type.DatetimeTest do
  use ExUnit.Case, async: true

  import Joi.Type.Datetime

  @t :datetime
  @field :field

  @correct_datetime_examples [~U[2021-05-31 06:57:59.330819Z]]

  for i <- @correct_datetime_examples do
    test "success: when input #{i}" do
      data = %{@field => unquote(Macro.escape(i))}
      validate_field(@field, data, [])
    end
  end

  @incorrect_datetime_examples ["1990-05-30", ~D[1990-05-31], 1_622_443_538]

  for i <- @incorrect_datetime_examples do
    test "error: when input #{i}" do
      data = %{@field => unquote(i |> Macro.escape())}
      assert {:error, _} = validate_field(@field, data, [])
    end
  end
end

