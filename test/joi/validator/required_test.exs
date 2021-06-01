defmodule Joi.Validator.RequiredTest do
  use ExUnit.Case, async: true

  import Joi.Support.Util, only: [all_types: 0]

  @field :field
  describe "required test" do
    for t <- all_types() do
      test "error: with nil field when validate #{t} type" do
        data = %{@field => nil}
        type_module = unquote(t) |> Atom.to_string() |> Macro.camelize()
        module = Module.safe_concat([Joi.Type, type_module])
        assert {:error, error} = apply(module, :validate_field, [@field, data, []])
        assert error.type == "#{unquote(t)}.required"
      end
    end
  end
end

