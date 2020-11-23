# This file is part of https://pabloaguiar.me/post/breadth-first-search-in-elixir/

# Licensed under the BSD-3-Clause license:
# https://opensource.org/licenses/BSD-3-Clause
# Copyright (c) 2020, Pablo S. Blum de Aguiar <scorphus@gmail.com>

defmodule ShortestReach do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> shortest_reach()
  end

  defp shortest_reach(0) do
  end

  defp shortest_reach(q) do
    [n, m] =
      IO.gets("")
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    [nil | edges] = read_edges(nil, m)

    # the start node should be read before adding any
    # edge to avoid adding edges from any node back
    # to the start node, as that would be wasteful
    s =
      IO.gets("")
      |> String.trim()
      |> String.to_integer()

    init_graph(n)
    |> add_edges(edges, s)
    |> bfs(s)
    |> expand_paths(n, s)
    |> Enum.reverse()
    |> Enum.join(" ")
    |> IO.puts()

    shortest_reach(q - 1)
  end

  defp read_edges(edges, 0), do: [edges]

  defp read_edges(edges, m) do
    [
      edges
      | IO.gets("")
        |> String.trim()
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)
        |> read_edges(m - 1)
    ]
  end

  defp init_graph(0), do: %{0 => MapSet.new()}
  defp init_graph(n), do: init_graph(n - 1) |> Map.put(n, MapSet.new())

  defp add_edges(graph, [], _), do: graph

  # add only v as immediate neighbor of s
  defp add_edges(graph, [[s, v] | edges_tail], s) do
    Map.put(graph, s, MapSet.put(graph[s], v))
    |> add_edges(edges_tail, s)
  end

  # add only u as immediate neighbor of s
  defp add_edges(graph, [[u, s] | edges_tail], s) do
    Map.put(graph, s, MapSet.put(graph[s], u))
    |> add_edges(edges_tail, s)
  end

  # add u and v as immediate neighbors of each other
  defp add_edges(graph, [[u, v] | edges_tail], s) do
    Map.put(graph, u, MapSet.put(graph[u], v))
    |> Map.put(v, MapSet.put(graph[v], u))
    |> add_edges(edges_tail, s)
  end

  defp bfs(graph, s) do
    # bootstrap the BFS with:
    # - an empty map
    # - the initialized graph
    # - the list of neighbors of `s`
    # - an empty list of nodes to visit next
    # - the initial layer
    bfs(%{}, graph, MapSet.to_list(graph[s]), [], 1)
  end

  defp bfs(paths, _, [], [], _), do: paths

  defp bfs(paths, graph, [], neighbors, layer) do
    bfs(paths, graph, neighbors, [], layer + 1)
  end

  defp bfs(paths, graph, [u | tail], neighbors, layer) do
    cond do
      Map.has_key?(paths, u) ->
        bfs(paths, graph, tail, neighbors, layer)

      true ->
        Map.put_new(paths, u, layer)
        |> bfs(graph, tail, MapSet.to_list(graph[u]) ++ neighbors, layer)
    end
  end

  defp expand_paths(_, 0, _), do: []

  defp expand_paths(paths, s, s), do: expand_paths(paths, s - 1, s)

  defp expand_paths(paths, n, s) do
    cond do
      Map.has_key?(paths, n) ->
        [paths[n] * 6] ++ expand_paths(paths, n - 1, s)

      true ->
        [-1] ++ expand_paths(paths, n - 1, s)
    end
  end
end

ShortestReach.main()
