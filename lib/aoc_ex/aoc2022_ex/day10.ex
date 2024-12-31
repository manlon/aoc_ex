defmodule AocEx.Aoc2022Ex.Day10 do
  use AocEx.Day, year: 2022, day: 10

  def parse do
    input_lines()
    |> Enum.map(&String.split/1)
    |> Enum.map(fn s ->
      case s do
        ["noop"] -> :noop
        ["addx", n] -> {:addx, String.to_integer(n)}
      end
    end)
  end

  def solve1 do
    {signals, _} = run_prog()
    Enum.sum(for {a, b} <- signals, do: a * b)
  end

  def solve2 do
    {_, paint} = run_prog()

    screen =
      Enum.chunk_every(paint, 40)
      |> Enum.map(&Enum.join/1)
      |> Enum.join("\n")

    IO.puts(screen)
    screen
  end

  def run_prog(), do: run_prog(parse(), 1, 1, [], [])
  def run_prog([], _, _, results, paint), do: {results, Enum.reverse(paint)}

  def run_prog([instr | rest_program], cycle, reg, results, paint) do
    {results, paint} = check(cycle, reg, results, paint)

    case instr do
      :noop ->
        run_prog(rest_program, cycle + 1, reg, results, paint)

      {:addx, n} ->
        {results, paint} = check(cycle + 1, reg, results, paint)
        reg = reg + n
        run_prog(rest_program, cycle + 2, reg, results, paint)
    end
  end

  def check(cycle, reg, results, paint) do
    results =
      if rem(cycle - 20, 40) == 0 do
        [{cycle, reg} | results]
      else
        results
      end

    scan_pos = rem(cycle - 1, 40)

    paint =
      if(scan_pos in (reg - 1)..(reg + 1)) do
        ["#" | paint]
      else
        ["." | paint]
      end

    {results, paint}
  end
end
