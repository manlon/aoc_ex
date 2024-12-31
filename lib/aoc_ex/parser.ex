defmodule AocEx.Parser do
  defmodule ParseHelp do
    import NimbleParsec

    def ispace(), do: ignore(times(string(" "), min: 1))
    def ispace(a), do: a |> ignore(times(string(" "), min: 1))
    def istr(s), do: ignore(string(s))
    def istr(a, s), do: a |> ignore(string(s))
    def int(), do: integer(min: 1)
    def int(a), do: a |> integer(min: 1)
    def separated(a, sep), do: repeat(concat(a, sep)) |> concat(a)
    def separated(x, a, sep), do: x |> repeat(concat(a, sep)) |> concat(a)

    defmacro defmatch(name, comb, opts \\ []) do
      quote do
        defparsec(unquote(:"#{name}_parser"), unquote(comb), unquote(opts))

        def unquote(name)(s) do
          {:ok, match, _, _, _, _} = unquote(:"#{name}_parser")(s)
          match
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import NimbleParsec
      import AocEx.Parser.ParseHelp
    end
  end
end
