[
    recurse(.nodes[], .floating_nodes[])
    | select(.app_id == "gitg")
    | "\(.rect.x),\(.rect.y)"
]
| .[0]
