defmodule Joi.Support.Util do
  defdelegate all_types, to: Joi.Util

  defdelegate types_by(validator), to: Joi.Util

  defdelegate atom_type_to_mod(atom), to: Joi.Util
end

