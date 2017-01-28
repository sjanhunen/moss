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

        with SourceTree('tree', mk) as src:

            self.assertEqual(mk.make(), 0)
            self.assertEqual(mk.make('-q'), 0)

    def test_large_source_tree(self):

        make_sources = lambda: [CSourceFile('tree') for _ in range(10)]
        make_spore = lambda: SporeFile(
                sources=make_sources(),
                products='static_lib',
                path='tree')

        mk = Makefile(
                spores=[make_spore() for _ in range(10)],
                name='Makefile')

        with SourceTree('tree', mk) as src:
            pass
