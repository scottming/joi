import Joi.Util


for t <- all_types() do
  module = atom_type_to_mod(t)
  opts = [path: []]
  map = apply(module, :message_map, [opts])

  IO.puts("#### #{t |> Atom.to_string() |> Macro.camelize()}")
  IO.puts("")
  IO.puts("error types")
  IO.puts("")
  for e <- Map.keys(map) do
    IO.puts("* `#{e}`")
  end

  IO.puts("")
end
