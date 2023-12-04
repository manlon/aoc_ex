defmodule Aoc2023Ex.Parser do
  defmodule ParseHelp do
    import NimbleParsec

    def ispace(), do: ignore(times(string(" "), min: 1))
    def ispace(a), do: a |> ignore(times(string(" "), min: 1))
    def istr(s), do: ignore(string(s))
    def istr(a, s), do: a |> ignore(string(s))

    defmacro defmatch(name, comb, opts \\ []) do
      quote do
        defparsec(unquote(name), unquote(comb), unquote(opts))

        def unquote(:"#{name}_match")(s) do
          {:ok, match, _, _, _, _} = unquote(name)(s)
          match
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import NimbleParsec
      import Aoc2023Ex.Parser.ParseHelp
    end
  end
end
