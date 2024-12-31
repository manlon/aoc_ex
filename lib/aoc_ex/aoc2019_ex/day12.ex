defmodule AocEx.Aoc2019Ex.Day12 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  @moon_pattern ~r{<x=(.*), y=(.*), z=(.*)>}

  def ex do
    """
    <x=-8, y=-10, z=0>
    <x=5, y=5, z=10>
    <x=2, y=-7, z=3>
    <x=9, y=-8, z=-3>
    """
  end

  def input do
    AocEx.Day.input_file_contents(2019, 12)
    |> parse_input
  end

  def parse_input(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_moon/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {moon, idx}, acc -> Map.put(acc, idx, moon) end)
  end

  def parse_moon(line) do
    pos =
      Regex.run(@moon_pattern, line)
      |> tl
      |> Enum.map(&String.to_integer/1)

    {pos, [0, 0, 0]}
  end

  def pairs([a, b]) do
    [[a, b]]
  end

  def pairs([a]) do
    nil
  end

  def pairs([a | rest]) do
    rest
    |> Enum.map(fn i -> [a, i] end)
    |> Kernel.++(pairs(rest))
  end

  def tick(moons, i \\ 1) do
    if i <= 0 do
      moons
    else
      moons
      |> apply_gravity
      |> apply_velocity
      |> tick(i - 1)
    end
  end

  def one_coord(moons, i) do
    Enum.reduce(moons, %{}, fn {idx, {p, v}}, acc ->
      Map.put(acc, idx, {[Enum.at(p, i)], [0]})
    end)
  end

  def tick_until_same(moons, init \\ nil, steps \\ 0) do
    if init == nil do
      init = moons
      moons = tick(moons)
      tick_until_same(moons, init, 1)
    else
      if moons == init do
        steps
      else
        tick_until_same(tick(moons), init, steps + 1)
      end
    end
  end

  def energy({p, v}) do
    [p, v]
    |> Enum.map(fn vec ->
      vec
      |> Enum.map(&abs/1)
      |> Enum.sum()
    end)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def part1 do
    input()
    |> tick(1000)
    |> Map.values()
    |> Enum.map(&energy/1)
    |> Enum.sum()
  end

  def part2 do
    moons = input()

    [0, 1, 2]
    |> Enum.map(fn i ->
      tick_until_same(one_coord(moons, i))
    end)
    |> IO.inspect()
    |> lcm()
  end

  def lcm([a, b | rest]) do
    lcm([div(a * b, Integer.gcd(a, b)) | rest])
  end

  def lcm([a]) do
    a
  end

  def compare_positions(p1, p2) do
    [p1, p2]
    |> Enum.zip()
    |> Enum.map(fn {a, b} ->
      cond do
        a == b ->
          0

        a < b ->
          1

        a > b ->
          -1
      end
    end)
  end

  def add_tuples(t1, t2) do
    [t1, t2]
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.sum/1)
  end

  def add_gravity_from(m1, m2) do
    {p1, v1} = m1
    {p2, v2} = m2
    delta = compare_positions(p1, p2)
    new_v = add_tuples(v1, delta)
    {p1, new_v}
  end

  def apply_gravity(moons) do
    index_pairs = pairs(Map.keys(moons))

    index_pairs
    |> Enum.reduce(moons, fn [idx1, idx2], acc ->
      m1 = Map.get(acc, idx1)
      m2 = Map.get(acc, idx2)

      acc
      |> Map.put(idx1, add_gravity_from(m1, m2))
      |> Map.put(idx2, add_gravity_from(m2, m1))
    end)
  end

  def apply_velocity(moons) do
    moons
    |> Enum.reduce(%{}, fn {idx, moon}, acc ->
      {p, v} = moon
      Map.put(acc, idx, {add_tuples(p, v), v})
    end)
  end
end
