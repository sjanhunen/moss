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
import time


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
            cmd.append('MOSS.ARCH=%s' % self._arch)
        if self._tool is not None:
            cmd.append('MOSS.TOOL=%s' % self._tool)
        if targets is not None:
            cmd.append(targets)
        return subprocess.call(cmd)

    @property
    def obj_suffix(self):
        # TODO: parse this from Moss.settings
        return '.o'

    @property
    def obj_dir(self):
        # TODO: parse this from Moss.settings
        return 'moss.build/obj'

    @property
    def exe_suffix(self):
        # TODO: parse this from Moss.settings
        return ''

    @property
    def exe_dir(self):
        # TODO: parse this from Moss.settings
        return 'moss.build/bin'

    def clean(self, targets):
        pass


class AbstractFile(metaclass=ABCMeta):
    def __init__(self, name):
        self._name = name
        self._path = Path(name)

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
        # Touching a file is an approach we use for testing our
        # make rules on all platforms. Some platforms (e.g. OS X with HFS+)
        # do not support sub-second resolution on modification times.
        # Ensure our modification time in seconds is always unique by
        # adding this delay here.
        time.sleep(1)
        self._path.touch()
        # self._path is now newer than any existing files
        time.sleep(1)
        # invoking make now will generate timestamps newer than self._path

    def exists(self):
        return self._path.exists()

    def newer_than(self, other):
        return self._path.stat().st_mtime > other._path.stat().st_mtime

    def not_older_than(self, other):
        return self._path.stat().st_mtime >= other._path.stat().st_mtime

    def delete(self):
        self._path.unlink()


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

    C_SOURCE_TEMPLATE = """
int %s()
{
	return 0;
}
"""

    def __init__(self, name, includes=None):
        fn_name = os.path.basename(os.path.splitext(name)[0])

        out = io.StringIO()
        if not includes is None:
            out.write('#include "%s"' % includes.name)
            dependencies = [includes, ]
        else:
            dependencies = []
        out.write(self.C_SOURCE_TEMPLATE % fn_name)

        super(CSourceFile, self).__init__(name, out.getvalue(), dependencies)


class CHeaderFile(SourceFile):

    C_HEADER_TEMPLATE = """
static void inline_function_%s() {}
"""

    def __init__(self, name):
        fn_name = os.path.basename(os.path.splitext(name)[0])
        super(CHeaderFile, self).__init__(name,
                                          self.C_HEADER_TEMPLATE % fn_name)


class ObjectFile(AbstractFile):
    def __init__(self, build, source):
        super(ObjectFile, self).__init__(build.obj_dir + '/' + source.basename
                                         + build.obj_suffix)
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

class ExecutableProductFile(AbstractFile):
    def __init__(self, build, spore):
        super(ExecutableProductFile, self).__init__(build.exe_dir + '/' + spore.name
                                         + build.exe_suffix)



class SporeFile(SourceFile):

    # TODO: Future concept
    # sp = SporeFile('lib1/lib1.spore', source=[c1, c2],
    #                defines='BOB', products='static_lib')
    def __init__(self, sources, products, name):
        if not isinstance(sources, collections.Iterable):
            sources = [sources, ]
        if not isinstance(products, collections.Iterable):
            products = [products, ]

        spore_name = os.path.basename(os.path.splitext(name)[0])
        out = io.StringIO()
        out.write('MOSS.SPORES += %s\n' % spore_name)
        out.write('%s.products = %s\n' % (spore_name, products))
        out.write('%s.source =' % spore_name)
        for s in sources:
            out.write(' \\\n    %s' % s.name)

        super(SporeFile, self).__init__(name, out.getvalue(), sources)
        self._products = products
        self._sources = sources
        self._name = spore_name

    @property
    def sources(self):
        return self._sources

    @property
    def products(self):
        return self._products

    @property
    def name(self):
        return self._name


class Makefile(SourceFile):
    def __init__(self, name, spores):
        if not isinstance(spores, collections.Iterable):
            spores = [spores, ]

        out = io.StringIO()
        for s in spores:
            out.write('include %s\n' % s.name)
        # TODO: need to specify path to Moss in constructor
        out.write("include ../../moss.mk")

        super(Makefile, self).__init__(name, out.getvalue(), spores)
        self._spores = spores

    @property
    def spores(self):
        return self._spores
