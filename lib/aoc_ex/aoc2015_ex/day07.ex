defmodule AocEx.Aoc2015Ex.Day07 do
  use AocEx.Day, year: 2015, day: 7
  import Bitwise

  def parse_input do
    for line <- input_lines(),
        toks = String.split(line) do
      case toks do
        [num, "->", res] -> {res, parse_arg(num)}
        ["NOT", arg, "->", res] -> {res, {:not, parse_arg(arg)}}
        [a1, "AND", a2, "->", res] -> {res, {:and, parse_arg(a1), parse_arg(a2)}}
        [a1, "OR", a2, "->", res] -> {res, {:or, parse_arg(a1), parse_arg(a2)}}
        [a1, "LSHIFT", a2, "->", res] -> {res, {:lshift, parse_arg(a1), parse_arg(a2)}}
        [a1, "RSHIFT", a2, "->", res] -> {res, {:rshift, parse_arg(a1), parse_arg(a2)}}
      end
    end
    |> Map.new()
  end

  def parse_arg(arg) do
    if Regex.match?(~r{^\d*$}, arg) do
      String.to_integer(arg)
    else
      arg
    end
  end

  def flow(diagram) do
    {diagram, updated?} =
      Enum.reduce(diagram, {diagram, false}, fn {key, val}, {diagram, any_update?} ->
        {new_val, updated?} =
          case val do
            {op, a1, a2} when is_binary(a1) or is_binary(a2) ->
              case diagram do
                %{^a1 => v1} when is_integer(v1) -> {{op, v1, a2}, true}
                %{^a2 => v2} when is_integer(v2) -> {{op, a1, v2}, true}
                _ -> {val, false}
              end

            {op, a1} when is_binary(a1) ->
              case diagram do
                %{^a1 => v1} when is_integer(v1) -> {{op, v1}, true}
                _ -> {val, false}
              end

            x ->
              case diagram do
                %{^x => v} when is_binary(x) and is_integer(v) -> {v, true}
                _ -> {val, false}
              end
          end

        {new_val, did_op?} = do_op(new_val)
        updated? = updated? or did_op?

        if updated? do
          {put_in(diagram[key], new_val), true}
        else
          {diagram, any_update?}
        end
      end)

    if updated? do
      flow(diagram)
    else
      diagram
    end
  end

  def do_op({:and, a1, a2}) when is_integer(a1) and is_integer(a2), do: {a1 &&& a2, true}
  def do_op({:or, a1, a2}) when is_integer(a1) and is_integer(a2), do: {a1 ||| a2, true}
  def do_op({:lshift, a1, a2}) when is_integer(a1) and is_integer(a2), do: {a1 <<< a2, true}
  def do_op({:rshift, a1, a2}) when is_integer(a1) and is_integer(a2), do: {a1 >>> a2, true}
  def do_op({:not, a1}) when is_integer(a1), do: {bnot(a1), true}
  def do_op(x), do: {x, false}

  def solve1, do: flow(parse_input())["a"]
  def solve2, do: put_in(parse_input()["b"], solve1()) |> flow() |> Map.get("a")
end
