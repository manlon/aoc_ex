defmodule AocEx.Aoc2015Ex.Day13 do
  use AocEx.Day, year: 2015, day: 13

  def parsed_input do
    for [name, _, sign, n, _, _, _, _, _, _, neighb] <- input_tokens(),
        reduce: %{} do
      map ->
        sign =
          case sign do
            "gain" -> +1
            "lose" -> -1
          end

        neighb = hd(String.split(neighb, "."))
        hap = sign * String.to_integer(n)
        Map.update(map, name, %{neighb => hap}, &Map.put(&1, neighb, hap))
    end
  end

  def perms(names), do: perms(Enum.reverse(names), [])
  def perms([], order), do: [order]

  def perms(names, order) do
    Stream.flat_map(names, fn name ->
      perms(names -- [name], [name | order])
    end)
  end

  def score(happy, [a, b | rest], acc, first) do
    score(happy, [b | rest], acc + happy[a][b] + happy[b][a], first || a)
  end

  def score(happy, [last], acc, first) do
    acc + happy[first][last] + happy[last][first]
  end

  def solve1 do
    happy = parsed_input()
    names = Map.keys(happy)

    perms(names)
    |> Stream.map(fn perm -> score(happy, perm, 0, nil) end)
    |> Enum.max()
  end

  def solve2 do
    happy = parsed_input()
    names = Map.keys(happy)
    happy = Map.put(happy, "me", %{})

    happy =
      Enum.reduce(names, happy, fn name, happy ->
        Map.update!(happy, "me", &Map.put(&1, name, 0))
        |> Map.update!(name, &Map.put(&1, "me", 0))
      end)

    perms(["me" | names])
    |> Stream.map(fn perm -> score(happy, perm, 0, nil) end)
    |> Enum.max()
  end
end
