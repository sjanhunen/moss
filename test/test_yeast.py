import unittest
from yeast_harness import *


class TestYeast(unittest.TestCase):
    def test_single_c_source(self):

        mk = Makefile(
            spores=SporeFile(
                sources=CSourceFile('tree'),
                products='static_lib',
                path='tree'),
            name='Makefile')

        mk.create()
        mk.create_spores()
        mk.create_sources()
        self.assertEqual(mk.make(), 0)
        self.assertEqual(mk.make('-q'), 0)
