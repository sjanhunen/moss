import unittest
from yeast_harness import *


class TestYeast(unittest.TestCase):

    def test_c_source_compile(self):

        # New proposal for source files:
        # 	SourceFile(name, contents, dependencies)
        # Language-specific SourceFile subclasses create dependencies automatically
        #
        # h1 = CHeaderFile('lib1/inc/header.h')
        # c1 = CSourceFile('lib1/src/file1.c', includes=h1, checks='defined(BOB)')
        # c2 = CSourceFile('lib2/src/file2.c')
        #
        # sp = SporeFile('lib1/lib1.spore', source=[c1, c2],
        #				 defines='BOB', products='static_lib')
        # mk = Makefile('Makefile', spores=sp)
        #
        # with SourceTree('my_source') as st:
        # 	# create can be used to create any node in the tree
        # 	st.create(mk)
        #
        # 	build1 = Build(st, mk, arch='host', tool='gcc')
        # 	build2 = Build(st, mk, arch='arm', tool='gcc')
        #
        # 	o1 = ObjectFile(c1, build1)
        # 	o1 = ObjectFile(c1, build2)
        #
        #	build1.make()
        #	assert(o1.exists())
        #   assert(not o2.exist())
        #
        #	build2.make()
        #   assert(o2.newer_than(o1))

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
