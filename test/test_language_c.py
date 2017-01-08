import unittest
import yeast_harness

class TestLanguageC(unittest.TestCase):

	def testSingleCSourceFile(self):
		sf = yeast_harness.CSourceFile('source_tree/src/aa.c')
		sf.create()
