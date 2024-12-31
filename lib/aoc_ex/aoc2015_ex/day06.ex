defmodule AocEx.Aoc2015Ex.Day06 do
  use AocEx.Day, year: 2015, day: 6
  import Enum, only: [map: 2, flat_map: 2]

  def parse_input do
    for line <- input_lines(),
        [x1, y1, x2, y2] = line_ints(line),
        r = {{x1, x2}, {y1, y2}} do
      case line do
        "turn on" <> _ -> {:on, r}
        "turn off" <> _ -> {:off, r}
        "toggle" <> _ -> {:toggle, r}
      end
    end
  end

  def apply_rule(inst, cur) do
    case {inst, cur} do
      {:on, _} -> :on
      {:off, _} -> :off
      {:toggle, :on} -> :off
      {:toggle, :off} -> :on
    end
  end

  def apply_rule2(inst, cur) do
    case inst do
      :on -> cur + 1
      :off -> max(cur - 1, 0)
      :toggle -> cur + 2
    end
  end

  def process([], regions, _rule_fn), do: regions

  def process([_rule = {inst, irange} | rest], regions, rule_fn) do
    regions =
      decompose(regions, irange)
      |> map(fn r = {range, status} ->
        if covers?(irange, range) do
          {range, rule_fn.(inst, status)}
        else
          r
        end
      end)

    process(rest, regions, rule_fn)
  end

  def covers?(_irange = {{x1, x2}, {y1, y2}}, {{tx1, tx2}, {ty1, ty2}}) do
    x1 <= tx1 and x2 >= tx2 and y1 <= ty1 and y2 >= ty2
  end

  def decompose(regions, _instruction_range = {{x1, x2}, {y1, y2}}) do
    flat_map(regions, fn r ->
      [r]
      |> flat_map(fn r = {{{rx1, rx2}, {ry1, ry2}}, status} ->
        if x1 in (rx1 + 1)..rx2//1 and y1 <= ry2 and y2 >= ry1 do
          [{{{rx1, x1 - 1}, {ry1, ry2}}, status}, {{{x1, rx2}, {ry1, ry2}}, status}]
        else
          [r]
        end
      end)
      |> flat_map(fn r = {{{rx1, rx2}, {ry1, ry2}}, status} ->
        if x2 in rx1..(rx2 - 1)//1 and y1 <= ry2 and y2 >= ry1 do
          [{{{rx1, x2}, {ry1, ry2}}, status}, {{{x2 + 1, rx2}, {ry1, ry2}}, status}]
        else
          [r]
        end
      end)
      |> flat_map(fn r = {{{rx1, rx2}, {ry1, ry2}}, status} ->
        if y1 in (ry1 + 1)..ry2//1 and x1 <= rx2 and x2 >= rx1 do
          [{{{rx1, rx2}, {ry1, y1 - 1}}, status}, {{{rx1, rx2}, {y1, ry2}}, status}]
        else
          [r]
        end
      end)
      |> flat_map(fn r = {{{rx1, rx2}, {ry1, ry2}}, status} ->
        if y2 in ry1..(ry2 - 1)//1 and x1 <= rx2 and x2 >= rx1 do
          [{{{rx1, rx2}, {ry1, y2}}, status}, {{{rx1, rx2}, {y2 + 1, ry2}}, status}]
        else
          [r]
        end
      end)
    end)
  end

  def solve1 do
    inp = parse_input()
    start = {{{0, 999}, {0, 999}}, :off}

    for {{xrange, yrange}, :on} <- process(inp, [start], &apply_rule/2),
        {x1, x2} = xrange,
        {y1, y2} = yrange do
      (x2 - x1 + 1) * (y2 - y1 + 1)
    end
    |> Enum.sum()
  end

  def solve2 do
    inp = parse_input()
    start = {{{0, 999}, {0, 999}}, 0}

    for {{xrange, yrange}, bright} <- process(inp, [start], &apply_rule2/2),
        {x1, x2} = xrange,
        {y1, y2} = yrange do
      (x2 - x1 + 1) * (y2 - y1 + 1) * bright
    end
    |> Enum.sum()
  end
end
