defmodule Joi.Validator.InclusionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Joi.Support.Util
  import Assertions

  @field :field
  @inclusion [:fake_inclusion]
  @validator :inclusion

  test "types that support #{@validator}" do
    assert_lists_equal(types_by(@validator), [:atom, :string, :integer, :float])
  end

  describe "validate inclusion" do
    for t <- types_by("inclusion") do
      test "error: when type is #{t}, inclusion is #{inspect(@inclusion)}" do
        data = %{@field => 1}
        type_module = atom_type_to_mod(unquote(t))
        assert {:error, _} = apply(type_module, :validate_field, [@field, data, [inclusion: @inclusion]])
      end
    end
  end
end

