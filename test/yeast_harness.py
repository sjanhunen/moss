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
#	- add_target
#	- add_object
#	- remove_target
#	- remove_object

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
#	- add_source


# ProductFile
#	- filename
#	- sources
#	- product_name

# SporeFile
#	- sources
#	- products
#	- update

# Makefile
#	- spores
#	- update
