import unittest
from yeast_harness import *


class TestYeast(unittest.TestCase):
    def test_single_c_source(self):

        mk = Makefile(
            spores=SporeFile(
                sources=CSourceFile(),
                products='static_lib'),
            name='Makefile')

        with SourceTree('tree', mk) as src:
            build = Build(src)
            self.assertEqual(build.make(), 0)
            self.assertEqual(build.make('-q'), 0)

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
