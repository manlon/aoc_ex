defmodule AocEx.Aoc2024Ex.Day09 do
  def input do
    AocEx.Day.input_file_contents(2024, 9)
    # "2333133121414131402"
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def input_marked do
    Enum.zip(Stream.cycle([:file, :free]), input())
    |> Enum.reduce({0, []}, fn {typ, n}, {i, acc} ->
      case typ do
        :file -> {i + 1, [{:file, i, n} | acc]}
        :free -> {i, [{:free, n} | acc]}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  def solve1 do
    inp = input_marked()

    q = :queue.from_list(inp)

    compactify(q, [])
    |> score()
  end

  def solve2 do
    inp = input_marked()

    q = :queue.from_list(inp)

    compactify_whole(q, [])
    |> combine_space([])
    |> score
  end

  def score(blocks) do
    Stream.flat_map(blocks, fn
      {:file, id, n} ->
        Stream.cycle([id]) |> Stream.take(n)

      {:free, n} ->
        Stream.cycle([0]) |> Stream.take(n)
    end)
    |> Stream.with_index()
    |> Stream.map(fn {i, j} -> i * j end)
    |> Enum.sum()
  end

  def compactify(q, acc) do
    {item, q} = :queue.out(q)

    case item do
      :empty ->
        Enum.reverse(acc)

      {:value, block} ->
        case block do
          {:file, _i, _n} ->
            compactify(q, [block | acc])

          {:free, _num_free} ->
            compactify_space(q, block, acc)
        end
    end
  end

  def compactify_space(q, _block = {:free, 0}, acc) do
    compactify(q, acc)
  end

  def compactify_space(q, block = {:free, num_free}, acc) do
    {item, q} = :queue.out_r(q)

    case item do
      :empty ->
        Enum.reverse(acc)

      {:value, last_block} ->
        case last_block do
          {:free, _} ->
            compactify_space(q, block, acc)

          file_block = {:file, i, n} ->
            if num_free >= n do
              remaining_free = {:free, num_free - n}
              q = :queue.in_r(remaining_free, q)
              compactify(q, [file_block | acc])
            else
              moved_file = {:file, i, num_free}
              remaining_file = {:file, i, n - num_free}
              q = :queue.in(remaining_file, q)
              compactify(q, [moved_file | acc])
            end
        end
    end
  end

  def compactify_whole(q, acc) do
    case :queue.out_r(q) do
      {:empty, _} ->
        Enum.reverse(acc)

      {{:value, block = {:free, _}}, q} ->
        compactify_whole(q, [block | acc])

      {{:value, block = {:file, _i, n}}, q} ->
        if :queue.any(
             fn
               {:free, num_free} -> num_free >= n
               {:file, _, _} -> false
             end,
             q
           ) do
          q = fill_space(q, block)
          compactify_whole(q, acc)
        else
          compactify_whole(q, [block | acc])
        end
    end
  end

  def fill_space(q, file_to_move = {:file, _i, n}) do
    :queue.to_list(q)
    |> Enum.reduce({[], false}, fn
      block, {acc, true} ->
        {[block | acc], true}

      free_block = {:free, numfree}, {acc, _moved? = false} ->
        if numfree >= n do
          {[{:free, numfree - n}, file_to_move | acc], true}
        else
          {[free_block | acc], false}
        end

      existing_file, {acc, false} ->
        {[existing_file | acc], false}
    end)
    |> then(fn {acc, true} ->
      new_spaces = {:free, n}

      combine_space([new_spaces | acc], [])
      |> :queue.from_list()
    end)
  end

  # reverses
  def combine_space([{:free, a}, {:free, b} | rest], acc),
    do: combine_space([{:free, a + b} | rest], acc)

  def combine_space([blk | rest], acc), do: combine_space(rest, [blk | acc])
  def combine_space([], acc), do: acc
end
