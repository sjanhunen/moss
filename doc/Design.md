# Moss Design Overview

Moss is a library for GNU make that streamlines the creation of large
software builds with many artifacts. Moss makes it easy to create and manage
the makefile rules, recipes, and dependencies required for builds with
multiple variants, artifacts, and toolchains.

## Build Concepts

A build is a single (non-recursive) invocation of `make` that
creates some or all makefile targets. This avoids the pitfalls of recursive
make that have been well documented in the paper "Recursive Make Considered
Harmful".

Moss introduces three simple but powerful concepts that may be applied selectively as necessary to solve complex build problems.
These concepts make it much easier to manage namespaces for definitions and complicated build tree structures.

### Artifacts

An artifact is a single, fully realized build product.
Unlike a build target, a build artifact is always ultimately realized as one or more files in the build tree.
There are no phony artifacts.
Common examples of build artifacts include executables, libraries, and packages.

A specific artifact within the build tree can only every be created in one way.
Build specialization is handled explicitly on a case by case basis for each artifact that is defined.
Thus, a "production" build will always have a separate output path from a "debug" build.

All definitions required to build a specific artifact are created within a unique namespace.
The build outputs generated for each artifact are placed within a specific path of the build tree.
This guarantees that object and output files for one artifact will never be clobbered or corrupted by another build artifact.

Artifacts are defined in-line by calling the `artifact` function as part of the dependencies of a build target. Calling this function creates the rules necessary for the specific artifact defined within the given namespace.

Problems solved by Artifacts:

- rigid global constructs like platform, variant, etc. that don't fully capture subtleties of builds
- unreliable environment or global variables that control build outputs
- global variables that unexpectedly change multiple outputs when modified
- build tree sandbox for build variants
- creation and expansion of rules unique to each artifact

### Modules

Modules are simply makefiles that are imported into specific namespaces.
This makes it possible to define things in one place that can be reliably imported into different paths and even reused multiple times within the same `Makefile`.

Control over the module definition namespace at import time is the key
differentiator over and above the `include` directive of GNU make.

Two special variables are present within modules to designate the module namespace prefix and the module path prefix.

Problems solved by Modules:

- many global variables that are hard to understand and debug
- including makefiles that clobber the global namespace
- no easy way to reference paths relative to module definition 
- no way to include the same snippet multiple times in different namespace

### Templates

A template is a `Makefile` snippet that may be easily applied to multiple namespaces.
All definitions within a template are expanded within a namespace.

Templates are implemented using a "decorated" definition with the gnumake `define` directive. The `template` function is called as part of the definition directive itself.

Problems solved by Templates:

- no easy way to mutate definitions with focused operations 
- duplication required for artifacts that have definitions in common
- no easy way to debug nested define directives when expanded by make 

## Build Processes

Three processes are carried out during a build to produce the required
artifacts.  These concepts can be put into perspective by way of a genetic
analogy of protein synthesis.

### Mutation

In mutation, a definition is modified in some way to produce another definition.
The original definition is left intact and a new (modified) clone is created.

Analogy: definition (dna) -> definition' (dna)

Templates enable the creation of granular, re-usable mutations.

### Transcription

In transcription, a definition is transcribed into rules and recipes containing
build commands. Rules determine when recipes are expanded and tools are
invoked.

Analogy: definition (dna) -> rules with recipes (rna)

While the recipes are created at this stage, they are not fully expanded by make during the final build process.
Templates enable the creation of granular, re-usable rules and recipes.

### Translation

During translation, make invokes one or more tools according to the rules and recipes to create the final build artifacts.
The recipe provides all necessary inputs to a tool to produce the required artifact.

Analogy: recipe (rna) -> artifact (protein)

In some cases, translation involves actual conversion of source code into
object code. In other cases, it may only involve moving source or object code
into a final package or archive.
