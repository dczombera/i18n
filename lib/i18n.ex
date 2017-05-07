defmodule I18n do
  @moduledoc """
  Internationalization library that supports mutlple locals. 
  """

  defmacro __using__(_options) do
    quote location: :keep do
      Module.register_attribute __MODULE__, :locales, accumulate: true, persist: false
      import unquote(__MODULE__), only: [locale: 2]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :locales)) 
  end

  defmacro locale(name, mappings) do
    quote bind_quoted: [name: name, mappings: mappings] do
      @locales {name, mappings}
    end
  end

  def compile(translations) do
    translation_ast = for {locale, mappings} <- translations do
      deftranslations(locale, "", mappings)
    end
 
    quote do
      def t(locale, path, bindings \\ [count: 1]) 
      unquote(translation_ast)
      def t(_locale, _path, _bindings), do: {:error, :no_translation}
    end
  end

  defp deftranslations(locale, current_path, mappings) do
    for {key, val} <- mappings do
      path = append_path(current_path, key)
      cond do
        Keyword.keyword?(val) -> 
          deftranslations(locale, path, val)
        key == :zero ->
          quote do
            def t(unquote(locale), unquote(current_path), [{:count, 0} | bindings]) do
              unquote(interpolate(val)) 
            end
          end

        key == :one ->
          quote do
            def t(unquote(locale), unquote(current_path), [{:count, n} | bindings]) when n <= 1 do
              unquote(interpolate(val)) 
            end
          end

        key == :other ->
          quote do
            def t(unquote(locale), unquote(current_path), [{:count, n} | bindings]) when n > 1 do
              unquote(interpolate(val)) 
            end
          end

        true ->
          quote do
            def t(unquote(locale), unquote(path), bindings) do
              unquote(interpolate(val))
            end
          end
      end
    end
  end

  defp interpolate(string) do
    ~r/(?<head>)%{[^}]+}(?<tail>)/
    |> Regex.split(string, on: [:head, :tail])
    |> Enum.reduce("", fn
      <<"%{" <> rest>>, acc ->
        key = String.to_atom(String.trim_trailing(rest, "}"))
        quote do
          unquote(acc) <> to_string(Keyword.fetch!(bindings, unquote(key)))
        end
      segment, acc -> quote do: (unquote(acc) <> unquote(segment))
    end)
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"
end
