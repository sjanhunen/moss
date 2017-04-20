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
