#  osnekl

## About

I've been working through Jane Street's [OCaml Workshop](https://github.com/sam4815/learn-ocaml-workshop). One of the projects - building a snake clone - uses [X11](https://en.wikipedia.org/wiki/X_Window_System) for rendering, which has been a little clunky to work with on a Mac, so I broke out my Snake clone into a standalone app using [Notty](https://github.com/pqwy/notty) to display the game in the terminal.

## Installation

To build the project, run
```
dune build
```

Then play the game using
```
_build/default/bin/main.exe
```

## Resources
1. https://github.com/cedlemo/OCaml-Notty-introduction
