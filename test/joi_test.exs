defmodule JoiTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "required test" do
    @field :field
    test "errors: with nil field when field required" do
      for t <- all_types() do
        schema = %{@field => [t]}
        data = %{@field => nil}
        assert {:error, [%{type: type}]} = Joi.validate(data, schema)
        assert type == "#{t}.required"
      end
    end
  end

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

  def all_types() do
    with {:ok, list} <- :application.get_key(:joi, :modules) do
      list
      |> Enum.filter(fn x ->
        module_list = x |> Module.split()

        # TODO: delete map when implemented
        Enum.slice(module_list, 0..1) == ~w|Joi Type| &&
          module_list not in [~w|Joi Type|, ~w|Joi Util|] &&
          module_list != ~w|Joi Type Map|
      end)
      |> Enum.map(&(&1 |> Module.split() |> List.last() |> String.downcase() |> String.to_atom()))
    end
  end
end
