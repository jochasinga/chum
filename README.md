# chum 🚧

A friendly WASM compiler for scheme (experimental).

## run

```shell
$ guile
> GNU Guile 3.0.9
> Copyright (C) 1995-2023 Free Software Foundation, Inc.
>
> Guile comes with ABSOLUTELY NO WARRANTY; for details type `,show w'.
> This program is free software, and you are welcome to redistribute it
> under certain conditions; type `,show c' for details.
>
> Enter `,help' for help.
> scheme@(guile-user)> (load "compiler.scm")
> scheme@(guile-user)> (compile-and-run '(primcall integer? 3))
>> #t
> scheme@(guile-user)> (compile-and-run '(primcall + 3 2))
>> int: 5
```

Instead of compiling to x86 Assembly, chum compiles to hand-rolled WAT program and gets executed by the [runtime](https://github.com/jochasinga/chum-runtime).

Running `compile-to-wasm` procedure will compile an expression to a corresponding WAT in `modules/compiled.wat` without compiling to WASM binary and running.

```shell
> scheme@(guile-user)> (load "compiler.scm")
> scheme@(guile-user)> (compile-to-wasm #\a)
```

To invoke the runtime, run `compile-and-run`:

```shell
> scheme@(guile-user)> (load "compiler.scm")
> scheme@(guile-user)> (compile-and-run #\a)
>> char: a
```

## components

### [compiler](compiler.scm)

Does most of the work. Use tagged pointers to determine types such as fix-num, boolean, and character. Emit the source code in **Webassembly Text Format (WAT)** in [`modules/compiled.wat`](modules/compiled.wat).

### [runtime](./rts)

Rust runtime that links a bunch of WAT modules together, convert the tagged binaries into the corresponding types, and simply print them out.

### [lib](./modules/lib)

Helper functions written in WAT.

## movitation

I started coding from literature, thus writing computer code has been nothing short of writing a novel for computers. Writing a compiler for a programming language is one of my programming epitaphs I've always wanted the time to work on.

Lisp (and in effect, Scheme) is, in my opinion, the most expressive computer language humanity has ever created.

Moreover, the [homoiconicity](https://en.wikipedia.org/wiki/Homoiconicity#:~:text=A%20language%20is%20homoiconic%20if,language%20treats%20code%20as%20data.)<sup>1</sup> of Lisp makes it possible to skip the parsing process of a compiler.

This project is also overwhelmingly inspired by [An Incremental Approach to Compiler Construction](http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf)<sup>2</sup> and [Let's Build a Compiler Series](https://generalproblem.net/lets_build_a_compiler/01-starting-out/)<sup>3</sup>.

> 1) I wish we could stop linking Wikipedia. It's at the point where it's just downright scaring learners away.
> 2) An Incremental Approach to Compiler Construction, Abdulazia Ghuloum
> 3) Let's Build a Compiler, Noah Zentzis
