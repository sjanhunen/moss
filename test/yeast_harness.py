import os
import os.path

# Class design sketches for yest test harness

# Settings (ideally, generate this automatically from make Yeast.settings)
#	- Yeast.path.home
#	- Yeast.path.object
#	- Yeast.path.executable

class BaseFile(object):

	def __init__(self, name):
		self.name = name

	def name(self):
		return self.name

	def symbol(self):
		pass

	def touch(self):
		pass

	def exists(self):
		pass

	def create(self, content):
		directory = os.path.dirname(self.name)
		if not os.path.isdir(directory):
			os.makedirs(directory)

		fout = open(self.name, "wb")
		fout.write(bytes(content, 'UTF-8'))
		fout.close()

	def delete(self):
		pass

# SourceFile(BaseFile)
#	- object_files
#	- products

class CSourceFile(BaseFile):

	C_FILE_TEMPLATE = """
void function_%s()
{
}
"""

	def create(self):
		fn_name = os.path.basename(os.path.splitext(self.name)[0])
		super(CSourceFile, self).create(self.C_FILE_TEMPLATE % fn_name)

# HSourceFile, CppSourceFile, AsmSourceFile, etc.

# ObjectFile
#	- source
#	- products

# ProductFile
#	- source_files
#	- object_files
#	- spore

# SporeFile
#	- products
#	- makefile

# Makefile
#	- spores