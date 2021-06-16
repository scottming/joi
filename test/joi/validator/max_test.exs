defmodule Joi.Validator.MaxTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "max/min validation" do
    @field :field
    @types [:integer, :float, :decimal]

    property "success: with valid attrs when validate max" do
      check all value <- integer(), type <- member_of(@types), value <= 100 do
        schema = %{@field => [type, max: 100]}
        data = %{@field => value}
        assert {:ok, _} = Joi.validate(data, schema)
      end
    end

    property "errors: with invalid attrs when validate max" do
      check all value <- integer(), type <- member_of(@types), value > -100 do
        schema = %{@field => [type, max: -100]}
        data = %{@field => value}
        assert {:error, _} = Joi.validate(data, schema)
      end
    end

    property "success: with valid attr when validate min" do
      check all value <- positive_integer(), type <- member_of(@types) do
        schema = %{@field => [type, min: 1]}
        data = %{@field => value}
        assert {:ok, _} = Joi.validate(data, schema)
      end
    end

    property "errors: with invalid attr when validate min" do
      check all value <- negative_integer(), type <- member_of(@types) do
        schema = %{@field => [type, min: 0]}
        data = %{@field => value}
        assert {:error, _} = Joi.validate(data, schema)
        # TODO: assert error details
      end
    end

    defp negative_integer() do
      map(positive_integer(), &(&1 / -1))
    end
  end
end
