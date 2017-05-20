Use Cases
=========

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
