defmodule Joi.Validator.Inclusion do
  import Joi.Util

  def validate_field(type, field, params, %{inclusion: inclusion}) do
    case params[field] in inclusion do
      true ->
        {:ok, params}

      false ->
        error_message(
          field,
          params,
          "must be one of #{inspect(inclusion)}",
          "#{type}.inclusion",
          inclusion
        )
    end
  end

  def validate_field(_type, _field, params, _) do
    {:ok, params}
  end
end
