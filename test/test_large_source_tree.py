import unittest
from moss_harness import *


class TestLargeSourceTree(unittest.TestCase):
    def test_large_source_tree(self):

        make_filename = lambda ext='': ''.join(
                random.choice(string.ascii_lowercase) for _ in range(8)) + ext

        make_sources = lambda path: [
                CSourceFile(path + '/' + make_filename('.c')) for _ in range(100)]
        make_spore = lambda: SporeFile(
                sources=make_sources(make_filename()),
                products='static_lib',
                name=make_filename('.spore'))

        mk = Makefile(
            spores=[make_spore() for _ in range(10)], name='Makefile')

        with SourceTree('tree', preserve=False) as src:
            src.create(mk)
            build = Build(src, mk)
            self.assertEqual(0, build.make('-j4'))
