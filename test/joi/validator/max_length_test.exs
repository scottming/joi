defmodule Joi.Validator.MaxLengthTest do
  @moduledoc false

  use ExUnit.Case, async: true
  import Joi.Support.Util

  @field :field
  @max_length 3

  describe "validate max_length" do
    for t <- types_by("max_length") do
      test "error: when type is #{t}, max_length is #{@max_length}" do
        data = %{@field => 1234}
        type_module = Module.safe_concat(Joi.Type, unquote(t) |> atom_type_to_mod())
        assert {:error, _} = apply(type_module, :validate_field, [@field, data, [max_length: @max_length]])
      end
    end
  end
end

