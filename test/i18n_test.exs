defmodule I18nTest do
  use ExUnit.Case
  doctest I18n

  defmodule Translator do
    use I18n 

    locale "en", [
      name: "name",
      flash: [
        notice: [
          alert: "Alert!",
          hello: "Hello %{first} %{last}!",
          bye: [
            zero:   "Cya!",
            one:    "Cya, buddy!",
            other:  "Cya, guys!",    
          ]
        ]
      ],
      users: [
        title: "Users",
        profile: [
          title: "Profiles",
        ] 
      ]
    ]

    locale "es", [
      name: "nombre", 
      flash: [
        notice: [
          alert: "Alarma!",
          hello: "Hola %{first} %{last}!",
        ]
      ]
    ]
  end

  describe "Integration tests" do
    test "it recursively walks translations tree" do
      assert Translator.t("en", "flash.notice.alert")   == "Alert!"
      assert Translator.t("en", "users.title")          == "Users"
      assert Translator.t("en", "users.profile.title")  == "Profiles"
    end

    test "it handles translations at root level" do
      assert Translator.t("en", "name") == "name"
    end

    test "it allows multiple locales to be registered" do
      assert Translator.t("es", "flash.notice.alert") == "Alarma!"
      assert Translator.t("en", "flash.notice.alert") == "Alert!"
    end

    test "it interpolates bindings" do
      assert Translator.t("en", "flash.notice.hello", first: "Han", last: "Solo") == "Hello Han Solo!"
    end

    test "t/3 raises KeyError when bindings not provided" do
      assert_raise KeyError, fn -> Translator.t("en", "flash.notice.hello") end
    end

    test "t/3 returns {:error, :no_translation} when translation is missing" do
      assert Translator.t("en", "flash.not_exists") == {:error, :no_translation}
    end

    test "convert interpolation values to string" do
      assert Translator.t("es", "flash.notice.hello", first: 42, last: 1337) == "Hola 42 1337!" 
    end

    test "it allows pluralization" do
      assert Translator.t("en", "flash.notice.bye", count: 0)  == "Cya!"
      assert Translator.t("en", "flash.notice.bye", count: 1)  == "Cya, buddy!"
      assert Translator.t("en", "flash.notice.bye", count: 42) == "Cya, guys!"
    end
  end

  describe "Unit tests" do
    test "compile/1 generates catch-all t/3 functions" do
      assert I18n.compile([]) |> Macro.to_string == String.strip ~S"""
      (
        def(t(locale, path, bindings \\ [count: 1]))
        []
        def(t(_locale, _path, _bindings)) do
          {:error, :no_translation}
        end
      )
      """
    end

    test "compile/1 generates t/3 functions from each locale" do
      assert I18n.compile([{"en", [foo: "bar", bar: "%{baz}"]}]) |> Macro.to_string == String.strip ~S"""
      (
        def(t(locale, path, bindings \\ [count: 1]))
        [[def(t("en", "foo", bindings)) do
          "" <> "bar"
        end, def(t("en", "bar", bindings)) do
          ("" <> to_string(Keyword.fetch!(bindings, :baz))) <> ""
        end]]
        def(t(_locale, _path, _bindings)) do
          {:error, :no_translation}
        end
      )
      """
    end
  end
end
