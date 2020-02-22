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

The design of Moss is based on a few fundamental concepts that encourage a
healthy separation of several important concerns:

1. Layout and naming of the build artifacts 
2. Definition of the build rules and recipes
3. Definition of the build artifact itself
4. Selection and configuration of the build tools

This separation of concerns helps avoid many pitfalls of more traditional
makefile-based build systems.

### Artifacts

An artifact is a single fully realized build product.
Unlike a build target, a build artifact is always ultimately realized as a file in the build tree.
There are no phony artifacts.
Common examples of build artifacts include executables, libraries, and packages.

A specific artifact within the build tree can only be created one way.
Build specialization is handled explicitly on a case by case basis for each artifact that is defined.

The build for each artifact is performed in an isolated sandbox.
This guarantees that object and output files for one artifact will never be clobbered or corrupted by another build artifact.

Pitfalls:
- building multiple variants of the same artifact in the same location
- attempting to specialize artifacts with rigid global constructs (like platform, variant, etc)
- not creating each build artifact in a sandbox

### Rules

Build rules define both the dependencies and the recipes required to create a build artifact.
Recipes invoke the build tools that create the build artifacts.
Recipes may also create intermediate build artifacts as needed by chains of implicit rules.
Build rule definition is intentionally kept separate from artifact definition.

Pitfalls:
- not separating definition of rules from definition of artifacts
- not specializing rules and recipes for each artifact

### Templates

A template is a special kind of generic definition that may be easily cloned
and composed.  Templates follow definition namespace conventions that keep the
definitions within a template from polluting the global namespace.

Templates make is easy to define and customize artifacts for multiple build
variants.  A given template may be used to produce multiple artifacts without
requiring duplication of the common definitions.

Pitfalls:
- many global variables that are hard to understand and debug
- no way to compose and mutate definitions with granular building blocks

### Modules

Modules are reusable, independent makefile snippets that can be imported into
specific namespaces.  Control over namespace at import time is the key
differentiator over and above the `include` directive of GNU make.

Pitfalls:
- many global variables that are hard to understand and debug
- including makefiles that clobber the global namespace

## Build Processes

Three processes are carried out during a build to produce the required
artifacts.  These concepts can be put into perspective by way of a genetic
analogy of protein synthesis.

### Mutation

In mutation, a definition is modified in some way to produce another definition.
The original definition is left intact and a new (modified) clone is created.

Analogy: definition (dna) -> definition' (dna)

### Transcription

In transcription, a definition is transcribed into rules and recipes containing
build commands. Rules determine when recipes are expanded and tools are
invoked.

Analogy: definition (dna) -> recipe (rna)

While the rules and recipes are actually created at this stage, they are only
fully expanded by make during the final build process.

### Translation

During translation, make invokes one or more tools according to the rules and
recipe to create the final artifact. The recipe provides all necessary inputs
to a tool to produce the required artifact.

Analogy: recipe (rna) -> artifact (protein)

In some cases, translation involves actual conversion of source code into
object code. In other cases, it may only involve moving source or object code
into a final package or archive.
