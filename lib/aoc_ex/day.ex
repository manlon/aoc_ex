defmodule AocEx.Day do
  defmacro __using__(opts) do
    day =
      case Keyword.get(opts, :day, nil) do
        day when is_integer(day) -> day
        _ -> raise "using Day module should pass a day number option"
      end

    year =
      case Keyword.get(opts, :year, nil) do
        year when is_integer(year) -> year
        _ -> raise "using Day module should pass a year number option"
      end

    module_num = String.pad_leading(Integer.to_string(day), 2, "0")

    [
      quote do
        import AocEx.Combos
        def solve, do: {solve1(), solve2()}

        def solve_timed do
          {t1, s1} = :timer.tc(&solve1/0)
          {t2, s2} = :timer.tc(&solve2/0)
          {{s1, t1 / 1000}, {s2, t2 / 1000}}
        end

        def input_file do
          "input/#{unquote(year)}/input#{unquote(module_num)}.txt"
        end

        def input do
          File.read!(input_file())
          |> String.trim("\n")
        end

        def input_lines(input \\ nil) do
          (input || input())
          |> String.split("\n")
        end

        def input_ints do
          input_lines()
          |> Enum.map(&String.to_integer/1)
        end

        def input_tokens do
          input_lines()
          |> Enum.map(&String.split/1)
        end

        def comma_int_list(s) do
          String.trim(s)
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
        end

        def input_comma_ints do
          input()
          |> comma_int_list()
        end

        def input_map_with_size(input \\ nil) do
          (input || input())
          |> String.split("\n")
          |> Enum.map(fn line ->
            String.graphemes(line)
          end)
          |> Enum.with_index()
          |> Enum.reduce({%{}, {0, 0}}, fn {line, lineno}, {map, maxkey} ->
            Enum.reduce(Enum.with_index(line), {map, maxkey}, fn {val, colno}, {map, maxkey} ->
              map = Map.put(map, {lineno, colno}, val)
              maxkey = Enum.max([maxkey, {lineno, colno}])
              {map, maxkey}
            end)
          end)
        end

        def input_int_map_with_size(input \\ nil) do
          {map, size} = input_map_with_size(input)

          map =
            Enum.map(map, fn {pos, char} ->
              {pos, String.to_integer(char)}
            end)
            |> Map.new()

          {map, size}
        end

        def input_char_map_with_size(input \\ nil) do
          {map, size} = input_map_with_size(input)

          map =
            Enum.map(map, fn {pos, char} ->
              {pos, hd(String.to_charlist(char))}
            end)
            |> Map.new()

          {map, size}
        end

        def input_int_map(input \\ nil) do
          {map, _} = input_int_map_with_size(input)
          map
        end

        def input_line_ints(input \\ nil) do
          input_lines(input)
          |> Enum.map(&line_ints/1)
        end

        def stanzas(input \\ nil) do
          (input || input())
          |> String.split("\n\n")
        end

        def stanza_lines(opts \\ []) do
          input = opts[:input]
          mapper = opts[:map] || (& &1)

          stanzas(input)
          |> Enum.map(&Enum.map(String.split(&1, "\n"), mapper))
        end

        def line_ints(line) do
          String.split(line, [" ", ",", "=", ":", "x", "[", "]", "{", "}"])
          |> Enum.map(&Integer.parse/1)
          |> Enum.filter(fn i -> i != :error end)
          |> Enum.map(fn {i, _} -> i end)
        end

        def four_neighbors({r, c}) do
          [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
          |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
        end

        def eight_neighbors({r, c}) do
          [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
          |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
        end

        def print_coord_map(map) do
          kk = Map.keys(map)
          maxx = Enum.max(for {x, y} <- kk, do: x)
          maxy = Enum.max(for {x, y} <- kk, do: y)

          for y <- 0..maxy do
            for x <- 0..maxx do
              Map.get(map, {x, y}, " ")
            end
            |> Enum.join()
          end
          |> Enum.join("\n")
          |> IO.puts()
        end

        def print_row_col_map(map) do
          row_col_map_to_s(map)
          |> IO.puts()
        end

        def row_col_map_to_s(map) do
          kk = Map.keys(map)
          maxx = Enum.max(for {x, y} <- kk, do: x)
          maxy = Enum.max(for {x, y} <- kk, do: y)
          minx = Enum.min(for {x, y} <- kk, do: x)
          miny = Enum.min(for {x, y} <- kk, do: y)

          for x <- minx..maxx do
            for y <- miny..maxy do
              Map.get(map, {x, y}, " ")
            end
            |> Enum.join()
          end
          |> Enum.join("\n")
        end
      end
    ]
  end

  def input_file_name(year, day) do
    "input/#{year}/input#{String.pad_leading(Integer.to_string(day), 2, "0")}.txt"
  end

  def input_file_contents(year, day) do
    File.read!(input_file_name(year, day))
    |> String.trim("\n")
  end
end
