defmodule Joi.Type.AtomTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Joi.Type.Atom

  @t :atom
  @field :field

  property "check all input will convert to an atom" do
    check all value <- random_correct_input(),
              data = %{@field => value} do
      assert {:ok, result} = validate_field(@field, data, [])
      assert is_value_atom?(result)
    end
  end

  property "check all input returns a base error" do
    check all value <- random_incorrect_input(),
              data = %{@field => value} do
      assert {:error, error} = validate_field(@field, data, [])
      assert error.message == "#{@field} must be an #{@t}"
    end
  end

  defp random_correct_input() do
    [string(:alphanumeric), boolean(), atom(:alphanumeric)] |> one_of()
  end

  defp random_incorrect_input() do
    [float(), integer()] |> one_of()
  end

  defp is_value_atom?(map) when is_map(map) do
    value = Map.get(map, @field)
    is_atom(value)
  end
end

