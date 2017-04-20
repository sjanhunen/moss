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
dependency generation. For compilers that don't support this, the dependency
generation step can be implemented as a separate invocation of the compiler or
other tool during the same recipe for compilation.
