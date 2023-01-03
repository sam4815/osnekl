#  osnekl

![in](https://user-images.githubusercontent.com/32017929/210279792-3aad1784-aa35-4c6f-a666-547e4199b283.gif)

## About

Recently I've been working through Jane Street's [OCaml Workshop](https://github.com/sam4815/learn-ocaml-workshop). One of the projects involves building a Snake clone, and it uses [X11](https://en.wikipedia.org/wiki/X_Window_System) for rendering. Though it's relatively simple to work with, the graphics are a little clunky and it comes with an additional system dependency (e.g. XQuartz for Mac users), so I broke my Snake clone out into a standalone app and switched to using [Notty](https://github.com/pqwy/notty) to display the game in the terminal.

## Installation

To build the project, run
```
dune build
```

Then play the game using
```
_build/default/bin/main.exe
```

## Controls
<kbd>w</kbd><kbd>a</kbd><kbd>s</kbd><kbd>d</kbd> or <kbd>&#8593;</kbd><kbd>&#8592;</kbd><kbd>&#8595;</kbd><kbd>&#8594;</kbd> to move

<kbd>Space</kbd> to accelerate

<kbd>r</kbd> to restart

<kbd>Esc</kbd> to quit

## Resources
1. https://github.com/cedlemo/OCaml-Notty-introduction
