# I18n
A lightweight internationalization library whose usage is similar to its bigger [Ruby brother](https://github.com/svenfuchs/i18n) (but also much smaller in its scope). 

## Installlation 
This library is not available in [Hex](https://hex.pm/docs/publish) since I'm not planning to maintain it.
However, if you want to use it, you can instead add this repository as your dependecy to your Elixir project:

```elixir
def deps do
  [{:i18n, git: "git://github.com/dczombera/i18n.git"}]
end
```

## Usage
The library takes advantage of Elixir's `use` macro in order to inject the `locale` macro into the caller's module.
The `locale` macro is used to define new locales:
```elixir
  defmodule Translator do
    use I18n 

    locale "en", [
      flash: [
        notice: [
          hello: "Hello %{first} %{last}!",
        ]
      ],
      users: [
        title: [
          one:    "User",
          other:  "Users" 
        ],
      ]
    ]

    locale "es", [
      flash: [
        notice: [
          hello: "Hola %{first} %{last}!",
        ]
      ],
      users: [
        title: [
          one:    "Usuario",
          other:  "Usuarios" 
        ],
      ]
    ]
  end
```
To get the desired translation, the `t/3` function is called, which is injected into the callers module during compile time:

```elixir
iex> Translator.t("en", "flash.notice.hello", first: "Han", last: "Solo")
"Hello Han Solo!"

iex> Translator.t("es", "flash.notice.hello", first: "Han", last: "Solo")
"Hola Han Solo!"
```

The library also supports different versions of a locale depending on the supplied `count` option. 
For instance, in the `Translator` module above a singular as well as a plural version of the user title is defined:
```elixir
iex> Translator.t("en", "users.title")
"User"
iex> Translator.t("en", "users.title", count: 1)
"User"
iex> Translator.t("en", "users.title", count: 2)
"Users"
```
