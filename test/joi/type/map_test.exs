# defmodule Joi.Type.MapTest do
#   use ExUnit.Case, async: true

#   describe "validate nested types" do
#     test "success: when validate without converting" do
#       raw_data = %{m: %{id: 1}}
#       sub_schema = %{id: [:number, max: 3]}
#       schema = %{m: [:map, schema: sub_schema]}

#       assert {:ok, data} = Joi.validate(raw_data, schema)
#       assert data == raw_data
#     end

#     test "success: validate and convert" do
#       raw_data = %{m: %{id: "1"}}
#       expected_data = %{m: %{id: 1}}

#       sub_schema = %{id: [:number, max: 3, integer: true]}
#       schema = %{m: [:map, schema: sub_schema]}
#       assert {:ok, data} = Joi.validate(raw_data, schema)
#       assert data == expected_data
#     end

#     test "success: validate when not required" do
#       raw_data = %{m: %{i: "1"}}

#       sub_schema = %{id: [:number, max: 3, integer: true]}
#       schema = %{m: [:map, required: false, schema: sub_schema]}
#       assert {:ok, data} = Joi.validate(raw_data, schema)
#       assert data == raw_data
#     end

#     test "error: validate when failed" do
#       raw_data = %{m: %{id: 4}}
#       sub_schema = %{id: [:number, max: 3]}
#       schema = %{m: [:map, schema: sub_schema]}
#       assert {:error, messages} = Joi.validate(raw_data, schema)

#       # TODO: nested errors must have a path field
#       assert messages == [
#                [
#                  %{
#                    constraint: 3,
#                    field: :id,
#                    value: raw_data[:id],
#                    message: "id must be less than or equal to 3",
#                    type: "number.max"
#                  }
#                ]
#              ]

#       non_nested_data = %{id: 4}
#       assert {:error, messages} = Joi.validate(non_nested_data, sub_schema)

#       assert messages ==
#                [
#                  %{
#                    constraint: 3,
#                    field: :id,
#                    value: raw_data[:id],
#                    message: "id must be less than or equal to 3",
#                    type: "number.max"
#                  }
#                ]
#     end
#   end
# end
