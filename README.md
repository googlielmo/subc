
SubC Compiler
=============

    By Nils M Holm, 2011—2016 
    Placed in the public domain

The original
[SubC compiler](http://www.t3x.org/subc/)
is described in the excellent book
[Practical Compiler Construction](http://www.t3x.org/reload/index.html)
by Nils M Holm.

The current version starts out from the latest compiler code
available from Nils' website:
[subc-20161212.tgz](http://www.t3x.org/subc/subc-20161212.tgz).


WHAT'S NEW
----------

Updated by Guglielmo Nigri
([@googlielmo](https://github.com/googlielmo)), 2021.

Source code available at: https://github.com/googlielmo/subc

- Darwin target now *stable* (tested on macOS 10.15 and 11.1)
- Ongoing work to update Linux x86-64 target to the latest tool 
  chain
- Docker support

The rest of this document is being updated to track the ongoing
development.

Please see [README_ORIG](README_ORIG) for the original README.


SUMMARY
-------

SubC is a compiler for a (mostly) strict and sane subset of
C as described in "The C Programming Language", 2nd Ed (also
known informally as "ANSI C" or "C89").

A previous version of the compiler is described in great detail
in the book "Practical Compiler Construction", which can be
purchased at Lulu.com. See  http://www.t3x.org/reload/  for
ordering information.

The SubC compiler can compile itself. Unlike many other small C
compilers, it does not bend the rules, though. Its code passes
`gcc -Wall -pedantic` with little or no warnings (depending on
the gcc version used). Of course, you can also bootstrap it with
other C compilers, such as Clang or PCC.

SubC is fast and simple. Its output is statically linked (where
available) and typically small due to a non-bloated library). It
uses a simple optimizer on per-expression basis.


QUICKSTART
----------

On supported systems this is the quickest way to compile and
install the `scc` compiler.

Make sure you have the system C compiler on your path.

Configure the target system:

      make configure

Bootstrap the SubC compiler to check everything is in order:

      make scc

Install the compiler:

      make install

Of course, you can also build and install manually.
See below for detailed instructions.


SUPPORTED SYSTEMS
-----------------

SubC generates code for GAS, the GNU assembler (except for the
DOS version, which emits TASM-style syntax). It targets the
following processors and operating systems:

    FreeBSD		386	armv6	x86-64
    Linux		386	-	x86-64
    NetBSD		386	-	x86-64
    OpenBSD		386%	-	-
    Windows/MinGW	386	-	-
    Darwin		-	-	x86-64%
    DOS		8086!

      %  uses the syscall layer of the host libc
      *  untested
      !  experimental
     (/) broken

Platforms tagged "untested" are not regularly tested by myself
and are therefore subject to potential bit rot. You can help
me improve SubC by running `make tests` on an "untested"
platform and let me know about the results.

Platforms using the system's libc as a thin system call layer
often cause build/stability problems due to the omnipresence of
the GNU libc, which is not "thin" at all. Expect trouble on
those systems!

On Darwin/macOS the system libc is being used (not the GNU libc),
which is linked dynamically and is actually required for
issuing system calls in a portable way.

Platforms tagged "broken" currently will not compile or run
properly for some reason. See the Todo file for details.

The DOS version brings its own toolchain, which can be found in
the s86/ directory, so no pre-existing DOS assembler or linker
is required to compile SubC programs on DOS.

Porting SubC to other 32-bit or 64-bit platforms should be
quite straight-forward. See the file "Porting" and/or the book
for a general road map.


CHANGES TO THE BOOK VERSION
---------------------------

Note: The book version runs on FreeBSD/386 exclusively.

The current version uses an improved code generator, which
emits much smaller and faster code than the book compiler.
The techniques are described in the book, though.

The current version of the SubC compiler adds support for
the following parts of C language to the version described
in "Practical Compiler Construction":

*  `&array` is now valid syntax (you no longer have to write
   `&array[0]`).

*  the `auto`, `register`, and `volatile` keywords are recognized
   (as no-ops). Yes, volatile is safe, because SubC does not
   have register variables.

*  enums may now be local.

*  extern identifiers may now be declared locally.

*  Prototypes may have the `static` storage class.

*  There is support for `struct` and `union` data types.

*  `jmp_buf` is now a struct; `setjmp()` and `longjmp()` must be
   called with `&jmp_buf`.

*  FILEs are now structs and can no longer be mistaken for
   ints by the type checker.

*  The `#error`, `#line`, and `#pragma` commands have been added.

*  There is a (non-standard) `kprintf()` function, which is
   like `fprintf()`, but uses a file descriptor.

*  There is now a (slightly incompatible) varargs mechanism.
   Here is how it works:

```c
   #include <varargs.h>
   
   void p(int a, int b, ...) {
     int	first;
     void	*ap;
   
     ap = _va_start(&b);
     first = (int) _va_arg(&ap);
     vprintf("other args: %d %d %d\n", ap);
     _va_end(&ap);
   }
```

*  The `vprintf()`, `vfprintf()`, and `vsprintf()` functions have
   been added to the runtime library.

*  A broader subset of C expression syntax is accepted
   in constant expression contexts. For example, pointer
   variables can be initialized with NULL.


DIFFERENCES BETWEEN SUBC (THIS VERSION) AND FULL C89
----------------------------------------------------

*  The following keywords are not recognized:
   `const`, `double`, `float`, `goto`, `long`, `short`,
   `signed`, `typedef`, `unsigned`.

*  There are only two primitive data types: the signed `int` and
   the unsigned `char`; there are also void pointers, and there
   is limited support for `int(*)()` (pointers to functions
   of type int).

*  No more than two levels of indirection are supported, and
   arrays are limited to one dimension, i.e. valid declarators
   are limited to `x`, `x[]`, `*x`, `*x[]`, `**x` (and `(*x)()`).

*  K&R-style function declarations (with parameter declarations
   between the parameter list and function body) are not
   accepted.

*  There are no `const` variables.

*  There is no `typedef`.

*  There are no unsigned integers, long integers, or signed
   chars.

*  Struct/union declarations must be separate from the
   declarations of struct/union objects, i.e.
   `struct p { int x, y; } q;` will not work.

*  Struct/union declarations must be global (struct and union
   objects may be declared locally, though).

*  There is no support for bit fields.

*  Only ints, chars, and arrays of int and char can be
   initialized in their declarations; pointers can be
   initialized with 0 or NULL.

*  Local arrays cannot have initializers.

*  Local declarations are limited to the beginnings of function
   bodies (they do not work in other compound statements).

*  Arguments of prototypes must be named.

*  There is no `goto`.

*  There are no parameterized macros.

*  The `#if` and `#elif` preprocessor commands are not recognized.

*  The preprocessor does not accept multi-line commands.

*  The preprocessor does not accept comments in (some) commands.

*  The preprocessor does not recognize the `#` and `##` operators.

*  There may not be any blanks between the `#` that introduces
   a preprocessor command and the subsequent command (e.g.:
   `# define` would not be recognized as a valid command).

*  The `sizeof` operator requires parentheses.

*  Subscripting an integer with a pointer (e.g. `1["foo"]`) is
   not supported.

*  Function pointers are limited to one single type, `int(*)()`,
   and they have no argument types. Note that this declaration
   will in fact generate a pointer to `int(*)(void)`.

*  There is no `assert()` due to the lack of parameterized macros.

*  The `atexit()` mechanism is limited to one function (this may
   even be covered by TCPL2).

*  The `signal()` function returns int due to the lack of a more
   sophisticated type system; the return value must be casted to
   `int(*)()` manually.

*  Most of the time-related functions are missing, in particular:
   `asctime()`, `gmtime()`, `localtime()`, `mktime()`,
   and `strftime()`.

*  The `clock()` function is missing, because `CLOCKS_PER_SEC`
   varies among systems.

*  The `ctime()` function ignores the time zone.

*  The varargs mechanism is slightly incompatible.

*  The SubC compiler accepts `//` comments in addition to `/* */`.


SELECTING A TARGET PLATFORM
---------------------------

The easiest way to prepare a build is to run the `configure`
script in this directory (`make configure` also works).

Don't worry, it is just a simple script that will figure out
the host platform via uname and link a few machine-dependent 
files into place.

If you want to configure the compiler manually: select one of
the target descriptions (cg*.c) files in `src/targets/cg` and
symlink it to `src/cg.c`. Also link the corresponding header
file into place:

    (cd src && ln -fs targets/cg/cg386.c cg.c)
    (cd src && ln -fs targets/cg/cg386.h cg.h)

Next select the C startup (crt0) file for your OS and CPU type
from `src/targets/OS-CPU/` and link it to `src/lib/crt0.s`, e.g.:

    (cd src/lib && \
     ln -fs ../targets/freebsd-386/crt0-freebsd-386.s \
        crt0.s)

If your OS/CPU combination is not supported, you might try
to port the compiler. See the file "Porting" for details.

You will also need some operating system-dependent
definitions, which are kept in files named `sys-OS-CPU.h`
in `src/targets/OS-CPU/`. Just symlink the appropriate file
to `src/sys.h`:

    (cd src && \
     ln -fs targets/freebsd-386/sys-freebsd-386.h sys.h)

Finally, select a `limits-*.h` file from `targets/include/` that
reflects the machine word size of your target and link it to
`src/include/limits.h`:

    (cd src/include && \
     ln -fs ../targets/include/limits-32.h limits.h)


COMPILING THE COMPILER
----------------------

The compiler sources are contained in the `src` directory,
so all the subsequent steps assume that this is your current
working directory. (I.e. do a `cd src` now.)

On a supported system, just type `make scc`.

Without `make` the compiler can be bootstrapped by running:

    cc -o scc0 *.c

To compile and package the runtime library:

    ./scc0 -c lib/*.c
    ar -rc lib/libscc.a lib/*.o
    ranlib lib/libscc.a

To compile the startup module:

    as -o lib/crt0.o lib/crt0.s

To test the compiler, either run `make test` or perform the
following steps:

    ./scc0 -o scc1 *.c
    ./scc1 -o scc *.c
    cmp scc1 scc

There should not be any differences between the `scc1` and `scc`
executables.


INSTALLING THE COMPILER
-----------------------

The easy way would be to set up the PREFIX (and optionally
SCCDIR and BINDIR) variables in `src/Makefile` to suit your
taste and then run

    make dirs	# to create the directories
    make install

If you want to install the SubC compiler manually, you will
have to change the `SCCDIR` variable in the compiler itself.
It points to the base directory which will contain the SubC
headers and runtime library. `SCCDIR` defaults to ".", but can
be overridden on the command line:

    ./scc1 -o scc -D 'SCCDIR="INSTALLDIR"' *.c

(where `INSTALLDIR` is where the compiler will be installed.)

You can place the `scc` executable wherever you want, as long
as its location is covered by the PATH environment variable.
The headers (`include/*`) go to `INSTALLDIR/include`, the library
`lib/libscc.a` and the startup module `lib/crt0.o` go to
`INSTALLDIR/lib`.

To test the installation just re-compile the compiler:

    rm scc && scc -o scc *.c


DOS SUPPORT
-----------

Please see the NOTES-DOS file!


WINDOWS SUPPORT
---------------

Please see the NOTES-WINDOWS file!


THANKS
------

To the Super Dimension Fortress (SDF.ORG) for providing
free shell accounts on 64-bit NetBSD machines.

To Bakul Shah for granting me remote access to a 64-bit
FreeBSD system and a Linux VM.

To "minux" for porting the runtime module to Linux/x86-64.

To Jean-Marc Lienher (cod5.org) for porting the runtime module
to MinGW Windows/386.

To Romain LWPB for porting the runtime module to OpenBSD/386
and Darwin/x86-64 as well as for modifying the x86-64 code
generator to emit proper code for Darwin.

To everybody who test-drove SubC and submitted bug reports.

To the Unknown Hacker for various minor and not so minor
contributions.


CONTACT
-------

Send feedback, suggestions, etc to:

n m h @ t 3 x . o r g

See http://t3x.org/contact.html for current ways through my
spam filter.
