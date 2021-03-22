defmodule Joi.Type.AtomTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import Joi.Type.Atom

  @field :field

  property "check all input will convert to an atom" do
    check all value <- random_value(),
              data = %{@field => value} do
      assert {:ok, result} = validate_field(@field, data, [])
      assert is_value_atom?(result)
    end
  end

  describe "Joi.validate/2" do
    test "success: with valid attrs" do
      data = %{@field => "atom"}
      expected = %{@field => :atom}
      schema = %{@field => [:atom]}

      assert {:ok, expected} == Joi.validate(data, schema)
    end

    test "error: with invalid attrs" do
      data = %{@field => []}
      schema = %{@field => [:atom]}
      assert {:error, _} = Joi.validate(data, schema)
    end
  end

  defp random_value() do
    [string(:alphanumeric), integer(), boolean(), float(), atom(:alphanumeric)] |> one_of()
  end

  defp is_value_atom?(map) when is_map(map) do
    value = Map.get(map, @field)
    is_atom(value)
  end
end
