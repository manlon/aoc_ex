defmodule AocEx.Aoc2024Ex.Day23 do
  # @example """
  # kh-tc
  # qp-kh
  # de-cg
  # ka-co
  # yn-aq
  # qp-ub
  # cg-tb
  # vc-aq
  # tb-ka
  # wh-tc
  # yn-cg
  # kh-ub
  # ta-co
  # de-co
  # tc-td
  # tb-wq
  # wh-td
  # ta-ka
  # td-qp
  # aq-cg
  # wq-ub
  # ub-vc
  # de-ta
  # wq-aq
  # wq-vc
  # wh-yn
  # ka-de
  # kh-ta
  # co-tc
  # wh-qp
  # tb-vc
  # td-yn
  # """

  def input do
    AocEx.Day.input_file_contents(2024, 23)
    # @example
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, "-", trim: true) |> Enum.sort() end)
    |> MapSet.new()
  end

  def connections(edges, x) do
    Enum.reduce(edges, [], fn pair, acc ->
      case pair do
        [^x, other] -> [other | acc]
        [other, ^x] -> [other | acc]
        _ -> acc
      end
    end)
  end

  def find_clique_3(edges, nodes) do
    Enum.reduce(nodes, [], fn node, acc ->
      Enum.reduce(edges, acc, fn [a, b], acc ->
        if node < a && [node, a] in edges && [node, b] in edges do
          [[node, a, b] | acc]
        else
          acc
        end
      end)
    end)
  end

  def expand_cliques(edges, nodes, cliques) do
    for clique <- cliques, [lowest | _] = clique, reduce: MapSet.new() do
      acc ->
        for node <- nodes,
            node < lowest,
            reduce: acc do
          acc ->
            if Enum.all?(clique, fn clnode -> [node, clnode] in edges end) do
              MapSet.put(acc, [node | clique])
            else
              acc
            end
        end
    end
  end

  def expand_until_biggest(edges, nodes, cliques) do
    if Enum.count(cliques) == 1 do
      cliques
      |> Enum.to_list()
      |> Enum.at(0)
    else
      new_cliques = expand_cliques(edges, nodes, cliques)
      dbg(Enum.count(new_cliques))

      expand_until_biggest(edges, nodes, new_cliques)
    end
  end

  def solve1 do
    edges = input()
    nodes = edges |> Enum.to_list() |> List.flatten() |> Enum.uniq()

    find_clique_3(edges, nodes)
    |> Enum.filter(&Enum.any?(&1, fn s -> String.starts_with?(s, "t") end))
    |> Enum.count()
  end

  def solve2 do
    edges = input()
    nodes = edges |> Enum.to_list() |> List.flatten() |> Enum.uniq()

    cliques = find_clique_3(edges, nodes)

    expand_until_biggest(edges, nodes, cliques)
    |> Enum.join(",")
  end
end
