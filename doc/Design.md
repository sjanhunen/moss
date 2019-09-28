# Moss Design Overview

Moss is a library for GNU make that streamlines the creation of large
software builds with many artifacts. Moss makes it easy to create and manage
the makefile rules, recipes, and dependencies required for builds with
multiple variants, artifacts, and toolchains.

## Fundamental Concepts

The design of Moss is based on four fundamental concepts. These concepts
enforce a healthy separation of concerns but still allow for great
flexibility in application. These concepts help avoid many pitfalls of more
traditional makefile-based build systems.

### Builds

A build is defined as a single (non-recursive) invocation of `make` that
creates some or all makefile targets.

As part of the build concept, Moss intentionally avoids formalizing support
for multiple architectures, platforms, or variants. Instead, this type of specialization
is handled explicitly on a case by case basis as build artifacts are defined.

Pitfalls:
- recursive application of make
- attempting to formalize concepts that are highly application and artifact specific

### Artifacts

An artifact is a single fully realized build product. Common examples include
libraries and executables.

Artifacts are individually defined and specialized as required for different
architectues, platforms, or variants. Every artifact is 
created in an isolated sandbox. This guarantees that object and
artifact files from one variant will never be clobbered by another build
target.

Pitfalls:
- not creating each build artifact in a sandbox
- attempting to specialize separately from definition (global variables vs mutation)

### Templates 

A template is used to define a build recipe with associated rule(s) that are used as part of artifact creation.

Pitfalls:
- not separating definition of rules from definition of artifacts
- not specializing rules and recipes for each artifact

### Tables

A table is a set of related definitions used to define an artifact.
Table definitions follow a variable namespace convention within make.

Tables make is easy to define and customize artifacts for multiple build variants.
A given table may be used to produce multiple artifacts without requiring duplication of the common definitions.

Pitfalls:
- global variables that are hard to understand and debug
- no way to compose and mutate definitions with granular building blocks

## Processes

Three proceses are carried out during a build to produce the required artifacts.
These concepts can be put into perspective by way of a genetic analogy of protein synthesis.

### Mutation

Analogy: table (dna) -> mutate using mutation -> table (dna)

A mutation is simply a table definition that is used to modify another table definition.

### Transcription

Analogy: table (dna) -> transcribe using template -> recipe (rna)

Template rules are used to contol when recipes are expanded and tools are invoked.
Templates are composed and configured using tables and mutations.  Rules
and recipes are only expanded when artifacts are actuall built by make.

### Translation

Analogy: recipe (rna) -> translate using tool -> artifact (proteins)

Tool are the programs used to create all final and intermediate build artifacts.
Tools perform one of three possible actions:

1. Translate: convert source code from one language from another language. The output is generated source code, not object code.
2. Compile: converts source code into object code.  The output is object code, an intermediate artifact.
3. Form: Create final artifact output. An artifact may contain source files or object code. Some artifacts may be produced directly from source files.