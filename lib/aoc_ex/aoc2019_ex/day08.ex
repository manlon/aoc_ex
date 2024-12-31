defmodule AocEx.Aoc2019Ex.Day08 do
  defmacro dbg!(clause) do
    quote do
      label = "[#{__ENV__.file}:#{__ENV__.line}] #{unquote(Macro.to_string(clause))}"
      IO.inspect(unquote(clause), label: label)
    end
  end

  def input do
    AocEx.Day.input_file_contents(2019, 8)
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(25 * 6)
  end

  def part1 do
    counted =
      input()
      |> Enum.map(fn x ->
        {Enum.count(x, fn i -> i == 0 end), x}
      end)

    min =
      counted
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.min()

    {_, best} = Enum.find(counted, fn {c, _} -> c == min end)

    [ones, twos] =
      Enum.map([1, 2], fn x ->
        Enum.count(best, fn i -> x == i end)
      end)

    ones * twos
  end

  def part2 do
    _image =
      input()
      |> compute_pixel([])
      |> Enum.chunk_every(25)
      |> print_image
  end

  def print_image(image) do
    Enum.map(image, fn row ->
      Enum.map(row, fn pixel ->
        if pixel == 1 do
          "#"
        else
          " "
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def compute_pixel([[] | _], result) do
    result
  end

  def compute_pixel(layers, result) do
    heads = Enum.map(layers, &hd/1)
    tails = Enum.map(layers, &tl/1)
    pixel = Enum.find(heads, fn i -> i != 2 end)
    compute_pixel(tails, result ++ [pixel])
  end
end
