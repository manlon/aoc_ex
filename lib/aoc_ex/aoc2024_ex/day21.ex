defmodule AocEx.Aoc2024Ex.Day21 do
  @input """
  279A
  286A
  508A
  463A
  246A
  """

  def input do
    @input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [[num]] = Regex.scan(~r/^\d+/, line)
      {line, String.to_integer(num)}
    end)
  end

  @dirneighbs %{
    "A" => [{"<", "^"}, {"v", ">"}],
    "^" => [{">", "A"}, {"v", "v"}],
    ">" => [{"^", "A"}, {"<", "v"}],
    "v" => [{"<", "<"}, {"^", "^"}, {">", ">"}],
    "<" => [{">", "v"}]
  }

  @numneighbs %{
    "A" => [{"<", "0"}, {"^", "3"}],
    "0" => [{">", "A"}, {"^", "2"}],
    "1" => [{">", "2"}, {"^", "4"}],
    "2" => [{"<", "1"}, {">", "3"}, {"^", "5"}, {"v", "0"}],
    "3" => [{"<", "2"}, {"^", "6"}, {"v", "A"}],
    "4" => [{"v", "1"}, {">", "5"}, {"^", "7"}],
    "5" => [{"v", "2"}, {"<", "4"}, {">", "6"}, {"^", "8"}],
    "6" => [{"v", "3"}, {"<", "5"}, {"^", "9"}],
    "7" => [{"v", "4"}, {">", "8"}],
    "8" => [{"v", "5"}, {"<", "7"}, {">", "9"}],
    "9" => [{"v", "6"}, {"<", "8"}]
  }

  def keypad_paths(map, to, paths) do
    newpaths =
      for path <- paths,
          [{_lastdir, lastnum} | _rest] = path,
          nn = map[lastnum],
          move <- nn,
          {_dir, num} = move,
          prevnums = Enum.map(path, fn {_d, n} -> n end),
          num not in prevnums do
        [move | path]
      end

    case Enum.filter(newpaths, fn [{_dir, num} | _] -> num == to end) do
      [] ->
        keypad_paths(map, to, newpaths)

      paths ->
        paths
        |> Enum.map(fn path ->
          Enum.reverse(path)
          |> Enum.map(fn {dir, _num} -> dir end)
          |> Enum.join()
        end)
    end
  end

  def all_pair_paths(map) do
    for {num1, _} <- map,
        {num2, _} <- map,
        reduce: %{} do
      acc ->
        if num1 == num2 do
          Map.put(acc, {num1, num2}, [""])
        else
          Map.put(acc, {num1, num2}, keypad_paths(map, num2, [[{nil, num1}]]))
        end
    end
  end

  def numpad_paths, do: all_pair_paths(@numneighbs)
  def dirpad_paths, do: all_pair_paths(@dirneighbs)

  def possible_expansions(seg, routes) do
    ("A" <> seg <> "A")
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [n1, n2] -> routes[{n1, n2}] end)
  end

  def best_expansion(segment_expansion_sets, n, routes, memo) do
    for segment_choices <- segment_expansion_sets, reduce: {0, memo} do
      {acc, memo} ->
        {c, memo} =
          for segment <- segment_choices, reduce: {:inf, memo} do
            {minc, memo} ->
              {c, memo} = expand_segment(segment, n, memo, routes)
              minc = min(c, minc)
              {minc, memo}
          end

        {acc + c, memo}
    end
  end

  def expand_segment(seg, n, memo, _) when is_map_key(memo, {seg, n}) do
    {memo[{seg, n}], memo}
  end

  def expand_segment(seg, 0, memo, _) do
    c = String.length(seg) + 1
    {c, Map.put(memo, {seg, 0}, c)}
  end

  def expand_segment(seg, n, memo, routes) do
    expansions = possible_expansions(seg, routes)
    {c, memo} = best_expansion(expansions, n - 1, routes, memo)
    {c, Map.put(memo, {seg, n}, c)}
  end

  def presses(num_levels) do
    {c, _memo} =
      input()
      |> Enum.reduce({0, %{}}, fn {s, n}, {acc, memo} ->
        [seg, ""] = String.split(s, "A")
        numpad_expansions = possible_expansions(seg, numpad_paths())
        {c, memo} = best_expansion(numpad_expansions, num_levels, dirpad_paths(), memo)
        {acc + c * n, memo}
      end)

    c
  end

  def solve1, do: presses(2)
  def solve2, do: presses(25)
end
