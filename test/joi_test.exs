defmodule JoiTest do
  use ExUnit.Case, async: true
  doctest Joi

  alias Joi.Type

  describe "validate/2" do
    test "validates data according to a schema" do
    end

    test "errors when a disallowed parameter is passed" do
    end
  end
end
