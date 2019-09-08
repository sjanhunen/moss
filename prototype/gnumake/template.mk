# Templates are used to create the rules and recipes required for
# artifacts and their associated prerequisites.
#
# A template has the following table members:
# 	RECIPE - the command(s) used to create the artifact or intermediate
# 	PREREQ - any dependencies required by the final artifact
# 	TARGET - for intermediates, the implicit target pattern
# 	RULES - for artifacts that have prerequisites
#
# Artifacts are defined through creation of a new target.
# Targets are specified explicitly for artifacts in the rule.

# Option 1:
#
# bin/host/myprogram.exe: $(call TEMPLATE, myprogram, host.exe)
#
# bin/arm/myprogram.alf bin/arm/myprogram.bin: $(call TEMPLATE, myprogram, arm.exe)
#

# Option 2:
#
# myprogram-host.exe: $(call TEMPLATE, myprogram_host)
# bin/arm/myprog.elf bin/arm/myprog.bin: $(call TEMPLATE, myprogram_target)

# Note that if we want object directory structure to follow target directory
# structure, we might have trouble with this form of TEMPLATE. We may need
#
# $(call TEMPLATE, bin/host/myprogram.exe, myprogram, ...)
#
# Need to carefully examine whether we can automatically match object DIRS to target

define _RULES
$(call $1.TARGET,$2): $(call $1.PREREQ,$2); $(call $1.RECIPE,$2)
endef

define _TEMPLATE
$(call $1.PREREQ,$1); $(call $1.RECIPE,$1)
$(foreach t,$($1.RULES),$(eval $(call _RULES,$t,$1)))
endef

TEMPLATE = $(call _TEMPLATE,$(strip $1))
