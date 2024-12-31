defmodule AocEx.Aoc2024Ex.Day25 do
  def input do
    AocEx.Day.input_file_contents(2024, 25)
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn block ->
      lines = String.split(block, "\n", trim: true)
      typ = if String.starts_with?(hd(lines), "."), do: :key, else: :lock

      sizes =
        for line <- lines,
            reduce: %{} do
          acc ->
            for {c, i} <- Enum.with_index(String.graphemes(line)),
                c == "#",
                reduce: acc do
              acc ->
                Map.update(acc, i, 1, &(&1 + 1))
            end
        end
        |> Enum.to_list()
        |> Enum.sort()
        |> Enum.map(&elem(&1, 1))
        |> Enum.map(fn x -> x - 1 end)

      {typ, sizes}
    end)
  end

  def fit?(lock, key) do
    Enum.zip(lock, key)
    |> Enum.all?(fn {l, k} -> l + k <= 5 end)
  end

  def solve1 do
    inp = input()
    keys = Enum.filter(inp, fn {typ, _} -> typ == :key end)
    locks = Enum.filter(inp, fn {typ, _} -> typ == :lock end)

    for {:lock, lock} <- locks,
        {:key, key} <- keys,
        fit?(lock, key),
        reduce: 0 do
      acc -> acc + 1
    end
  end
end
