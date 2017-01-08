import os
import os.path
from abc import ABCMeta
import io

# Class design sketches for yest test harness

# Settings (ideally, generate this automatically from make Yeast.settings)
#	- Yeast.path.home
#	- Yeast.path.object
#	- Yeast.path.executable


class BaseFile(object):
    def __init__(self, name):
        self._name = name

    @property
    def name(self):
        return self._name

    def touch(self):
        pass

    def exists(self):
        pass

    def create(self, content):
        directory = os.path.dirname(self.name)
        if directory != '' and not os.path.isdir(directory):
            os.makedirs(directory)

        fout = open(self.name, "wb")
        fout.write(bytes(content, 'UTF-8'))
        fout.close()

    def delete(self):
        pass


# SourceFile(BaseFile)
#	- object_files
#	- products


class CSourceFile(BaseFile):

    C_FILE_TEMPLATE = """
void function_%s()
{
}
"""
    def create(self):
        fn_name = os.path.basename(os.path.splitext(self.name)[0])
        super(CSourceFile, self).create(self.C_FILE_TEMPLATE % fn_name)


# HSourceFile, CppSourceFile, AsmSourceFile, etc.

# ObjectFile
#	- source
#	- products


class ProductFile(BaseFile):
    def __init__(self, name):
        super(ProductFile, self).__init__(name)


# Create StaticLibProductFile, ExecutableProductFile, etc.


class SporeFile(BaseFile):
    def __init__(self, name, source_files, products):
        super(SporeFile, self).__init__(name)
        self._products = products
        self._source_files = source_files

    @property
    def source_files(self):
        return self._source_files

    @property
    def products(self):
        return self._products

    def create(self):
        spore_name = os.path.basename(os.path.splitext(self.name)[0])

        out = io.StringIO()
        out.write('YEAST.SPORES += %s\n' % spore_name)
        out.write('%s.source =' % spore_name)
        for s in self.source_files:
            out.write(' \\\n    %s' % s.name)

        super(SporeFile, self).create(out.getvalue())

    def create_source(self):
        for source in self.source_files:
            source.create()


class Makefile(BaseFile):
    def __init__(self, name, spores):
        super(Makefile, self).__init__(name)
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

    def create_spores(self):
        for spore in self.spores:
            spore.create()
