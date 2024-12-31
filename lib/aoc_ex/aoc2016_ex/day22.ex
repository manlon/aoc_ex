defmodule AocEx.Aoc2016Ex.Day22 do
  use AocEx.Day, year: 2016, day: 22
  # import Aoc2015Ex.Combos, only: [pairs: 1]

  def parsed_input do
    for [x, y, size, used, avail, _] <- input_line_ints() do
      {{x, y}, {size, used, avail}}
    end
  end

  def fixed_input do
    items =
      for {loc, {size, used, _avail}} <- parsed_input() do
        case {size, used} do
          {size, used} when size > 500 and used >= 490 ->
            {loc, "#"}

          {size, 0} when size in 60..100 ->
            {loc, "_"}

          {size, used} when size in 60..100 and used in 60..75 ->
            {loc, "."}
        end
      end

    {{maxx, _}, _} = Enum.max(items)

    Map.new(items)
    |> Map.put({maxx, 0}, "G")
  end

  def hash(map) do
    Enum.reduce(map, {nil, nil}, fn {loc, item}, {blank, goal} ->
      case item do
        "_" ->
          {loc, goal}

        "G" ->
          {blank, loc}

        _ ->
          {blank, goal}
      end
    end)
  end

  def search(_states = [{map, n, blank, goal} | rest], seen) do
    if goal == {0, 0} do
      n
    else
      neighbors =
        four_neighbors(blank)
        |> Enum.filter(fn loc -> Map.has_key?(map, loc) && map[loc] != "#" end)
        |> Enum.filter(fn {_x, y} -> y <= 6 end)

      new_states =
        neighbors
        |> Enum.map(fn neighb ->
          cur = map[neighb]

          new_map =
            Map.put(map, neighb, "_")
            |> Map.put(blank, cur)

          {new_map, n + 1, neighb, if(neighb == goal, do: blank, else: goal)}
        end)
        |> Enum.filter(fn {_map, _n, blank, goal} -> {blank, goal} not in seen end)

      seen =
        Enum.reduce(new_states, seen, fn {_map, _n, blank, goal}, seen ->
          MapSet.put(seen, {blank, goal})
        end)

      search(rest ++ new_states, seen)
    end
  end

  def solve1 do
    all_pairs = Stream.flat_map(pairs(parsed_input()), fn [a, b] -> [[a, b], [b, a]] end)

    for [a = {_, {_asize, aused, _aavail}}, b = {_, {_bsize, _bused, bavail}}] <- all_pairs,
        aused > 0,
        aused <= bavail do
      {a, b}
    end
    |> Enum.count()
  end

  def solve2 do
    inp = fixed_input()
    {blank, goal} = hash(inp)
    search([{inp, 0, blank, goal}], MapSet.new([{blank, goal}]))
  end
end
