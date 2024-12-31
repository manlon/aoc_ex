defmodule AocEx.Aoc2019Ex.Day10 do
  @max 24

  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 10)
    |> parse_input
  end

  def ex do
    """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """
  end

  def parse_input(str) do
    list_of_chars =
      str
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.codepoints()
      end)

    row_count = length(list_of_chars)
    col_count = length(hd(list_of_chars))

    {map, _} =
      list_of_chars
      |> Enum.reduce({%{}, 0}, fn row, {map, rowidx} ->
        {map, _} =
          Enum.reduce(row, {map, 0}, fn char, {map, colidx} ->
            if char == "#" do
              {Map.put(map, {colidx, rowidx}, "#"), colidx + 1}
            else
              {map, colidx + 1}
            end
          end)

        {map, rowidx + 1}
      end)

    {map, {row_count, col_count}}
  end

  def print_map(map) do
    0..(@max - 1)
    |> Enum.map(fn r ->
      0..(@max - 1)
      |> Enum.map(fn c ->
        if Map.has_key?(map, {c, r}) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def max_visible_count_pos(map) do
    Map.keys(map)
    |> Enum.map(fn pos ->
      {c, _} = visible_from(map, pos)
      {c, pos}
    end)
    |> Enum.max()
  end

  def part1 do
    {map, _} = input()
    {maxc, _} = max_visible_count_pos(map)
    maxc
  end

  def part2 do
    {map, _} = input()
    {_maxc, maxpos} = max_visible_count_pos(map)

    Map.delete(map, maxpos)
    |> Map.keys()
    |> order_points(maxpos)
    |> Enum.at(199)
    |> case do
      {_, _, {x, y}} ->
        100 * x + y
    end
  end

  def order_points(points, origin) do
    points =
      points
      |> Enum.map(fn p -> {point_clock_angle(origin, p), point_dist(origin, p), p} end)
      |> Enum.sort()

    order_points(points, origin, nil, [])
  end

  def order_points([], _, _, result) do
    result |> Enum.reverse()
  end

  def order_points(points, origin, at_least_angle, result) do
    cmp_angle_fn =
      if at_least_angle == nil do
        fn {angle, _, _} -> angle >= 0 end
      else
        fn {angle, _, _} -> angle > at_least_angle end
      end

    points_after_rotate =
      points
      |> Enum.filter(cmp_angle_fn)

    case points_after_rotate do
      [] ->
        order_points(points, origin, nil, result)

      pts ->
        {min_angle, _, _} = Enum.min_by(pts, fn {a, _, _} -> a end)
        points_at_angle = Enum.filter(pts, fn {a, _, _} -> a == min_angle end)
        closest = Enum.min_by(points_at_angle, fn {_, d, _} -> d end)
        order_points(List.delete(points, closest), origin, min_angle, [closest | result])
    end
  end

  def point_dist(p1, p2) do
    {x1, y1} = p1
    {x2, y2} = p2
    dx = x2 - x1
    dy = y2 - y1
    dx * dx + dy * dy
  end

  def point_clock_angle(_origin = {xo, yo}, _p1 = {x1, y1}) do
    dx = x1 - xo
    dy = y1 - yo
    :math.pi() - :math.atan2(dx, dy)
  end

  def ring_distance_positions(_map, {x, y}, dist) do
    topy = y - dist
    boty = y + dist
    leftx = x - dist
    rightx = x + dist

    (Enum.map(leftx..rightx, fn x -> {x, topy} end) ++
       Enum.map(leftx..rightx, fn x -> {x, boty} end) ++
       Enum.map(topy..boty, fn y -> {leftx, y} end) ++
       Enum.map(topy..boty, fn y -> {rightx, y} end))
    |> Enum.uniq()
    |> Enum.filter(fn {x, y} ->
      x >= 0 && x < @max && y >= 0 && y < @max
    end)
  end

  def visible_from(map, {x, y}) do
    1..(@max - 1)
    |> Enum.reduce({map, []}, fn dist, {map, visibles} ->
      visible =
        ring_distance_positions(map, {x, y}, dist)
        |> Enum.filter(fn pos -> Map.has_key?(map, pos) end)

      map =
        Enum.reduce(visible, map, fn pos, map ->
          remove_blocked(map, {x, y}, pos)
        end)

      {map, visibles ++ visible}
    end)
    |> case do
      {_, visibles} ->
        {length(visibles), visibles}
    end
  end

  def remove_blocked(map, {_x, _y} = origin, {_x1, _y1} = pos) do
    skip_positions = skips(origin, pos)

    skip_positions
    |> Enum.reduce(map, fn skip_pos, map ->
      _map =
        if Map.has_key?(map, skip_pos) do
          if pos == skip_pos do
            # IO.puts "SEE #{inspect skip_pos}"
          else
            # IO.puts "BLOCKED #{inspect skip_pos}"
          end

          map = Map.delete(map, skip_pos)
          map
        else
          map
        end
    end)
  end

  def reduce_skip({x, y}) do
    case {x, y} do
      {0, 0} ->
        IO.puts("oh no")
        nil

      {0, y} ->
        {0, div(y, abs(y))}

      {x, 0} ->
        {div(x, abs(x)), 0}

      {x, y} ->
        case Integer.gcd(x, y) do
          1 ->
            {x, y}

          d ->
            reduce_skip({div(x, d), div(y, d)})
        end
    end
  end

  def skips(_from = {x, y}, _to = {x1, y1}) do
    {xskip, yskip} = reduce_skip({x1 - x, y1 - y})

    0..@max
    |> Enum.reduce_while([], fn mult, result ->
      {xpos, ypos} = {xskip * mult + x, yskip * mult + y}

      if xpos >= 0 && xpos < @max && ypos >= 0 && ypos < @max do
        {:cont, [{xpos, ypos} | result]}
      else
        {:halt, result}
      end
    end)
  end
end
