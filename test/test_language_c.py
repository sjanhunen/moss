import unittest
import yeast_harness


class TestLanguageC(unittest.TestCase):
    def testSingleCSourceFile(self):

        src_file = yeast_harness.CSourceFile('tree/src/a.c')
        product_file = yeast_harness.ProductFile('tree/mylib.a')
        spore_file = yeast_harness.SporeFile('tree/mylib.spore', [src_file, ],
                                             [product_file, ])
        mk = yeast_harness.Makefile('Makefile', [spore_file, ])
        mk.create()
        mk.create_spores()
        spore_file.create_source()
