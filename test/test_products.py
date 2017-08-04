import unittest
from moss_harness import *
import time

class TestMoss(unittest.TestCase):

    def test_executable(self):

        c_source = CSourceFile('main.c')
        spore = SporeFile(sources=c_source,
                products='executable',
                name='main.spore')
        mk = Makefile(
            spores=spore,
            name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            # TODO: how do we solve the timestamp problem for OS X?
            time.sleep(1)
            build = Build(src, mk)
            self.assertEqual(build.make(), 0)
            exe = ExecutableProductFile(build, spore)
            self.assertTrue(exe.newer_than(c_source))
