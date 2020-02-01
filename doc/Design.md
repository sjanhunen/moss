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

An artifact is a single fully realized build product. Common examples include
libraries and executables.

Moss intentionally avoids formalizing support for multiple architectures,
platforms, or variants. Instead, this type of specialization is handled
explicitly on a case by case basis for each artifact that is defined.

Furthermore, the build for each artifact is performed in an isolated sandbox.
This guarantees that object and artifact files from one variant will never be
clobbered by another build target.

Pitfalls:
- not creating each build artifact in a sandbox
- attempting to specialize artifacts with rigid global constructs (like platform, variant, etc)

### Rules

Build rules define the dependency chain and recipes required to create a final
build artifact.

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
- global variables that are hard to understand and debug
- no way to compose and mutate definitions with granular building blocks

### Tools

Tools are programs used to create all final and intermediate build artifacts.

Pitfalls:
- hardcoding recipes and rules for specific tool configurations
- mixing tool configuration with artifact definition

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
