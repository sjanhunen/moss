Use Cases
=========

As someone integrating several libraries into my top-level build process, I would like to specify toolchain and architecture setting at one point and have all dependent libraries use these changes by default.

As an integrator, I want to build my system for multiple architectures and with multiple tools with parallel build directory structures that don't clobber one another.

As an integrator, I need to be able to customize toolchain settings per library.

As a library developer, I don't want to concern myself with platform specifics that don't apply to me. I need to be able to set include paths and defines for my code in a portable way.

As a library developer, I may control toolchain settings for my local testing, but I defer responsibility of that to the integrator for the next level up.

Cross-compiling
---------------

- Cross-compile embedded applications for different architectures with a single
  Makefile
- Out-of-the-box support for gcc and clang x86/ARM
- Create libaraies with different complier options (e.g. ARM vs Thumb code)

Target generation
-----------------

- Build the same source file with different compiler settings
- Create multiple executable and library target outputs with ease
- Separate definition of program source and structure from creating rules

Large projects
--------------

- Manage large projects with multiple sub-components
- Combine components from different parts of a filesystem (re-use installed
  library source in multiple projects)
- Create release directory structures with libraries, binaries, and includes
- Build against libraries either from source or from released package

Usability
---------

- Tab auto-completion works with targets defined by Moss
- Makes it easier to debug by dumping full commands with options
- Unit testable for validation and performance testing
- Work with in-place object files for the smallest projects
- Support for automatic dependency generation
