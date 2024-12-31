defmodule AocEx.Aoc2019Ex.Day16 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def puzzle_input do
    AocEx.Day.input_file_contents(2019, 16)
    |> parse_input
  end

  def parse_input(s) do
    s
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)

    # |> :array.from_list(0)
  end

  def make_pattern(idx) do
    [0, 1, 0, -1]
    |> Enum.map(fn i -> {i, idx} end)
    |> pop_pattern(idx)
    |> case do
      {pattern, _} ->
        pattern
    end
  end

  def part1 do
    puzzle_input()
    |> phases(100)
    |> Enum.take(8)
    |> Enum.join()
    |> String.to_integer()
  end

  def part2 do
    inp = puzzle_input()
    l = length(inp)
    signal_length = l * 10000

    offset =
      Enum.take(inp, 7)
      |> Enum.join()
      |> String.to_integer()

    tail_length = signal_length - offset
    repeats = div(tail_length, l)
    first_chunk_size = rem(tail_length, l)

    signal = Enum.drop(inp, l - first_chunk_size) ++ Enum.concat(List.duplicate(inp, repeats))

    fast_phases(signal, 100)
    |> Enum.take(8)
    |> Enum.join()
    |> String.to_integer()
  end

  def pop_pattern([{n, repeats} | rest], idx) do
    if repeats == 0 do
      pop_pattern(rest ++ [{n, idx}], idx)
    else
      {[{n, repeats - 1} | rest], n}
    end
  end

  def phases(input, n) do
    if n == 0 do
      input
    else
      output = phase(input, length(input))
      phases(output, n - 1)
    end
  end

  def running_sum([], _, output) do
    output
  end

  def running_sum([n | rest], sum, output) do
    sum = rem(sum + n, 10)
    running_sum(rest, sum, [sum | output])
  end

  def fast_phases(input, n) do
    if n == 0 do
      input
    else
      fast_phases(fast_phase(input), n - 1)
    end
  end

  def fast_phase(input) do
    rev = Enum.reverse(input)
    running_sum(rev, 0, [])
  end

  def phase(input, len, output \\ [], idx \\ 1) do
    if idx > len do
      Enum.reverse(output)
    else
      n = calc_position(idx, input)
      phase(input, len, [n | output], idx + 1)
    end
  end

  def calc_position(idx, input) do
    pattern = make_pattern(idx)

    {result, _} =
      input
      |> Enum.reduce({0, pattern}, fn n, {sum, pattern} ->
        {pattern, mult} = pop_pattern(pattern, idx)
        {sum + mult * n, pattern}
      end)

    abs(rem(result, 10))
  end
end
