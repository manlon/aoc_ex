defmodule AocEx.Aoc2016Ex.Day14 do
  use AocEx.Day, year: 2016, day: 14
  @salt "zpqevtbw"
  #  @salt "abc"

  def get_triplet(<<c, c, c, _::binary>>), do: <<c>>
  def get_triplet(<<_, rest::binary>>), do: get_triplet(rest)
  def get_triplet(""), do: nil

  def find_key(hashes = [{n, _} | _], nth, rehash) when length(hashes) < 1100 do
    new_hash_start = length(hashes) + n

    new_hashes =
      new_hash_start..(new_hash_start + 1000)
      |> Enum.map(fn i -> {i, hashn(i, rehash)} end)

    find_key(hashes ++ new_hashes, nth, rehash)
  end

  def find_key([{n, hash} | rest], nth, rehash) do
    case get_triplet(hash) do
      nil ->
        find_key(rest, nth, rehash)

      c ->
        five = String.duplicate(c, 5)

        match =
          Enum.reduce_while(rest, 0, fn {_, hash}, i ->
            cond do
              i >= 1000 ->
                {:halt, nil}

              String.contains?(hash, five) ->
                {:halt, hash}

              true ->
                {:cont, i + 1}
            end
          end)

        case match do
          nil ->
            find_key(rest, nth, rehash)

          _hash ->
            if nth == 1 do
              n
            else
              find_key(rest, nth - 1, rehash)
            end
        end
    end
  end

  def hashn(n, rehash_times), do: hash(hash("#{@salt}#{n}"), rehash_times)
  def hash(s, 0), do: s
  def hash(s, n), do: hash(hash(s), n - 1)
  def hash(s), do: :erlang.md5(s) |> Base.encode16(case: :lower)

  def solve1 do
    find_key([{0, hashn(0, 0)}], 64, 0)
  end

  def solve2 do
    find_key([{0, hashn(0, 2016)}], 64, 2016)
  end
end
