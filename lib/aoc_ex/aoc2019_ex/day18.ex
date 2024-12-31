defmodule AocEx.Aoc2019Ex.Day18 do
  def input do
    AocEx.Day.input_file_contents(2019, 18)
    |> parse_input
  end

  def parse_input(str) do
    list_of_chars =
      str
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    row_count = length(list_of_chars)
    col_count = length(hd(list_of_chars))

    {map, _} =
      list_of_chars
      |> Enum.reduce({%{}, 0}, fn row, {map, rowidx} ->
        {map, _} =
          Enum.reduce(row, {map, 0}, fn char, {map, colidx} ->
            {Map.put(map, {colidx, rowidx}, char), colidx + 1}
          end)

        {map, rowidx + 1}
      end)

    {map, {row_count, col_count}}
  end

  def print_map({map, {row_count, col_count}}), do: print_map(map, row_count, col_count)

  def print_map(map, row_count, col_count) do
    0..(row_count - 1)
    |> Enum.map(fn r ->
      0..(col_count - 1)
      |> Enum.map(fn c ->
        Map.get(map, {r, c})
      end)
    end)
    |> :string.join(~c'\n')
    |> IO.puts()
  end

  @capdiff ?a - ?A

  def is_key?(c), do: c in ?a..?z
  def is_door?(c), do: c in ?A..?Z
  def is_passage?(c), do: c == ?.
  def is_entrance?(c), do: c == ?@
  def is_wall?(c), do: c == ?#
  def key_for(door), do: door + @capdiff

  def advance_positions_until_key(map, {r, c}, keys),
    do: advance_positions_until_key(map, [{{r, c}, 0}], keys, MapSet.new([{r, c}]), [])

  def advance_positions_until_key(map, positions, keys) when is_list(positions) do
    pos_with_len = for p <- positions, do: {p, 0}
    advance_positions_until_key(map, pos_with_len, keys, MapSet.new(positions), [])
  end

  def advance_positions_until_key(_map, [], _keys, _visited_positions, results), do: results

  def advance_positions_until_key(
        map,
        [_pos = {{r, c}, len} | rest_positions],
        keys,
        visited_positions,
        results
      ) do
    {new_positions, visited, results} =
      [{1, 0}, {-1, 0}, {0, -1}, {0, 1}]
      |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
      |> Enum.filter(fn p ->
        Map.has_key?(map, p) and p not in visited_positions and !is_wall?(Map.get(map, p))
      end)
      |> Enum.reduce({[], visited_positions, results}, fn new_pos,
                                                          {new_positions, visited, results} ->
        char = Map.get(map, new_pos)

        cond do
          is_passage?(char) or
            is_entrance?(char) or
            (is_door?(char) and key_for(char) in keys) or
              (is_key?(char) and char in keys) ->
            new_positions = [{new_pos, len + 1} | new_positions]
            visited = MapSet.put(visited, new_pos)
            {new_positions, visited, results}

          is_key?(char) ->
            visited = MapSet.put(visited, new_pos)
            results = [{new_pos, len + 1, char} | results]
            {new_positions, visited, results}

          is_door?(char) ->
            {new_positions, visited, results}

          true ->
            raise "whoops #{char}"
        end
      end)

    advance_positions_until_key(map, rest_positions ++ new_positions, keys, visited, results)
  end

  def successor_states(map, {start_len, positions, keys}) do
    successor_states(map, start_len, positions, [], keys, [])
  end

  def successor_states(_map, _start_len, [], _seen, _keys, results), do: results

  def successor_states(map, start_len, [pos | rest], seen, keys, result) do
    new_key_posits = advance_positions_until_key(map, pos, keys)

    new_results =
      for {pos, len, k} <- new_key_posits do
        all_robots = seen ++ [pos | rest]
        {start_len + len, all_robots, Enum.sort([k | keys])}
      end

    successor_states(map, start_len, rest, seen ++ [pos], keys, new_results ++ result)
  end

  def advance_until_all_keys(map, states, num_keys) do
    visited =
      Enum.reduce(states, %{}, fn {len, pos, keys}, acc ->
        Map.put(acc, {pos, keys}, len)
      end)

    advance_until_all_keys(map, states, num_keys, visited)
  end

  def advance_until_all_keys(
        _map,
        _states = [state = {_len, _positions, keys} | _rest],
        num_keys,
        _visited
      )
      when length(keys) == num_keys do
    state
  end

  def advance_until_all_keys(
        map,
        states = [state = {_len, _positions, _keys} | rest],
        num_keys,
        visited
      ) do
    IO.inspect(length(states))
    IO.inspect(state)

    new_states =
      successor_states(map, state)
      |> Enum.filter(fn {len, positions, keys} ->
        Map.get(visited, {positions, keys}, :infinity) > len
      end)

    visited =
      Enum.reduce(new_states, visited, fn {len, positions, keys}, visited ->
        Map.put(visited, {positions, keys}, len)
      end)

    states = Enum.sort(new_states ++ rest)
    advance_until_all_keys(map, states, num_keys, visited)
  end

  def go1 do
    {map, {_rc, _cc}} = input()
    {{startrow, startcol}, _} = Enum.find(map, fn {_, x} -> is_entrance?(x) end)
    startpos = {startrow, startcol}
    num_keys = length(Enum.filter(Map.values(map), &is_key?/1))
    {len, _, _} = advance_until_all_keys(map, [{0, [startpos], ~c''}], num_keys)
    len
  end

  def go2 do
    {map, {_rc, _cc}} = input()
    {{startrow, startcol}, _} = Enum.find(map, fn {_, x} -> is_entrance?(x) end)
    num_keys = length(Enum.filter(Map.values(map), &is_key?/1))

    map =
      map
      |> Map.put({startrow + 1, startcol}, ?#)
      |> Map.put({startrow - 1, startcol}, ?#)
      |> Map.put({startrow, startcol + 1}, ?#)
      |> Map.put({startrow, startcol - 1}, ?#)

    robot_starts =
      [{-1, -1}, {-1, 1}, {1, -1}, {1, 1}]
      |> Enum.map(fn {dr, dc} -> {startrow + dr, startcol + dc} end)

    {len, _, _} = advance_until_all_keys(map, [{0, robot_starts, ~c''}], num_keys)
    len
  end
end
