# Joi

[![Hex.pm](https://img.shields.io/hexpm/v/joi.svg)](https://hex.pm/packages/joi)
[![Build Docs](https://img.shields.io/badge/hexdocs-release-blue.svg)](https://hexdocs.pm/joi/readme.html)
[![Build Status](https://travis-ci.com/scottming/joi.svg?branch=master)](https://travis-ci.com/scottming/joi)


This project is inspired by [sideway/joi](https://github.com/sideway/joi) and [lob/litmus](https://github.com/lob/litmus).

And the code of this repository is based on [lob/litmus](https://github.com/lob/litmus), but the API of this repository is completely different from litmus.

<!-- MDOC !-->

## Background

The community already has a lot of verification-related libraries, such as skooma, vex, but why write a new one?

The api of vex is very much like Rails ActiveModel Validations, and it feels too complex for me, especially when it comes to customizing some validation modules, which is not convenient and flexible enough. Skooma, on the other hand, is very flexible and I find it particularly useful when validating non-map data structures.

So the **goal** of this repository is:

1. Support most of the types supported by the native [sideway/joi](https://github.com/sideway/joi)
2. Nested validation support.
3. Easy internationalization
4. Easy to extend

## Installation

```elixir
def deps do
  [
    {:joi, "~> 0.1.4"},
  ]
end
```

## Usage

Joi validates data against a predefined schema with the `Joi.validate/2` function.

If the data is valid, the function returns `{:ok, data}`. The returned data will perform the transformation according to the provided schema.

if the passed data does not match the type defined in the schema, the function returns `{:error, errors}`, the `errors` is a list of `Joi.Error`, that a struct contains four fields: 

* `context`: map providing context of the error containing:
  + `key`: key of the value that erred, equivalent to the last element of path.
  + `value`: the value that failed validation.
  + other error specific properties as described for each error code.
* `message`: string with a description of the error.
* `path`: list where each element is the accessor to the value where the error happened.
* `type`: type of the error.
  
, When a field is received that is not specified in the provided schema, it does nothing and returns `{:ok, data}`.

```elixir

Examples:

  iex> schema = %{a: [:integer]}
  %{a: [:integer]}
  iex> data1 = %{a: 1}
  %{a: 1}
  iex> Joi.validate(data1, schema)
  {:ok, %{a: 1}}
  iex> data2 = %{a: <<123>>}
  iex> Joi.validate(data2, schema)
  {:error,
  [
    %Joi.Error{
      context: %{key: :a, value: "{"},
      message: "a must be a integer",
      path: [:a],
      type: "integer.base"
    }
  ]}

```

### Supported Types

* [`atom`](#Atom)
* [`boolean`](#Boolean)
* [`date`](#Date)
* [`datetime`](#Datetime)
* [`decimal`](#Decimal)
* [`float`](#Float)
* [`integer`](#Integer)
* [`list`](#List)
* [`map`](#Map)
* [`string`](#String)

#### Atom

error types

* `atom.base`
* `atom.inclusion`

  Additional local context properties:

  ```elixir
  %{inclusion: list()}
  ```
* `atom.required`

#### Boolean

error types

* `boolean.base`
* `boolean.required`

#### Date

error types

* `date.base`
* `date.required`

#### Datetime

error types

* `datetime.base`
* `datetime.required`

#### Decimal

error types

* `decimal.base`
* `decimal.inclusion`

  Additional local context properties:

  ```elixir
  %{inclusion: list()}
  ```
* `decimal.max`

  Additional local context properties:

  ```elixir
  %{limit: float() | interger()}
  ```

* `decimal.min`

  Additional local context properties:

  ```elixir
  %{limit: float() | interger()}
  ```
* `decimal.required`

#### Float

error types

* `float.base`
* `float.inclusion`

  Additional local context properties:

  ```elixir
  %{inclusion: list()}
  ```
* `float.max`

  Additional local context properties:

  ```elixir
  %{limit: float() | interger()}
  ```
* `float.min`

  Additional local context properties:

  ```elixir
  %{limit: float() | interger()}
  ```
* `float.required`

#### Integer

error types

* `integer.base`
* `integer.inclusion`

  Additional local context properties:

  ```elixir
  %{inclusion: list()}
  ```
* `integer.max`
  Additional local context properties:

  ```elixir
  %{limit: interger()}
  ```
* `integer.min`
  Additional local context properties:

  ```elixir
  %{limit: interger()}
  ```
* `integer.required`

#### List

error types

* `list.base`
* `list.length`
  Additional local context properties:

  ```elixir
  %{limit: interger()}
  ```
* `list.max_length`

Additional local context properties:
```elixir
%{limit: interger()}
```

* `list.min_length`

Additional local context properties:
```elixir
%{limit: interger()}
```
* `list.required`
* `list.schema`
* `list.type`

#### Map

error types

* `map.base`
* `map.required`

#### String

error types

* `string.base`
* `string.format`
* `string.inclusion`
  Additional local context properties:

  ```elixir
  %{inclusion: list()}
  ```
* `string.length`

  Additional local context properties:
  ```elixir
  %{limit: interger()}
  ```
* `string.max_length`

  Additional local context properties:
  ```elixir
  %{limit: interger()}
  ```
* `string.min_length`

  Additional local context properties:
  ```elixir
  %{limit: interger()}
  ```
* `string.required`
* `string.uuid`


### Custom functions

There is nothing magical about custom functions, you just need to return the same format as Joi's type, and then use `:f` as the key for the custom function in the schema, so you can use one or more custom functions inside a type.

```elixir
func = fn field, data -> 
  case data[field] == 1 do
    true -> {:ok, data}
    false -> {
      :error, 
      %{type: "custom", field: field, message: "does not match the custom function", constraint: "custom"}
    }
  end
end

schema = %{id: [:number, f: func]}
data = %{id: 2}
Joi.validate(data, schema)
# {:error,
# [
#   %{
#     constraint: "custom",
#     field: :id,
#     message: "does not match the custom function",
#     type: "custom"
#   }
# ]}
```


## Contributing

Feel free to dive in! [Open an issue](https://github.com/scottming/joi/issues/new) or submit PRS.

Joi follows the [Contributor Covenant](https://www.contributor-covenant.org/version/1/3/0/code-of-conduct/) Code of Conduct.
