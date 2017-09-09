import unittest
from moss_harness import *
import time


class TestProducts(unittest.TestCase):
    def test_executable(self):

        c_source = CSourceFile('main.c')
        spore = SporeFile(
            sources=c_source, products='executable', name='main.spore')
        mk = Makefile(spores=spore, name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            build = Build(src, mk)
            exe = ExecutableProductFile(build, spore)
            self.assertFalse(exe.exists())
            self.assertEqual(build.make(), 0)
            self.assertTrue(exe.not_older_than(c_source))

    def test_static_lib(self):

        c_source = CSourceFile('main.c')
        spore = SporeFile(
            sources=c_source, products='static_lib', name='main.spore')
        mk = Makefile(spores=spore, name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            build = Build(src, mk)
            lib = StaticLibProductFile(build, spore)
            self.assertFalse(lib.exists())
            self.assertEqual(build.make(), 0)
            self.assertTrue(lib.not_older_than(c_source))
