defmodule AocEx.Aoc2024Ex.Day15 do
  @robot "@"
  @wall "#"
  @empty "."
  @box "O"
  @boxl "["
  @boxr "]"

  @dirs %{
    <: {0, -1},
    >: {0, 1},
    ^: {-1, 0},
    v: {1, 0}
  }
  def input(inp \\ nil) do
    (inp || AocEx.Day.input_file_contents(2024, 15))
    |> String.trim("\n")
    |> String.split("\n\n")
    |> then(fn [map, moves] ->
      {map_with_size(map),
       String.split(moves)
       |> Enum.join()
       |> String.graphemes()
       |> Enum.map(&String.to_existing_atom/1)}
    end)
  end

  def map_with_size(map_inp) do
    map_inp
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

  def print_map(map, pos, move) do
    map = Map.put(map, pos, @robot)
    {maxr, maxc} = Enum.max(Map.keys(map))

    IO.write("Move: #{move}\n")

    for r <- 0..maxr do
      [
        for c <- 0..maxc do
          map[{r, c}]
        end
        | "\n"
      ]
    end
    |> IO.write()

    IO.write("\n\n")
    # Process.sleep(50)

    :ok
  end

  def double(map) do
    Enum.reduce(map, %{}, fn {{r, c}, val}, acc ->
      case val do
        @box ->
          Map.put(acc, {r, 2 * c}, @boxl)
          |> Map.put({r, 2 * c + 1}, @boxr)

        @robot ->
          Map.put(acc, {r, 2 * c}, @robot)
          |> Map.put({r, 2 * c + 1}, @empty)

        _ ->
          Map.put(acc, {r, 2 * c}, val)
          |> Map.put({r, 2 * c + 1}, val)
      end
    end)
  end

  def addpos({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}
  def abspos({r, c}), do: {abs(r), abs(c)}
  def multpos({r, c}, x), do: {r * x, c * x}

  def movepos(pos, dir, n \\ 1) do
    dir = @dirs[dir]
    addpos(pos, multpos(dir, n))
  end

  def move_pos_set(set = %MapSet{}, move, n \\ 1) do
    for pos <- set,
        pos = movepos(pos, move, n),
        !MapSet.member?(set, pos) do
      pos
    end
    |> MapSet.new()
  end

  def move(map, pos, []), do: {map, pos}

  def move(map, pos, [move | rest]) do
    # print_map(map, pos, move)
    nextpos = movepos(pos, move)

    case Map.get(map, nextpos) do
      @empty ->
        move(map, nextpos, rest)

      @wall ->
        move(map, pos, rest)

      @box ->
        {map, pos} = move_boxes(map, pos, move)
        move(map, pos, rest)

      @boxl ->
        {map, pos} = move_double_boxes(map, pos, [nextpos], move)
        move(map, pos, rest)

      @boxr ->
        {map, pos} = move_double_boxes(map, pos, [nextpos], move)
        move(map, pos, rest)
    end
  end

  def move_boxes(map, pos, move) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while([], fn i, acc ->
      nextpos = movepos(pos, move, i)

      case Map.get(map, nextpos) do
        @box ->
          {:cont, [nextpos | acc]}

        @empty ->
          {:halt, {:ok, Enum.reverse(acc)}}

        @wall ->
          {:halt, :blocked}
      end
    end)
    |> case do
      {:ok, boxes = [box | _]} ->
        last_box = movepos(Enum.at(boxes, -1), move)

        map =
          Map.put(map, box, @empty)
          |> Map.put(last_box, @box)

        {map, box}

      :blocked ->
        {map, pos}
    end
  end

  def move_double_boxes(map, pos, boxes, move) when is_list(boxes) do
    move_double_boxes(map, pos, MapSet.new(boxes), move)
  end

  def move_double_boxes(map, pos, boxes = %MapSet{}, move) do
    boxes = add_box_pairs(map, boxes)
    new_positions = move_pos_set(boxes, move)

    cond do
      Enum.any?(new_positions, fn x -> map[x] == @wall end) ->
        {map, pos}

      Enum.all?(new_positions, fn x -> map[x] == @empty end) ->
        map = do_box_movement(map, boxes, move)
        {map, movepos(pos, move)}

      Enum.all?(new_positions, fn x -> map[x] in [@boxl, @boxr, @empty] end) ->
        box_pos =
          Enum.filter(new_positions, fn x -> map[x] in [@boxl, @boxr] end)
          |> MapSet.new()

        move_double_boxes(map, pos, MapSet.union(boxes, box_pos), move)

      true ->
        raise "fail"
    end
  end

  def do_box_movement(map, boxes, move) do
    map_boxes_removed =
      Enum.reduce(boxes, map, fn box, acc ->
        Map.put(acc, box, @empty)
      end)

    Enum.reduce(boxes, map_boxes_removed, fn box, acc ->
      Map.put(acc, movepos(box, move), Map.get(map, box))
    end)
  end

  def add_box_pairs(map, boxes) do
    Enum.reduce(boxes, MapSet.new(), fn box, acc ->
      dir = if map[box] == @boxl, do: :>, else: :<

      MapSet.put(acc, box)
      |> MapSet.put(movepos(box, dir))
    end)
  end

  def score(map) do
    Enum.filter(map, fn {_, val} -> val in [@box, @boxl] end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(fn {r, c} -> 100 * r + c end)
    |> Enum.sum()
  end

  def solve1 do
    {{map, _}, moves} = input()
    {pos, @robot} = Enum.find(map, fn {_, val} -> val == @robot end)
    map = Map.put(map, pos, @empty)
    {map, _pos} = move(map, pos, moves)
    score(map)
  end

  def solve2 do
    {{map, _}, moves} = input()
    map = double(map)
    {pos, @robot} = Enum.find(map, fn {_, val} -> val == @robot end)
    map = Map.put(map, pos, @empty)
    {map, _pos} = move(map, pos, moves)
    # print_map(map, pos, "done")
    score(map)
  end
end
