Dependency Generation
=====================

The only reliable way to get dependencies right with minimal maintenance is to
use the compiler iteself with the same options as an actual build. Otherwise,
there is a risk that preprocessor macros will not be evaluated correctly. 

Reference build with no dependencies:

	Not parallel: 14.229s
	Parallel (-j4): 0m4.096s

Alternatives:

1. Generate dependencies first, one at a time

Not parallel: 0m21.822s
Parallel (-j4): 0m6.318s


2. Generate dependencies after compile, one at a time
Not parallel: 0m19.663s
Parallel (-j4): 0m6.329s  

3. Generate dependencies during compile, one at a time
Not parallel: 0m14.578s
Parallel (-j4): 0m4.217s

3. Generate bulk dependencies for spore first: Not feasable without extra
   post-processing due to the fact that each target needs custom name

Option 3 is the clear winner. For compilers that support dependency generation
during compile (e.g. gcc), this is nearly as fast as a straight build with no
dependency generation. For compilers that don''t support this, the dependency
generation step can be implemented as a separate invocation of the compiler or
other tool during the same recipe for compilation.

One remaining challenge in this design is the performance of make with nothing
to do for large code bases (e.g 10,000 files). Include the per-file dependency
information can take a significant amount of time. For example:

	make: Nothing to be done for 'all'. (no dependencies)

	real    0m0.969s
	user    0m0.312s
	sys     0m0.656s

	make: Nothing to be done for 'all'. (using individual .d files for dependencies)

	real    0m7.629s
	user    0m1.484s
	sys     0m3.406s

The make with nothing to do slows down by nearly an order of magnitude when
full dependency information is used. An experiment was performed to rule out
the performance of include. All dependency files were concatenated into a
single all.d with the following result:

	make: Nothing to be done for 'all'. (using single all.d for dependencies)

	real    0m1.030s
	user    0m0.281s
	sys     0m0.734s

This is a significant performance improvement over including individual
dependency files and represents one path forward for high-performance
dependency generation.

Build Tree Structure
====================

All Moss build object files and products are placed in a Moss build tree
structure called `moss.build` by default.

Build objects and products are placed according to the following guidelines:

- headers -> `YEAST.HEADER.PATH`
- static and shared libraries -> `YEAST.LIBRARY.PATH`
- object files -> `YEAST.OBJECT.PATH`
- executables -> `YEAST.EXECUTABLE.PATH`

Headers located in `YEAST.HEADER.PATH` are automatically included as part of
the system include path when building spore products. Libraries located in
`YEAST.LIB.PATH` are included as part of the library search path when linking
spore products.

An example `moss.build` structure might look something like this:

	moss.build/
		include/
			freertos/
				task.h
				mutex.h
				...
			core/
				stuff.h
				...
			crypto/
				hash.h
				...
		obj/
			armv5.gcc-release/
				crypto/
					src/
						sha1.crypto.o
						md5.crypto.o
				...
			armv5.gcc-debug/
				crypto/
					src/
						sha1.crypto.o
						md5.crypto.o
				...
		bin/
			armv5.gcc-release/
				...
			armv5.gcc-debug/
				...
		lib/
			armv5.gcc-release/
				libfreertos.a
				libcore.a
				libcrypto.a
			armv5.gcc-debug/
				libfreertos.a
				libcore.a
				libcrypto.a

Moss assumes that header files are shared across all architectures and
toolchains. Any architecture-specific header files are an internal
implementation detail of the source code for a spore that defines them.
