defmodule AocEx.Aoc2024Ex.Day21 do
  @input """
  279A
  286A
  508A
  463A
  246A
  """

  @input_ex """
  029A
  980A
  179A
  456A
  379A
  """

  def input do
    # @input_ex
    @input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [[num]] = Regex.scan(~r/^\d+/, line)
      # {String.graphemes(line), String.to_integer(num)}
      {line, String.to_integer(num)}
    end)
  end

  @numpad """
  789
  456
  123
   0A
  """
  @numkeys String.split(@numpad) |> Enum.join() |> String.graphemes()

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

  def find_paths(map, to, paths) do
    newpaths =
      for path <- paths,
          [{lastdir, lastnum} | rest] = path,
          nn = map[lastnum],
          move <- nn,
          {dir, num} = move,
          prevnums = Enum.map(path, fn {d, n} -> n end),
          num not in prevnums do
        [move | path]
      end

    case Enum.filter(newpaths, fn [{_dir, num} | _] -> num == to end) do
      [] ->
        find_paths(map, to, newpaths)

      paths ->
        paths
        |> Enum.map(fn path ->
          Enum.reverse(path)
          |> Enum.map(fn {dir, num} -> dir end)
          |> Enum.join()
        end)
    end
  end

  def all_paths(map) do
    for {num1, _} <- map,
        {num2, _} <- map,
        reduce: %{} do
      acc ->
        if num1 == num2 do
          Map.put(acc, {num1, num2}, [""])
        else
          Map.put(acc, {num1, num2}, find_paths(map, num2, [[{nil, num1}]]))
        end
    end
  end

  def all_num_paths_c, do: all_paths(@numneighbs) |> best_vals()
  def all_dir_paths_c, do: all_paths(@dirneighbs) |> best_vals()

  def expand_segment(seg, expansions) do
    ("A" <> seg <> "A")
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [n1, n2] -> Map.get(expansions, {n1, n2}) end)
  end

  def expand_segment_best(seg, n, expansions, memo) do
    new_segs = expand_segment(seg, expansions)

    {c, memo} =
      for seg_part_choices <- new_segs, reduce: {0, memo} do
        {acc, memo} ->
          {c, memo} =
            for s <- seg_part_choices, reduce: {:inf, memo} do
              {minc, memo} ->
                {c, memo} = expand_segment_n({s, n - 1}, memo, expansions)
                minc = min(c, minc)
                {minc, memo}
            end

          {acc + c, memo}
      end

    {c, Map.put(memo, {seg, n}, c)}
  end

  def expand_segments_n(segs, n, expansions, memo) when is_list(segs) do
    for ss <- segs,
        reduce: {0, memo} do
      {acc, memo} ->
        {c, memo} =
          for s <- ss, reduce: {:inf, memo} do
            {minc, memo} ->
              {c, memo} = expand_segment_n({s, n}, memo, expansions)
              minc = min(c, minc)
              {minc, memo}
          end

        {acc + c, memo}
    end
  end

  def expand_segment_n({seq, n}, memo, expansions) do
    # dbg(on: {seq, n}, mapsize: map_size(memo))

    cond do
      Map.has_key?(memo, {seq, n}) ->
        c = Map.get(memo, {seq, n})
        {c, memo}

      n == 0 ->
        # TODO A accounting
        c = String.length(seq) + 1
        memo = Map.put(memo, {seq, n}, c)
        {c, memo}

      true ->
        {c, memo} = expand_segment_best(seq, n, expansions, memo)
        {c, memo}
    end
  end

  def most_conseq(s) do
    s
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce({0, 0}, fn [a, b], {max, count} ->
      if a == b do
        c = count + 1
        {max(max, c), c}
      else
        {max, 0}
      end
    end)
  end

  def take_shortest(strs) do
    l = Enum.map(strs, &String.length/1) |> Enum.min()
    Enum.filter(strs, fn s -> String.length(s) == l end)
  end

  def take_most_conseq(strs) do
    most =
      Enum.map(strs, &most_conseq/1)
      |> Enum.max()

    Enum.filter(strs, fn s -> most_conseq(s) == most end)
    # |> Enum.take(1)
  end

  def best_vals(map) do
    Enum.into(map, %{}, fn {k, v} -> {k, v} end)
  end

  def solve1 do
    num_paths = all_num_paths_c()
    dir_paths = all_dir_paths_c()

    {c, memo} =
      input()
      |> Enum.reduce({0, %{}}, fn {s, n}, {acc, memo} ->
        [seg, ""] = String.split(s, "A")

        numkeys =
          expand_segment(seg, num_paths)
          |> dbg

        {c, memo} = expand_segments_n(numkeys, 25, dir_paths, memo)
        dbg({c, n})
        {acc + c * n, memo}
      end)
  end
end
