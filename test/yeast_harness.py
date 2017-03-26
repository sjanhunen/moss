import os
import os.path
import shutil
from abc import ABCMeta
import io
import collections
import random
import string
import subprocess

class WorkingDirectory(object):

    def __init__(self, path):
        self._working_path = path

    def __enter__(self):
        # Capture current directory
        self._previous_path = os.getcwd()
        os.chdir(self._working_path)

    def __exit__(self, exception_type, exception_value, traceback):
        # Restore previous working directory
        os.chdir(self._previous_path)


class SourceTree(object):
    def __init__(self, root, makefile, preserve=False):
        self._root = root
        self._makefile = makefile
        self._preserve = preserve

    @property
    def root(self):
        return self._root

    @property
    def makefile(self):
        return self._makefile

    def create(self):
        os.makedirs(self.root)
        with WorkingDirectory(self.root):
            self._makefile.create()
            for spore in self._makefile.spores:
                spore.create()
                for source in spore.sources:
                    source.create()

    def delete(self):
        shutil.rmtree(self._root)

    def __enter__(self):
        self.create()
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        if not self._preserve:
            self.delete()


class Build(object):
    def __init__(self, source_tree):
        self._source_tree = source_tree

    def make(self, targets=None):
        with WorkingDirectory(self._source_tree.root):
            cmd = ['make', '-f', self._source_tree.makefile.name]
            if targets is not None:
                cmd.append(targets)
            return subprocess.call(cmd)

    def clean(self, targets):
        pass


class AbstractFile(metaclass=ABCMeta):
    def __init__(self, name):
        self._name = name

    # TODO: create helpers for basename, suffix

    @property
    def name(self):
        return self._name

    @property
    def path(self):
        (not_ext, ) = os.path.splitext(self._name)
        (not_basename, ) = os.path.split(not_ext)
        return not_basename

    def touch(self):
        pass

    def exists(self):
        pass

    def delete(self):
        pass


class SourceFile(AbstractFile):
    def __init__(self, name):

        super(SourceFile, self).__init__(name)
        self._sources = list()

    def create(self, content):
        directory = os.path.dirname(self.name)
        if directory != '' and not os.path.isdir(directory):
            os.makedirs(directory)

        fout = open(self.name, "wb")
        fout.write(bytes(content, 'UTF-8'))
        fout.close()

    @property
    def object(self):
        return None

    @property
    def sources(self):
        return self._sources


# Create HSourceFile, CppSourceFile, AsmSourceFile, etc.


class CSourceFile(SourceFile):

    C_FILE_TEMPLATE = """
void function_%s()
{
}
"""

    def __init__(self, name):
        super(CSourceFile, self).__init__(name)

    def create(self):
        fn_name = os.path.basename(os.path.splitext(self.name)[0])
        super(CSourceFile, self).create(self.C_FILE_TEMPLATE % fn_name)


class ObjectFile(AbstractFile):
    def __init__(self, build, source):
        pass

    @property
    def source(self):
        pass


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
    def __init__(self, sources, products, name):
        super(SporeFile, self).__init__(name)
        if not isinstance(sources, collections.Iterable):
            sources = [sources, ]
        if not isinstance(products, collections.Iterable):
            products = [products, ]
        self._products = products
        self._sources = sources

    @property
    def sources(self):
        return self._sources

    @property
    def products(self):
        return self._products

    def create(self):
        spore_name = os.path.basename(os.path.splitext(self.name)[0])

        out = io.StringIO()
        out.write('YEAST.SPORES += %s\n' % spore_name)
        out.write('%s.source =' % spore_name)
        for s in self.sources:
            out.write(' \\\n    %s' % s.name)

        super(SporeFile, self).create(out.getvalue())


class Makefile(SourceFile):
    def __init__(self, spores, name):
        super(Makefile, self).__init__(name)
        if not isinstance(spores, collections.Iterable):
            spores = [spores, ]
        self._spores = spores

    @property
    def spores(self):
        return self._spores

    def create(self):
        out = io.StringIO()
        for s in self.spores:
            out.write('include %s\n' % s.name)

        # TODO: need to specify path to Yeast in constructor
        out.write("include ../../yeast.mk")

        super(Makefile, self).create(out.getvalue())

