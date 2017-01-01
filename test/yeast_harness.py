import os
import os.path

# Class design sketches for yest test harness

# Settings (ideally, generate this automatically from make Yeast.settings)
#	- Yeast.path.home
#	- Yeast.path.object
#	- Yeast.path.executable

# File
#	- name
#	- exists
#	- newer
#	- touch
#	- delete

# SourceFile
#	- targets
#	- sources
#	- objects
#	- update

class SourceFile(object):

	C_FILE_TEMPLATE = """
void function_%s()
{
}
"""
	def __init__(self, name):
		self.name = name

	def filename(self):
		pass

	def symbol(self):
		pass

	def touch(self):
		pass

	def create(self):
		directory = os.path.dirname(self.name)
		if not os.path.isdir(directory):
			os.makedirs(directory)

		fn_name = os.path.basename(os.path.splitext(self.name)[0])

		fout = open(self.name, "wb")
		fout.write(self.C_FILE_TEMPLATE % fn_name)
		fout.close()


# CSourceFile, HSourceFile, CppSourceFile, AsmSourceFile, etc.

# ObjectFile
#	- sources
#	- targets

# ProductFile
#	- filename
#	- sources
#	- attach_spore
#	- detach_spore

# SporeFile
#	- sources
#	- products
#	- update
#	- add_source
#	- add_product
#	- attach_makefile
#	- detach_makefile

# Makefile
#	- spores
#	- update
#	- add_spore
