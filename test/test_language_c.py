import unittest
from yeast_harness import *


class TestLanguageC(unittest.TestCase):
    def testSingleCSourceFile(self):

        mk = Makefile(
            spores=SporeFile(
                sources=CSourceFile('tree'),
                products=ProductFile('tree'),
                path='tree'),
            name='Makefile')

        mk.create()
        mk.create_spores()
        mk.create_sources()
        self.assertEqual(mk.make(), 0)
        self.assertEqual(mk.make('-q'), 0)
