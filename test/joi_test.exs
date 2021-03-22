defmodule JoiTest do
  use ExUnit.Case, async: true

  describe "validate inclusion" do
    @field :animal
    @inclusion [:pig, :cow]
    @schema %{@field => [:atom, inclusion: @inclusion]}

    test "success: inclusion" do
      data = %{@field => :pig}
      assert {:ok, _} = Joi.validate(data, @schema)
    end

    test "errors: inclusion" do
      data = %{@field => :cat}

      assert {:error, [%{constraint: constraint, type: type}]} = Joi.validate(data, @schema)

      assert type == "atom.inclusion"
      assert constraint == @inclusion
    end
  end
end
