# git repo diagrams

Hacky but stable [`git`](https://git-scm.com/) repository diagram generator using [`gitg`](https://wiki.gnome.org/Apps/Gitg), [`Xvfb`](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml), and [`imagemagick`](https://imagemagick.org/).

There's also a simple [`graphviz`](https://graphviz.org/) template for visualizing git branching models.

## Requirements:

- `git`
- `gitg`
- `Xvfb`
- `imagemagick`
- `python3`
- [`ninja`](https://ninja-build.org/) (optional)

## Running

With `ninja`:

```sh
ninja
```

Without `ninja`:

```sh
sh create_history.sh
dot -Gdpi=200 -Tpng -ooverview.dot overview.png
dot -Gdpi=200 -Tsvg -ooverview.svg overview.svg
```

## Output

### git repo diagram

![git repo diagram example](https://raw.githubusercontent.com/qguv/git-repo-diagrams/examples/005.png)

### Branching model diagram

![branching model diagram example](https://raw.githubusercontent.com/qguv/git-repo-diagrams/examples/overview.png)
