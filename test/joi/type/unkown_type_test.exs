defmodule Joi.Type.UnknownTypeTest do
  use ExUnit.Case, async: true

  test "unknown type" do
    data = %{id: 1}
    schema = %{id: [:int]}
    assert_raise RuntimeError, "unknown type: #{:int}", fn -> Joi.validate(data, schema) end
  end
end

