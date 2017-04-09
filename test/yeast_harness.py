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
    def __init__(self, root, preserve=False):
        self._root = root
        self._preserve = preserve

    @property
    def root(self):
        return self._root

    def create(self, source_file):
        os.makedirs(self.root)
        with WorkingDirectory(self.root):
            def create_file(source_file):
                for d in source_file.dependencies:
                    create_file(d)
                source_file.create()

            create_file(source_file)

    def delete(self):
        shutil.rmtree(self._root)

    def __enter__(self):
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        if not self._preserve:
            self.delete()


class Build(object):
    def __init__(self, source_tree, makefile):
        self._source_tree = source_tree
        self._makefile = makefile

    def make(self, targets=None):
        with WorkingDirectory(self._source_tree.root):
            cmd = ['make', '-f', self._makefile.name]
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


# Create HSourceFile, CppSourceFile, AsmSourceFile, etc.


class CSourceFile(SourceFile):

    C_FILE_TEMPLATE = """
void function_%s()
{
}
"""
    def __init__(self, name):
        fn_name = os.path.basename(os.path.splitext(name)[0])
        super(CSourceFile, self).__init__(name, self.C_FILE_TEMPLATE % fn_name)

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