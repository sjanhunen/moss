import os
import os.path
from pathlib import Path
import shutil
from abc import ABCMeta
import io
import collections
import random
import string
import subprocess


class SourceTree(object):
    def __init__(self, root, preserve=False):
        self._root = root
        self._preserve = preserve

    @property
    def root(self):
        return self._root

    def create(self, source_file):
        def create_file(source_file):
            for d in source_file.dependencies:
                create_file(d)
            source_file.create()

        create_file(source_file)

    def delete(self):
        shutil.rmtree(self._root)

    def __enter__(self):
        os.makedirs(self.root)

        # Capture current directory
        self._previous_path = os.getcwd()
        os.chdir(self.root)

        return self

    def __exit__(self, exception_type, exception_value, traceback):
        # Restore previous working directory
        os.chdir(self._previous_path)

        if not self._preserve:
            self.delete()


class Build(object):
    def __init__(self, source_tree, makefile, arch=None, tool=None):
        self._source_tree = source_tree
        self._makefile = makefile
        self._arch = arch
        self._tool = tool

    def make(self, targets=None):
        cmd = ['make', '-f', self._makefile.name]
        if self._arch is not None:
            cmd.append('YEAST.ARCH=%s' % self._arch)
        if self._tool is not None:
            cmd.append('YEAST.TOOL=%s' % self._tool)
        if targets is not None:
            cmd.append(targets)
        return subprocess.call(cmd)

    @property
    def obj_suffix(self):
        # TODO: parse this from Yeast.settings
        return '.o'

    @property
    def obj_dir(self):
        # TODO: parse this from Yeast.settings
        return 'yeast.build/obj'

    def clean(self, targets):
        pass


class AbstractFile(metaclass=ABCMeta):
    def __init__(self, name):
        self._name = name
        # TOOD: make use of Path() object here for all actions

    @property
    def name(self):
        return self._name

    @property
    def basename(self):
        (name, _) = os.path.splitext(self._name)
        return name

    @property
    def path(self):
        (not_ext, ) = os.path.splitext(self._name)
        (not_basename, ) = os.path.split(not_ext)
        return not_basename

    def touch(self):
        path = Path(self.name)
        path.touch()

    def exists(self):
        return os.path.isfile(self._name)

    def newer_than(self, other):
        return os.path.getmtime(self.name) > os.path.getmtime(other.name)

    def delete(self):
        path = Path(self.name)
        path.unlink()


class SourceFile(AbstractFile):
    def __init__(self, name, content="", dependencies=[]):
        super(SourceFile, self).__init__(name)
        self._content = content
        self._dependencies = dependencies

    def create(self):
        directory = os.path.dirname(self.name)
        if directory != '' and not os.path.isdir(directory):
            os.makedirs(directory)

        fout = open(self.name, "wb")
        fout.write(bytes(self._content, 'UTF-8'))
        fout.close()

    @property
    def dependencies(self):
        return self._dependencies


class CSourceFile(SourceFile):

    C_FILE_TEMPLATE = """
void function_%s()
{
}
"""
    # TODO: Future concepts
    # h1 = CHeaderFile('lib1/inc/header.h')
    # c1 = CSourceFile('lib1/src/file1.c', includes=h1, checks='defined(BOB)')
    def __init__(self, name):
        fn_name = os.path.basename(os.path.splitext(name)[0])
        super(CSourceFile, self).__init__(name, self.C_FILE_TEMPLATE % fn_name)


class ObjectFile(AbstractFile):
    def __init__(self, build, source):
        super(ObjectFile, self).__init__(
            build.obj_dir + '/' + source.basename + build.obj_suffix)
        self._source = source

    @property
    def source(self):
        return self._source


class ProductFile(AbstractFile):
    def __init__(self, build, spore):
        pass

    @property
    def spore(self):
        pass


class StaticLibProductFile(ProductFile):
    def __init__(self, build, spore):
        pass


class SporeFile(SourceFile):

    # TODO: Future concept
    # sp = SporeFile('lib1/lib1.spore', source=[c1, c2],
    #                defines='BOB', products='static_lib')
    def __init__(self, sources, products, name):
        if not isinstance(sources, collections.Iterable):
            sources = [
                sources,
            ]
        if not isinstance(products, collections.Iterable):
            products = [
                products,
            ]

        spore_name = os.path.basename(os.path.splitext(name)[0])
        out = io.StringIO()
        out.write('YEAST.SPORES += %s\n' % spore_name)
        out.write('%s.source =' % spore_name)
        for s in sources:
            out.write(' \\\n    %s' % s.name)


        super(SporeFile, self).__init__(name, out.getvalue(), sources)
        self._products = products
        self._sources = sources

    @property
    def sources(self):
        return self._sources

    @property
    def products(self):
        return self._products


class Makefile(SourceFile):
    def __init__(self, name, spores):
        if not isinstance(spores, collections.Iterable):
            spores = [
                spores,
            ]

        out = io.StringIO()
        for s in spores:
            out.write('include %s\n' % s.name)
        # TODO: need to specify path to Yeast in constructor
        out.write("include ../../yeast.mk")

        super(Makefile, self).__init__(name, out.getvalue(), spores)
        self._spores = spores

    @property
    def spores(self):
        return self._spores