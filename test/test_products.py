import unittest
from moss_harness import *

class TestMoss(unittest.TestCase):

    def test_executable(self):

        mk = Makefile(
            spores=SporeFile(
                sources=CSourceFile('main.c'),
                products='executable',
                name='main.spore'),
            name='Makefile')

        with SourceTree('tree') as src:
            src.create(mk)
            build = Build(src, mk)
            self.assertEqual(build.make(), 0)
