Goals
=====

Moss is a thin layer grown on top of GNU make that streamlines the creation of
high-performance multi-tool-chain build systems for large code bases.

Rather than trying to create an entirely new build tool or introduce a code
generation step before running an existing build tool, Moss leverages the
powerful meta-programming tools build right into GNU make.

Moss currently supports C and C++ code bases, but it may apply well to other
native languages with similar compilation flows.

Moss focuses primarily on the following goals:

- Compiling C and C++ source files efficiently into object files
- Creating and managing a variety of outputs (libraries, executables, image
  dumps, etc.) required by most non-trivial software development
- Automatically generating and managing robust dependency information
- Working with a variety of tool chains and settings for cross compilation

Moss was built with the understanding that build speed really matters,
particularly when working in unit test-driven development flows that require
frequent compile-link-test cycles. For typical large trees (e.g. 10,000 source
files), build systems implemented with Moss execute a full dependency check
(make has nothing to do) and return to the prompt in under 1 second.

Portability is maximized by:

- Standardizing on GNU make as THE BUILD TOOL (version 3.81 and above, which is
  available on most platforms of interest today) rather than attempting to work
  with multiple incompatible build tools
- Providing out-of-the-box support for mainstream gcc and clang compilers
- Separating the description of the source tree from the implementation of the
  build system
- Separating tool-independent descriptions from tool-specific options
