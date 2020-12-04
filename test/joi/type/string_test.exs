defmodule Joi.Type.StringTest do
  use ExUnit.Case, async: true
  alias Joi.Type
  import Joi.Support.Util

  describe "validate_field/3" do
    test "validates property values of data based on their String schema definition in Type.String module" do
      field = :id
      data = %{id: "1"}
      options = []

      assert Type.String.validate_field(field, data, options) == {:ok, data}
    end
  end

  describe "minimum length validation" do
    test "returns :ok when length of field is more than or equal to min_length" do
      min_length = 3
      data = %{id: "abc"}

      schema = %{
        id: [:string, min_length: min_length]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is nil and min_length is 0" do
      data = %{id: nil}

      schema = %{
        id: [:string, min_length: 0, required: false]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is an empty string and min_length is 0" do
      data = %{id: ""}

      schema = %{
        id: [:string, min_length: 0, required: true]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when length of field is less than min_length" do
      min_length = 3
      field = :id
      data = %{id: "ab"}

      schema = %{
        id: [:string, min_length: min_length]
      }

      assert Joi.validate(data, schema) ==
               error_messages(
                 schema,
                 field,
                 "#{field} length must be greater than or equal to #{min_length} characters",
                 :min_length
               )
    end

    test "errors when value is blank and min_length is greater than 0" do
      min_length = 3
      field = :id
      data = %{id: ""}

      schema = %{
        id: [:string, min_length: min_length]
      }

      assert Joi.validate(data, schema) ==
               error_messages(
                 schema,
                 field,
                 "#{field} length must be greater than or equal to #{min_length} characters",
                 :min_length
               )
    end

    test "does not error if the field is not provided and not required" do
      field = :id
      data = %{id: nil}

      schema = %{id: [:string, min_length: 3, required: false]}
      [_ | options] = schema[field]

      assert Type.String.validate_field(field, data, options) == {:ok, data}
    end
  end

  describe "maximum length validation" do
    test "returns :ok when length of field is less than or equal to max_length" do
      max_length = 3
      data = %{id: "ab"}

      schema = %{
        id: [:string, required: true, max_length: max_length]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is nil" do
      data = %{id: nil}

      schema = %{
        id: [:string, max_length: 10, required: false]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is nil and the max length is 0" do
      data = %{id: nil}

      schema = %{
        id: [:string, max_length: 0, required: false]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is an empty string and the max length is 0" do
      data = %{id: ""}

      schema = %{
        id: [:string, max_length: 0, required: true]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when length of field is more than max_length" do
      max_length = 3
      field = :id
      data = %{id: "abcd"}

      schema = %{
        id: [:string, max_length: max_length]
      }

      assert Joi.validate(data, schema) ==
               error_messages(
                 schema,
                 field,
                 "#{field} length must be less than or equal to #{max_length} characters",
                 :max_length
               )
    end

    test "errors when length is more than 255" do
      field = :desc
      data = %{desc: string_of_length(256)}
      schema = %{desc: [:string]}
      max_length = 255

      # the default options is [max_length: 255]
      merged_schema = %{desc: [:string, max_length: 255]}

      assert Joi.validate(data, schema) ==
               error_messages(
                 merged_schema,
                 field,
                 "#{field} length must be less than or equal to #{max_length} characters",
                 :max_length
               )
    end
  end

  describe "exact length validation" do
    test "returns :ok when length of field is equal to length" do
      length = 3
      data = %{id: "abc"}

      schema = %{
        id: [:string, required: true, length: length]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is an empty string and the length is 0" do
      length = 0
      data = %{id: ""}

      schema = %{
        id: [:string, length: length]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "returns :ok when the value is nil and the length is 0" do
      length = 0
      data = %{id: nil}

      schema = %{
        id: [:string, length: length, required: false]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors when length of field is not equal to length" do
      length = 3
      field = :id
      data = %{id: "abcd"}

      schema = %{
        id: [:string, required: true, length: length]
      }

      assert Joi.validate(data, schema) ==
               error_messages(
                 schema,
                 field,
                 "#{field} length must be #{length} characters",
                 :length
               )
    end

    test "errors when the value is blank and length is greater than 0" do
      length = 3
      field = :id
      data = %{id: ""}

      schema = %{
        id: [:string, length: length]
      }

      assert Joi.validate(data, schema) ==
               error_messages(
                 schema,
                 field,
                 "#{field} length must be #{length} characters",
                 :length
               )
    end

    test "errors when the length is 0 and the value is not empty or nil" do
      # TODO: I think that's is not necessary when length is 0
      # length = 0
      # field = :id
      # data = %{id: "a"}

      # schema = %{
      #   id: [:string, length: length]
      # }

      # assert Joi.validate(data, schema) ==
      #          {:error, "#{field} length must be #{length} characters"}
    end
  end

  describe "regex validation" do
    test "returns :ok when value matches the regex pattern" do
      data = %{"username" => "user123"}

      schema = %{
        "username" => [:string, regex: ~r/^[a-zA-Z0-9_]*$/]
      }

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "errors with custom error message when value does not match regex pattern" do
      field = :username
      data = %{:username => "x@##1"}

      schema = %{
        username: [:string, regex: ~r/^[a-zA-Z0-9_]*$/]
      }

      assert Joi.validate(data, schema) ==
               error_messages(schema, field, "#{field} must be in a valid format", :regex)
    end

    test "errors when the value is nil" do
      field = :username
      data = %{:username => ""}

      schema = %{
        field => [:string, regex: ~r/^\d{3,}(?:[-\s]?\d*)?$/]
      }

      assert Joi.validate(data, schema) ==
               error_messages(schema, field, "#{field} must be in a valid format", :regex)
    end
  end

  describe "uuid validation" do
    test "success: when is a valid UUID" do
      data = %{id: UUID.uuid4()}
      schema = %{id: [:string, uuid: true]}

      assert Joi.validate(data, schema) == {:ok, data}
    end

    test "error: when is not a valid UUID" do
      field = :id
      data = %{id: "12345"}
      schema = %{id: [:string, uuid: true]}

      assert Joi.validate(data, schema) ==
               error_messages(schema, field, "#{field} is not a valid uuid", :uuid)
    end
  end

  # describe "trim extra whitespaces" do
  #   test "returns :ok with new parameters having trimmed values when trim is set to true" do
  #     data = %{id: " abc "}
  #     trimmed_data = %{id: "abc"}

  #     schema = %{
  #       id: [:string
  #         trim: true
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, trimmed_data}
  #   end

  #   test "returns :ok with same parameters when trim is set to false" do
  #     data = %{id: " abc "}

  #     schema = %{
  #       id: [:string
  #         trim: false
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, data}
  #   end

  #   test "does not error when the value is nil" do
  #     data = %{id: nil}

  #     schema = %{
  #       id: [:string
  #         trim: true
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, data}
  #   end
  # end

  # describe "replace" do
  #   test "replaces a pattern in a string with a new string" do
  #     data = %{"username" => "user123"}
  #     modified_data = %{"username" => "anonymous"}

  #     schema = %{
  #       "username" => [:string
  #         replace: %Joi.Type.String.Replace{
  #           pattern: ~r/^user[0-9]*$/,
  #           replacement: "anonymous"
  #         }
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, modified_data}
  #   end

  #   test "replaces multiple occurences of a regex within a string" do
  #     data = %{"username" => "user123"}
  #     modified_data = %{"username" => "userXXX"}

  #     schema = %{
  #       "username" => [:string
  #         replace: %Joi.Type.String.Replace{
  #           pattern: ~r/[0-9]/,
  #           replacement: "X"
  #         }
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, modified_data}
  #   end

  #   test "replaces multiple occurences of a string within a string" do
  #     data = %{"username" => "user212"}
  #     modified_data = %{"username" => "userX1X"}

  #     schema = %{
  #       "username" => [:string
  #         replace: %Joi.Type.String.Replace{
  #           pattern: "2",
  #           replacement: "X"
  #         }
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, modified_data}
  #   end

  #   test "replaces a single occurences of a patten when global is false" do
  #     data = %{"username" => "user123"}
  #     modified_data = %{"username" => "userX23"}

  #     schema = %{
  #       "username" => [:string
  #         replace: %Joi.Type.String.Replace{
  #           pattern: ~r/[0-9]/,
  #           replacement: "X",
  #           global: false
  #         }
  #       }
  #     }

  #     assert Joi.validate(data, schema) == {:ok, modified_data}
  #   end
  # end

  # describe "convert to string" do
  #   test "returns :ok with new parameters having values converted to string when field is boolean or number" do
  #     data = %{id: 1, "new_user" => true}
  #     modified_data = %{id: "1", "new_user" => "true"}

  #     schema = %{
  #       id: [:string},
  #       "new_user" => [:string},
  #       "description" => [:string}
  #     }

  #     assert Joi.validate(data, schema) == {:ok, modified_data}
  #   end

  #   test "does not convert nil to a string" do
  #     data = %{id: nil}

  #     schema = %{
  #       id: [:string}
  #     }

  #     assert Joi.validate(data, schema) == {:ok, data}
  #   end

  #   test "returns :error when field is neither string nor boolean nor number" do
  #     data = %{id: ["1"]}

  #     schema = %{
  #       id: [:string}
  #     }

  #     assert Joi.validate(data, schema) == {:error, "id must be a string"}
  #   end
  # end
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("", trim: true)

  def string_of_length(length) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end
end
