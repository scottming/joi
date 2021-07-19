defmodule JoiTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest Joi, import: true
end

