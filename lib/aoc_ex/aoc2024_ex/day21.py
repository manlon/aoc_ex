import re
from itertools import pairwise, product

input = """
279A
286A
508A
463A
246A
"""

dir_key_neighbs = {
    "A": [("<", "^"), ("v", ">")],
    "^": [(">", "A"), ("v", "v")],
    ">": [("^", "A"), ("<", "v")],
    "v": [("<", "<"), ("^", "^"), (">", ">")],
    "<": [(">", "v")],
}
numn_key_eighbs = {
    "A": [("<", "0"), ("^", "3")],
    "0": [(">", "A"), ("^", "2")],
    "1": [(">", "2"), ("^", "4")],
    "2": [("<", "1"), (">", "3"), ("^", "5"), ("v", "0")],
    "3": [("<", "2"), ("^", "6"), ("v", "A")],
    "4": [("v", "1"), (">", "5"), ("^", "7")],
    "5": [("v", "2"), ("<", "4"), (">", "6"), ("^", "8")],
    "6": [("v", "3"), ("<", "5"), ("^", "9")],
    "7": [("v", "4"), (">", "8")],
    "8": [("v", "5"), ("<", "7"), (">", "9")],
    "9": [("v", "6"), ("<", "8")],
}


def compute_path_to_dest(keyapd_map, dest, paths):
    newpaths = []
    hits = []
    for path in paths:
        (lastdir, lastkey) = path[-1]
        visited = [m[1] for m in path]
        for dir, key in keyapd_map[lastkey]:
            if key not in visited:
                newpath = path + [(dir, key)]
                if key == dest:
                    hits.append("".join(d for (d, _) in newpath))
                newpaths.append(newpath)
    return hits or compute_path_to_dest(keyapd_map, dest, newpaths)


def precompute_pairwise_paths(map):
    result = {}
    for pair in product(map, map):
        (startloc, endloc) = pair
        if startloc == endloc:
            result[pair] = [""]
        else:
            result[pair] = compute_path_to_dest(map, endloc, [[("", startloc)]])
    return result


NUMPAD_PATHS = precompute_pairwise_paths(numn_key_eighbs)
DIRPAD_PATHS = precompute_pairwise_paths(dir_key_neighbs)


def expand_segment(seg, n, routes, memo):
    if n == 0:
        return len(seg) + 1
    if (seg, n) in memo:
        return memo[(seg, n)]
    expansions = [routes[p] for p in pairwise(f"A{seg}A")]
    c = best_expansion(expansions, n - 1, routes, memo)
    memo[(seg, n)] = c
    return c


def best_expansion(expansion_sets, n, routes, memo):
    return sum(
        min(expand_segment(seg, n, routes, memo) for seg in segment_choices)
        for segment_choices in expansion_sets
    )


def solve(nlevels=2):
    memo = {}
    acc = 0
    for line in input.split():
        seg = line.split("A")[0]
        exps = [NUMPAD_PATHS[p] for p in pairwise(f"A{seg}A")]
        acc += int(seg) * best_expansion(exps, nlevels, DIRPAD_PATHS, memo)
    return acc


print(solve())
print(solve(25))
