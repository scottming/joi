defmodule Joi.Type.UnknownTypeTest do
  use ExUnit.Case, async: true

  test "unknown type" do
    data = %{id: 1}
    schema = %{id: [:int]}
    assert Joi.validate(data, schema) == {:error, ["unknown type: #{:int}"]}
  end
end
