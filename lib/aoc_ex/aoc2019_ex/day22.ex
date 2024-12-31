defmodule AocEx.Aoc2019Ex.Day22 do
  use AocEx.Day, year: 2019, day: 22

  def parsed_input() do
    for line <- input_tokens() do
      case line do
        ["deal", "into", "new", "stack"] ->
          :reverse

        ["deal", "with", "increment", x] ->
          {:incr, String.to_integer(x)}

        ["cut", x] ->
          {:cut, String.to_integer(x)}
      end
    end
  end

  def linear_tx(ops, n, coefs \\ {1, 0})
  def linear_tx(ops, n, {a, b}) when a < 0, do: linear_tx(ops, n, {a + n, b})
  def linear_tx(ops, n, {a, b}) when b < 0, do: linear_tx(ops, n, {a, b + n})
  def linear_tx([], _n, coefs), do: coefs
  def linear_tx([:reverse | rest], n, {a, b}), do: linear_tx(rest, n, {-a, -b - 1})
  def linear_tx([{:cut, i} | rest], n, {a, b}), do: linear_tx(rest, n, {a, rem(b - i, n)})

  def linear_tx([{:incr, i} | rest], n, {a, b}),
    do: linear_tx(rest, n, {rem(a * i, n), rem(b * i, n)})

  def mod_pow(x, pow, mod) do
    :binary.decode_unsigned(:crypto.mod_pow(x, pow, mod))
  end

  def inverse_mod(x, n), do: mod_pow(x, n - 2, n)

  def linear_tx_pwr({a, b}, pow, modn) do
    a_to_pow = mod_pow(a, pow, modn)
    b_to_pow = rem(b * (a_to_pow - 1) * inverse_mod(a - 1, modn), modn)
    {a_to_pow, b_to_pow}
  end

  def invert_linear_op(i, {a, b}, modn) do
    x = rem((i - b) * inverse_mod(a, modn), modn)
    if x < 0, do: x + modn, else: x
  end

  @decksize 10007
  def solve1 do
    inst = parsed_input()
    {a, b} = linear_tx(inst, @decksize)
    rem(a * 2019 + b, @decksize)
  end

  @bigdecksize 119_315_717_514_047
  @iters 101_741_582_076_661
  def solve2 do
    {a, b} =
      linear_tx(parsed_input(), @bigdecksize)
      |> linear_tx_pwr(@iters, @bigdecksize)

    invert_linear_op(2020, {a, b}, @bigdecksize)
  end
end
