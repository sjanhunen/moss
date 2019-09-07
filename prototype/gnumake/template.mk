# Templates are used to create the rules and recipes required for
# artifacts and their associated dependencies.
#
# A template has the following table members:
# 	RECIPE - the command(s) used to create the artifact or intermediate
# 	PREREQ - any dependencies required by the final artifact
# 	TARGET - for intermediates, the implicit target pattern
#
# Note that targets are specified explicitly for artifacts.  

# Example for CPP compilation
cpp.RECIPE = cc -c -o $$@ $$^
cpp.TARGET = %.obj.$1
cpp.PREREQ = %.cpp | $($1.DIRS)

# Example for final executable artifact
define exe.RECIPE
ld -o $$@ $$^ $($1.LIBS)
endef
exe.PREREQ = $($1.OBJS) $($1.LIBS)
# Any templates required to create artifact
exe.TEMPLATES = cpp

# How do we associate artifact template with final artifact?
# We could pass the TEMPLATE into the ARTIFACT call
# Should we call ARTIFACT TEMPLATE instead?
bin/host/myprogram.exe: $(call ARTIFACT, myprogram, host.exe)
# Could we potentially have multiple outputs?
bin/arm/myprogram.alf bin/arm/myprogram.bin: $(call ARTIFACT, myprogram, arm.exe)

# Or should we insist that each definition already has the TEMPLATE applied?
# Could we potentially have multiple outputs?
myprogram-host.exe: $(call ARTIFACT, myprogram_host)
bin/arm/myprog.elf bin/arm/myprog.bin: $(call ARTIFACT, myprogram_target)

# Note that if we want object directory structure to follow target directory
# structure, we might have trouble with this form of ARTIFACT. We may need
$(call ARTIFACT, bin/host/myprogram.exe, myprogram, ...)

# Need to carefully examine whether we can automatically match object DIRS to target
