# gnumake-molds
Molds for building software with GNU make

Goals:

- Cross-compile embedded applications for different architectures with a single Makefile
- Create libaraies with different complier options (e.g. ARM vs Thumb code)
- Create multiple executable outputs with ease
- Separate definition of program source and structure from creating rules
- Manage large projects with multiple "sub-components"
- Combine components from different parts of a filesystem (re-use installed library source in multiple projects)
