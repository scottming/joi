defmodule Joi.Support.Properties.Generators do
  @moduledoc """
  A module extend the StreamData generators.
  """
  import StreamData

  defmacro __using__(_opts) do
    quote do
      import Joi.Support.Properties.Generators
    end
  end

  def decimal() do
    [map(integer(), &Decimal.new/1), map(float(), &Decimal.from_float/1)] |> one_of()
  end

  def float_string() do
    map(float(), &Float.to_string/1)
  end

  def integer_string() do
    map(integer(), &Integer.to_string/1)
  end
end
