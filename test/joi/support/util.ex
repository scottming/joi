defmodule Joi.Support.Util do
  def error_messages(schema, field, data, message, child_key) do
    field_schema = Map.get(schema, field)
    [h | options] = field_schema
    constraint = Keyword.get(options, child_key)

    constraint =
      if is_atom(constraint) and not is_boolean(constraint),
        do: Atom.to_string(constraint),
        else: constraint

    type = Atom.to_string(h) <> "." <> Atom.to_string(child_key)

    {:error, [%{field: field, value: data[field], message: message, type: type, constraint: constraint}]}
  end

  def error_messages(schema, field, data, message) do
    field_schema = Map.get(schema, field)
    [h | _options] = field_schema
    type = Atom.to_string(h)

    {:error, [%{field: field, value: data[field], message: message, type: type, constraint: type}]}
  end

  def all_types() do
    with {:ok, list} <- :application.get_key(:joi, :modules) do
      list
      |> Enum.filter(fn x ->
        module_list = x |> Module.split()

        # TODO: delete map when implemented
        Enum.slice(module_list, 0..1) == ~w|Joi Type| &&
          module_list not in [~w|Joi Type|, ~w|Joi Util|] &&
          module_list != ~w|Joi Type Map|
      end)
      |> Enum.map(&(&1 |> Module.split() |> List.last() |> String.downcase() |> String.to_atom()))
    end
  end
end

