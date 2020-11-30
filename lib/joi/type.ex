defprotocol Joi.Type do
  @moduledoc false

  alias Joi.Type

  @type t ::
          Type.Any.t()
          | Type.Boolean.t()
          | Type.DateTime.t()
          | Type.List.t()
          | Type.Number.t()
          | Type.String.t()

  @spec validate(t(), term, map) :: {:ok, map} | {:error, String.t()}
  def validate(type, field, data)
end
