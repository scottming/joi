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

    {:error,
     [%{field: field, value: data[field], message: message, type: type, constraint: constraint}]}
  end

  def error_messages(schema, field, data, message) do
    field_schema = Map.get(schema, field)
    [h | _options] = field_schema
    type = Atom.to_string(h)

    {:error,
     [%{field: field, value: data[field], message: message, type: type, constraint: type}]}
  end
end
