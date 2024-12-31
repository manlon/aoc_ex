defmodule AocEx.Aoc2016Ex.Day21 do
  use AocEx.Day, year: 2016, day: 21
  import Enum, only: [reverse: 1, zip: 2, join: 1]
  import String, only: [slice: 2, slice: 3, graphemes: 1]

  @initial "abcdefgh"

  def parsed_input do
    for {s, ints} <- zip(input_lines(), input_line_ints()) do
      case {s, ints} do
        {"swap position" <> _, [x, y]} ->
          {:swap_pos, x, y}

        {<<"swap letter ", x::binary-size(1), " with letter ", y::binary-size(1)>>, _} ->
          {:swap_letters, x, y}

        {"rotate left" <> _, [x]} ->
          {:rot_left, x}

        {"rotate right" <> _, [x]} ->
          {:rot_right, x}

        {<<"rotate based on position of letter ", c::binary-size(1)>>, _} ->
          {:rot_letter, c}

        {"reverse" <> _, [x, y]} ->
          {:reverse, x, y}

        {"move" <> _, [x, y]} ->
          {:move, x, y}
      end
    end
  end

  def do_inst(s, {:swap_pos, x, y}) do
    if y < x do
      do_inst(s, {:swap_pos, y, x})
    else
      slice(s, 0, x) <>
        slice(s, y, 1) <>
        slice(s, (x + 1)..(y - 1)//1) <>
        slice(s, x, 1) <>
        slice(s, (y + 1)..-1)
    end
  end

  def do_inst(s, {:swap_letters, a, b}) do
    graphemes(s)
    |> Enum.map(fn c ->
      case c do
        ^a -> b
        ^b -> a
        _ -> c
      end
    end)
    |> join()
  end

  def do_inst(s, {:rot_left, 0}), do: s

  def do_inst(<<c::binary-size(1), rest::binary>>, {:rot_left, n}) do
    do_inst(rest <> c, {:rot_left, n - 1})
  end

  def do_inst(s, {:rot_right, 0}), do: s

  def do_inst(s, {:rot_right, n}) do
    pref = String.slice(s, 0..-2//-1)
    c = String.slice(s, -1..-1)
    do_inst(c <> pref, {:rot_right, n - 1})
  end

  def do_inst(s, {:rot_letter, a}) do
    idx =
      Enum.find_index(graphemes(s), fn c -> c == a end)

    rots =
      if idx >= 4 do
        idx + 2
      else
        idx + 1
      end

    do_inst(s, {:rot_right, rots})
  end

  def do_inst(s, {:reverse, x, y}) do
    String.slice(s, 0, x) <>
      join(reverse(graphemes(slice(s, x..y)))) <>
      String.slice(s, y + 1, String.length(s) - y)
  end

  def do_inst(s, {:move, x, y}) do
    c = String.at(s, x)
    s = slice(s, 0, x) <> slice(s, x + 1, String.length(s) - (x + 1))
    slice(s, 0, y) <> c <> slice(s, y, String.length(s) - y)
  end

  def do_rev(s, inst = {:swap_pos, _, _}), do: do_inst(s, inst)
  def do_rev(s, inst = {:swap_letters, _, _}), do: do_inst(s, inst)
  def do_rev(s, {:rot_left, x}), do: do_inst(s, {:rot_right, x})
  def do_rev(s, {:rot_right, x}), do: do_inst(s, {:rot_left, x})
  def do_rev(s, {:reverse, x, y}), do: do_inst(s, {:reverse, x, y})
  def do_rev(s, {:move, x, y}), do: do_inst(s, {:move, y, x})
  # TODO
  def do_rev(s, {:rot_letter, x}) do
    Enum.reduce_while(1..(String.length(s) + 1), s, fn i, _ ->
      ss = do_inst(s, {:rot_left, i})

      if do_inst(ss, {:rot_letter, x}) == s do
        {:halt, ss}
      else
        {:cont, ss}
      end
    end)
  end

  def solve1 do
    Enum.reduce(parsed_input(), @initial, fn inst, s ->
      do_inst(s, inst)
    end)
  end

  @scrambled "fbgdceah"

  def solve2 do
    insts = reverse(parsed_input())

    Enum.reduce(insts, @scrambled, fn inst, s ->
      do_rev(s, inst)
    end)
  end
end
