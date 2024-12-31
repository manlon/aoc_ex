defmodule AocEx.Aoc2016Ex.Day12 do
  use AocEx.Day, year: 2016, day: 12

  def parse_val(val) when val in ["a", "b", "c", "d"], do: val
  def parse_val(val), do: String.to_integer(val)

  def parsed_input do
    for line <- input_tokens() do
      case line do
        ["cpy", x, y] -> {:cpy, parse_val(x), y}
        ["inc", x] -> {:inc, x}
        ["dec", x] -> {:dec, x}
        ["jnz", x, y] -> {:jnz, x, parse_val(y)}
      end
    end
    |> :array.from_list()
  end

  def compute(_, :halt, regs), do: regs

  def compute(program, pctr, regs) do
    {regs, pctr} =
      case :array.get(pctr, program) do
        {:cpy, x, y} when is_integer(x) ->
          {Map.put(regs, y, x), pctr + 1}

        {:cpy, x, y} ->
          {Map.put(regs, y, regs[x]), pctr + 1}

        {:inc, x} ->
          {Map.update!(regs, x, &(&1 + 1)), pctr + 1}

        {:dec, x} ->
          {Map.update!(regs, x, &(&1 - 1)), pctr + 1}

        {:jnz, x, y} ->
          {regs, if(regs[x] != 0, do: pctr + y, else: pctr + 1)}

        :undefined ->
          {regs, :halt}
      end

    compute(program, pctr, regs)
  end

  @regs %{"a" => 0, "b" => 0, "c" => 0, "d" => 0}

  def solve1 do
    compute(parsed_input(), 0, @regs)
  end

  def solve2 do
    compute(parsed_input(), 0, put_in(@regs["c"], 1))
  end
end
