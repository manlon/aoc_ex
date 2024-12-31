defmodule AocEx.Aoc2022Ex.Day22 do
  use AocEx.Day, year: 2022, day: 22

  # @test_input ""
  #         ...#
  #         .#..
  #         #...
  #         ....
  # ...#.......#
  # ........#...
  # ..#....#....
  # ..........#.
  #         ...#....
  #         .....#..
  #         .#......
  #         ......#.

  # 10R5L5R10L4R5L5
  # """

  def parse_moves(str) do
    Regex.scan(~r[\d+|\D+], str)
    |> Enum.map(fn part ->
      case part do
        ["R"] -> :r
        ["L"] -> :l
        [i] -> String.to_integer(i)
      end
    end)
  end

  def get_input do
    [map, moves] = String.split(input(), "\n\n")
    {map, _size} = input_map_with_size(map)

    map =
      Enum.filter(map, fn {_, v} -> v != " " end)
      |> Map.new()

    moves = parse_moves(moves)
    {map, moves}
  end

  def add_dir(:right, :r), do: :down
  def add_dir(:down, :r), do: :left
  def add_dir(:left, :r), do: :up
  def add_dir(:up, :r), do: :right
  def add_dir(:right, :l), do: :up
  def add_dir(:up, :l), do: :left
  def add_dir(:left, :l), do: :down
  def add_dir(:down, :l), do: :right

  def add_pos({r, c}, :right), do: {r, c + 1}
  def add_pos({r, c}, :down), do: {r + 1, c}
  def add_pos({r, c}, :left), do: {r, c - 1}
  def add_pos({r, c}, :up), do: {r - 1, c}

  def score_dir(:right), do: 0
  def score_dir(:down), do: 1
  def score_dir(:left), do: 2
  def score_dir(:up), do: 3
  def char(:right), do: ">"
  def char(:left), do: "<"
  def char(:up), do: "^"
  def char(:down), do: "v"

  def wrap(map, {r, _c}, :right) do
    Map.keys(map)
    |> Enum.filter(fn {rr, _} -> rr == r end)
    |> Enum.min()
  end

  def wrap(map, {_r, c}, :down) do
    Map.keys(map)
    |> Enum.filter(fn {_, cc} -> cc == c end)
    |> Enum.min()
  end

  def wrap(map, {r, _c}, :left) do
    Map.keys(map)
    |> Enum.filter(fn {rr, _} -> rr == r end)
    |> Enum.max()
  end

  def wrap(map, {_r, c}, :up) do
    Map.keys(map)
    |> Enum.filter(fn {_, cc} -> cc == c end)
    |> Enum.max()
  end

  @dim 50

  def edge({_r, c}, {0, 1}, :up), do: {{c, 0}, :right, {3, 0}}
  def edge({r, _c}, {0, 1}, :left), do: {{@dim - r - 1, 0}, :right, {2, 0}}
  def edge({_r, c}, {0, 2}, :up), do: {{@dim - 1, c}, :up, {3, 0}}
  def edge({_r, c}, {0, 2}, :down), do: {{c, @dim - 1}, :left, {1, 1}}
  def edge({r, _c}, {0, 2}, :right), do: {{@dim - r - 1, @dim - 1}, :left, {2, 1}}
  def edge({r, _c}, {1, 1}, :left), do: {{0, r}, :down, {2, 0}}
  def edge({r, _c}, {1, 1}, :right), do: {{@dim - 1, r}, :up, {0, 2}}
  def edge({_r, c}, {2, 0}, :up), do: {{c, 0}, :right, {1, 1}}
  def edge({r, _c}, {2, 0}, :left), do: {{@dim - r - 1, 0}, :right, {0, 1}}
  def edge({r, _c}, {2, 1}, :right), do: {{@dim - r - 1, @dim - 1}, :left, {0, 2}}
  def edge({_r, c}, {2, 1}, :down), do: {{c, @dim - 1}, :left, {3, 0}}
  def edge({r, _c}, {3, 0}, :left), do: {{0, r}, :down, {0, 1}}
  def edge({_r, c}, {3, 0}, :down), do: {{0, c}, :down, {0, 2}}
  def edge({r, _c}, {3, 0}, :right), do: {{@dim - 1, r}, :up, {2, 1}}

  def cube_wrap(_map, {r, c}, dir) do
    face = {div(r, @dim), div(c, @dim)}
    face_pos = {rem(r, @dim), rem(c, @dim)}

    {{new_face_pos_r, new_face_pos_c}, new_dir, {new_face_y, new_face_x}} =
      edge(face_pos, face, dir)

    new_pos = {new_face_y * @dim + new_face_pos_r, new_face_x * @dim + new_face_pos_c}
    {new_pos, new_dir}
  end

  def move(_map, [], pos, dir), do: {pos, dir}

  def move(map, [0 | rest], pos, dir) do
    move(map, rest, pos, dir)
  end

  def move(map, [steps | rest], pos, dir) when is_integer(steps) do
    new_pos = add_pos(pos, dir)

    new_pos =
      if Map.has_key?(map, new_pos) do
        new_pos
      else
        wrap(map, new_pos, dir)
      end

    case Map.get(map, new_pos) do
      "#" ->
        move(map, rest, pos, dir)

      "." ->
        move(map, [steps - 1 | rest], new_pos, dir)
    end
  end

  def move(map, [turn | rest], pos, dir) do
    new_dir = add_dir(dir, turn)
    move(map, rest, pos, new_dir)
  end

  def move_cube(_map, [], pos, dir), do: {pos, dir}

  def move_cube(map, [0 | rest], pos, dir) do
    move_cube(map, rest, pos, dir)
  end

  def move_cube(map, [steps | rest], pos, dir) when is_integer(steps) do
    new_pos = add_pos(pos, dir)

    {new_pos, new_dir} =
      if Map.has_key?(map, new_pos) do
        {new_pos, dir}
      else
        cube_wrap(map, pos, dir)
      end

    case Map.get(map, new_pos) do
      "#" ->
        move_cube(map, rest, pos, dir)

      "." ->
        move_cube(map, [steps - 1 | rest], new_pos, new_dir)
    end
  end

  def move_cube(map, [turn | rest], pos, dir) do
    new_dir = add_dir(dir, turn)
    move_cube(map, rest, pos, new_dir)
  end

  def solve1 do
    {map, moves} = get_input()
    start_pos = Enum.min(Map.keys(map))
    start_dir = :right

    {{r, c}, dir} = move(map, moves, start_pos, start_dir)

    1000 * (r + 1) + 4 * (c + 1) + score_dir(dir)
  end

  def solve2 do
    {map, moves} = get_input()
    start_pos = Enum.min(Map.keys(map))
    start_dir = :right

    {{r, c}, dir} = move_cube(map, moves, start_pos, start_dir)

    1000 * (r + 1) + 4 * (c + 1) + score_dir(dir)
  end
end
