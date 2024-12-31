defmodule AocEx.Aoc2019Ex.Day04 do
  def input_range do
    234_208..765_869
  end

  def go do
    {Enum.count(input_range(), fn i -> valid?(Integer.digits(i)) end),
     Enum.count(input_range(), fn i ->
       digits = Integer.digits(i)
       valid?(digits) && has_pair?(digits)
     end)}
  end

  def part1 do
    elem(go(), 0)
  end

  def part2 do
    elem(go(), 1)
  end

  def valid?(digits, saw_dupe? \\ false)
  def valid?([a, b | _], _) when a > b, do: false
  def valid?([a, a | rest], _), do: valid?([a | rest], true)
  def valid?([_], saw_dupe?), do: saw_dupe?
  def valid?([_ | tail], saw_dupe?), do: valid?(tail, saw_dupe?)

  def has_pair?([d, d, d | rest]), do: has_pair?(Enum.drop_while(rest, &(&1 == d)))
  def has_pair?([d, d | _]), do: true
  def has_pair?([_ | rest]), do: has_pair?(rest)
  def has_pair?([]), do: false
end

"""



  def consume([el | rest], el), do: consume(rest, el)
  def consume(list, _), do: list

  def has_pair?([d, d, d | rest]), do: has_pair?(consume(rest, d))


  def go_single do
    input_range()
    |> Enum.reduce({0, 0}, fn i, {valid_part_1, valid_part_2} ->
      digits = Integer.digits(i)
      if valid?(digits) do
        if has_pair?(digits) do
          {valid_part_1 + 1, valid_part_2 + 1}
        else
          {valid_part_1 + 1, valid_part_2}
        end
      else
        {valid_part_1, valid_part_2}
      end
    end)
  end

  def go2 do
    {min, max} = input()
    {c1, valids} = min..max
                   |> Enum.reduce({0, []}, fn i, acc={count, list} ->
                     digits = Integer.digits(i)
                     if valid?(digits) do
                       {count + 1, [digits | list]}
                     else
                       acc
                     end
                   end)
    c2 = Enum.count(valids, &has_pair?/1)
    {c1, c2}
  end

  def go3 do
    {min, max} = input()
    p1 = min..max
         |> Enum.count(fn i -> valid?(Integer.digits(i)) end)
    p2 = min..max
         |> Enum.count(fn i ->
           digits = Integer.digits(i)
           valid?(digits) && has_pair?(digits)
         end)
    {p1, p2}
  end
"""
