import unittest
from yeast_harness import *


class TestYeast(unittest.TestCase):
    def test_c_cross_compile(self):

        mk = Makefile(
            spores=SporeFile(
                sources=CSourceFile('libfun.c'),
                products='static_lib',
                name='lib.spore'),
            name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            build = Build(src, mk, arch='armv5')
            self.assertEqual(build.make(), 0)

    def test_create_object_from_c_source(self):

        c_src = CSourceFile('libfun.c')
        mk = Makefile(
            spores=SporeFile(
                sources=c_src, products='static_lib', name='lib.spore'),
            name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            build = Build(src, mk)
            c_obj = ObjectFile(build, c_src)

            self.assertFalse(c_obj.exists())
            self.assertEqual(build.make(), 0)
            self.assertTrue(c_obj.exists())

    def test_update_object_from_c_source(self):

        c_src = CSourceFile('libfun.c')
        mk = Makefile(
            spores=SporeFile(
                sources=c_src, products='static_lib', name='lib.spore'),
            name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            build = Build(src, mk)
            c_obj = ObjectFile(build, c_src)

            self.assertEqual(build.make(), 0)
            self.assertTrue(c_obj.exists())
            c_src.touch()
            self.assertEqual(build.make(), 0)
            self.assertTrue(c_obj.newer_than(c_src))

    def test_large_source_tree(self):

        make_filename = lambda ext='': ''.join(
                random.choice(string.ascii_lowercase) for _ in range(8)) + ext

        make_sources = lambda path: [
                CSourceFile(path + '/' + make_filename('.c')) for _ in range(10)]
        make_spore = lambda: SporeFile(
                sources=make_sources(make_filename()),
                products='static_lib',
                name=make_filename('.spore'))

        mk = Makefile(
            spores=[make_spore() for _ in range(10)], name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            pass
