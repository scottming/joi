defmodule Joi.Validator.InclusionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Joi.Support.Util

  @field :field
  @inclusion [:fake_inclusion]

  describe "validate inclusion" do
    for t <- types_by("inclusion") do
      test "error: when type is #{t}, inclusion is #{inspect(@inclusion)}" do
        type_module = Module.safe_concat(Joi.Type, unquote(t) |> Atom.to_string() |> Macro.camelize())

        data = %{@field => 1}
        assert {:error, _} = apply(type_module, :validate_field, [@field, data, [inclusion: @inclusion]])
      end
    end
  end
end

