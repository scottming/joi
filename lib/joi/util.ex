defmodule Joi.Util do
  @types [:boolean, :date, :datetime, :list, :map, :number, :string]
  def error_message(field, params, message, type) do
    {:error,
     %{field: field, value: params[field], message: message, type: type, constraint: type}}
  end

  def error_message(field, params, message, type, constraint) do
    {:error,
     %{field: field, value: params[field], message: message, type: type, constraint: constraint}}
  end

  def is_schema(schema) when is_map(schema) do
    values = Enum.map(schema, fn {_k, v} -> v end)

    all_values_are_list?(values) &&
      all_types_are_validated?(values) &&
      all_tail_options_are_keyword?(values)
  end

  def is_schema(_schema) do
    false
  end

  defp all_values_are_list?(values), do: Enum.all?(values, &is_list/1)

  defp all_types_are_validated?(values), do: Enum.all?(values, &(hd(&1) in @types))

  defp all_tail_options_are_keyword?(values) do
    validations = Enum.map(values, fn [_h | t] -> t end)
    Enum.all?(validations, &Keyword.keyword?/1)
  end

  def string_to_float(str) do
    case Float.parse(str) do
      {num, _} -> num
      _ -> nil
    end
  end
end
