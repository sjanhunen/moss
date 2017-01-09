import os
import os.path
from abc import ABCMeta
import io
import collections
import random
import string
import subprocess


class SourceTree(object):
    def __init__(self, path, makefile):
        pass

    def create(self):
        pass

    def delete(self):
        pass

    # Consider using __enter__ and __exit__ to manage tree


class Build(object):
    def __init__(self, path, makefile):
        pass

    def make(self, targets):
        pass

    def clean(self, targets):
        pass

    def settings(self):
        pass

    def delete(self):
        pass

    # Consider using __enter__ and __exit__ to manage tree


class AbstractFile(metaclass=ABCMeta):
    def __init__(self, path=None, prefix='', name=None, suffix=''):
        if name is None:
            name = ''.join(
                random.choice(string.ascii_lowercase) for _ in range(8))
        name = prefix + name + suffix
        if path is not None:
            name = path + '/' + name

        self._name = name

    @property
    def name(self):
        return self._name

    def touch(self):
        pass

    def exists(self):
        pass

    def delete(self):
        pass


class SourceFile(AbstractFile):
    def __init__(self, path=None, prefix='', name=None, suffix=''):

        super(SourceFile, self).__init__(path, prefix, name, suffix)
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

    def __init__(self, path=None, name=None):
        super(CSourceFile, self).__init__(path, '', name, '.c')

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
    def __init__(self, sources, products, path=None, name=None):
        super(SporeFile, self).__init__(path, '', name, '.spore')
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

# TODO: move bulk creation to SourceTree

    def create_sources(self):
        for source in self.sources:
            source.create()


class Makefile(SourceFile):
    def __init__(self, spores, path=None, name=None):
        super(Makefile, self).__init__(path, '', name)
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
        out.write("include ../yeast.mk")

        super(Makefile, self).create(out.getvalue())

    # TODO: move bulk creation to SourceTree

    def create_spores(self):
        for spore in self.spores:
            spore.create()

    def create_sources(self):
        for spore in self.spores:
            spore.create_sources()

    def make(self, arguments=None):
        cmd = ['make', '-f', self.name]
        if arguments is not None:
            cmd.append(arguments)

        return subprocess.call(cmd)
