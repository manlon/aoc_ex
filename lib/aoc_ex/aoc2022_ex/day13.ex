defmodule AocEx.Aoc2022Ex.Day13 do
  use AocEx.Day, year: 2022, day: 13

  def parse_list("", acc), do: hd(Enum.reverse(acc))
  def parse_list("," <> rest, acc), do: parse_list(rest, acc)
  def parse_list("]" <> rest, acc), do: {Enum.reverse(acc), rest}
  def parse_list({last_item, rest}, acc), do: parse_list(rest, [last_item | acc])
  def parse_list("[" <> rest, acc), do: parse_list(parse_list(rest, []), acc)
  def parse_list(s, acc), do: parse_list(consume_num(s, []), acc)

  def consume_num(<<c, rest::binary>>, acc) when c in ?0..?9, do: consume_num(rest, [c | acc])
  def consume_num(s = <<c, _::binary>>, acc) when c in [?,, ?[, ?]], do: {parse_num(acc), s}
  def parse_num(reversed), do: elem(:string.to_integer(Enum.reverse(reversed)), 0)

  def cmp([], []), do: :eq
  def cmp([], r) when is_list(r), do: true
  def cmp(l, []) when is_list(l), do: false
  def cmp([n | l_r], [n | r_r]) when is_integer(n), do: cmp(l_r, r_r)
  def cmp([l | _], [r | _]) when is_integer(l) and is_integer(r), do: l < r
  def cmp([l | l_r], [r | r_r]) when is_integer(l) and is_list(r), do: cmp([[l] | l_r], [r | r_r])
  def cmp([l | l_r], [r | r_r]) when is_list(l) and is_integer(r), do: cmp([l | l_r], [[r] | r_r])
  def cmp([l | l_r], [r | r_r]), do: cmp(l, r) |> then(&if &1 == :eq, do: cmp(l_r, r_r), else: &1)

  def solve1 do
    stanza_lines(map: &parse_list(&1, []))
    |> Enum.with_index()
    |> Enum.filter(fn {[a, b], _} -> cmp(a, b) end)
    |> Enum.map(fn {_, i} -> i + 1 end)
    |> Enum.sum()
  end

  def solve2 do
    {pk1, pk2} = {[[2]], [[6]]}
    inp = [pk1, pk2] ++ Enum.concat(stanza_lines(map: &parse_list(&1, [])))
    sorted = Enum.sort(inp, &cmp/2)
    idx1 = Enum.find_index(sorted, fn i -> i == pk1 end)
    idx2 = Enum.find_index(sorted, fn i -> i == pk2 end)
    (idx1 + 1) * (idx2 + 1)
  end
end
