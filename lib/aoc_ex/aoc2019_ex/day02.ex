defmodule AocEx.Aoc2019Ex.Day02 do
  def input do
    AocEx.Day.input_file_contents(2019, 2)
    # "1,1,1,4,99,5,6,0,99"
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list()
  end

  def set(arr, i, v) do
    :array.set(i, v, arr)
  end

  def get(arr, i) do
    :array.get(i, arr)
  end

  def part1 do
    try_input(input(), 12, 2)
  end

  def try_input(inp, x, y) do
    inp
    |> set(1, x)
    |> set(2, y)
    |> doop(0)
    |> get(0)
  end

  def try_loop(inp, x, y) do
    val = try_input(inp, x, y)

    if val == 19_690_720 do
      x * 100 + y
    else
      if y >= 99 do
        try_loop(inp, x + 1, 0)
      else
        try_loop(inp, x, y + 1)
      end
    end
  end

  def part2 do
    try_loop(input(), 0, 0)
  end

  def get_chunk(arr, i, n) do
    i..(i + n - 1)
    |> Enum.map(&get(arr, &1))
  end

  def doop(arr, i) do
    op = get(arr, i)

    case op do
      1 ->
        [p1, p2, p3] = get_chunk(arr, i + 1, 3)
        [v1, v2] = Enum.map([p1, p2], &get(arr, &1))

        set(arr, p3, v1 + v2)
        |> doop(i + 4)

      2 ->
        [p1, p2, p3] = get_chunk(arr, i + 1, 3)
        [v1, v2] = Enum.map([p1, p2], &get(arr, &1))

        set(arr, p3, v1 * v2)
        |> doop(i + 4)

      99 ->
        arr
    end
  end
end
