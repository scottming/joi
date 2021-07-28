defmodule Joi.Support.ConvertTestHelper do
  use ExUnitProperties

  defmacro __using__(opts) do
    input = Keyword.fetch!(opts, :input)
    incorrect_input = Keyword.fetch!(opts, :incorrect_input)
    is_converted? = Keyword.fetch!(opts, :is_converted?)

    quote do
      property "check all input will convert to #{@t}" do
        check all value <- unquote(input).(),
                  data = %{@field => value} do
          assert {:ok, result} = validate_field(@field, data, [])
          assert unquote(is_converted?).(result)
        end
      end

      property "check all input returns a base error" do
        check all value <- unquote(incorrect_input).(),
                  data = %{@field => value} do
          assert {:error, error} = validate_field(@field, data, [])
          message = if @t == :atom, do: "#{@field} must be an atom", else: "field must be a #{@t}"

          assert error == %Joi.Error{
                   type: "#{@t}.base",
                   path: [@field],
                   message: message,
                   context: %{key: @field, value: value}
                 }
        end
      end
    end
  end
end

