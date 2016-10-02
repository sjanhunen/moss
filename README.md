# gnumake-molds
Molds for building software with GNU make

Goals:

- Cross-compile embedded applications for different architectures with a single Makefile
- Create libaraies with different complier options (e.g. ARM vs Thumb code)
- Create multiple executable outputs with ease
- Separate definition of program source and structure from creating rules
- Manage large projects with multiple "sub-components"
- Combine components from different parts of a filesystem (re-use installed library source in multiple projects)
- Build the same source file with different compiler settings
- Tab auto-completion works with targets defined by Mold
- Makes it easier to debug by dumping full commands with options
- Out-of-the-box support for gcc and clang x86/ARM
- Unit testable for validation and performance testing
- Work with in-place object files for the smallest projects
- Support for automatic dependency generation
- Create release directory structures with libraries, binaries, and includes
- Build against library components from either source or released binary

Key Concepts
============

- Architecture: CPU + toolchain
- Platform: variations of compiler and build settings required to create working targets (e.g. debug vs release)
- Target: final output such as a library, executable, or binary image

Example: For a given architecture and platform, a given source file is always complied with a single set of compiler settings.