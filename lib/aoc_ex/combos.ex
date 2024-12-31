defmodule AocEx.Combos do
  import Stream, only: [drop: 2, transform: 3, map: 2]
  import Enum, only: [take: 2, empty?: 1]

  def combo_stream(_, 0), do: [[]]
  def combo_stream(enum, n), do: transform(resolve_drop(enum), rest_of(enum), reducer(n))

  defp reducer(n), do: &reducer(&1, &2, n)
  defp reducer(_, :halt, _n), do: {:halt, []}
  defp reducer(item, rest, n), do: {map(combo_stream(rest, n - 1), &[item | &1]), rest_of(rest)}

  defp drop_help({:drop, n, enum}), do: {:drop, n + 1, enum}
  defp drop_help(enum = %Stream{}), do: {:drop, 1, enum}
  defp drop_help(enum = %{}), do: Enum.to_list(enum) |> drop_help()
  defp drop_help(enum) when is_list(enum), do: tl(enum)
  defp drop_help(enum), do: {:drop, 1, enum}

  defp resolve_drop({:drop, n, enum}), do: drop(enum, n)
  defp resolve_drop(enum), do: enum

  defp rest_of(enum) do
    if empty?(take(resolve_drop(enum), 1)) do
      :halt
    else
      drop_help(enum)
    end
  end

  def pairs(enum) do
    Stream.unfold(Enum.to_list(enum), fn
      [] -> nil
      [i | rest] -> {{i, rest}, rest}
    end)
    |> Stream.flat_map(fn {i, rest} -> Stream.map(rest, fn j -> [i, j] end) end)
  end

  def combos(_, 0), do: [[]]
  def combos([], _), do: []
  def combos([h | t], m), do: for(l <- combos(t, m - 1), do: [h | l]) ++ combos(t, m)
end
