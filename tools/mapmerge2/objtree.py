# Utilities for the object tree

from xml.etree import ElementTree
from collections import namedtuple, defaultdict, OrderedDict, ChainMap

ENCODING = 'utf-8'

PARENT_TYPES = {
    '/atom': '/datum',
    '/turf': '/atom',
    '/area': '/atom',
    '/obj': '/atom/movable',
    '/mob': '/atom/movable',
}

class ObjectTree:
    __slots__ = ['parent', 'path', 'full_path', 'children', 'root', '_vars']

    def __init__(self, path, parent):
        self.path = path
        self.parent = parent
        self.children = OrderedDict()
        self._vars = {}

        if parent:
            self.full_path = f"{parent.full_path}/{path}"
            self.root = parent.root
        else:
            self.full_path = ""
            self.root = self

        if self.full_path in PARENT_TYPES:
            self._vars['parent_type'] = PARENT_TYPES[self.full_path]

    @staticmethod
    def from_file(fname):
        with open(fname, encoding=ENCODING) as f:
            data = f.read()
        while data.startswith('loading '):
            data = data[data.index('\n')+1:]
        return _parse(ElementTree.fromstring(data), None)

    @property
    def parent_type(self):
        if 'parent_type' in self._vars:
            return self.root.find(self._vars['parent_type'][1:])
        return self.parent

    @property
    def vars(self):
        parent = self.parent_type
        if parent:
            return parent.vars.new_child(self._vars)
        return ChainMap(self._vars)

    def all_children(self, inclusive=True):
        if inclusive:
            yield self
        for child in self.children.values():
            yield child
            yield from child.all_children(inclusive=False)

    def find(self, path):
        if path == '':
            return self
        if '/' in path:
            first, rest = path.split('/', 1)
        else:
            first, rest = path, ''
        if first in self.children:
            return self.children[first].find(rest)
        return None

class Atom:
    __slots__ = ['type', 'loc', 'vars']

    def __init__(self, type, loc=None, vars={}):
        self.type = type
        self.loc = loc
        self.vars = type.vars.new_child(vars)

    @property
    def path(self):
        return self.type.full_path

def _parse(element, parent):
    this_path = element.text.rstrip()
    obj = ObjectTree(this_path, parent)

    for child in element:
        if child.tag in ('object', 'turf', 'mob', 'obj', 'area'):
            obj2 = _parse(child, obj)
            obj.children[obj2.path] = obj2
        elif child.tag == 'var':
            name, value = _parse_var(child)
            obj._vars[name] = value
        elif child.tag in ('proc', 'verb'):
            pass  # TODO
        else:
            raise ValueError(child.tag)
    return obj

def _parse_var(elem):
    if len(elem) == 0:
        value = None
    elif len(elem) == 1:
        value = _parse_val(elem[0])
    else:
        raise ValueError(elem.attrib['file'])
    return elem.text.rstrip(), value

def _parse_val(elem):
    text = (elem.text or '').rstrip()
    if text:
        return _parse_literal(text)
    elif len(elem) == 0:
        return []
    elif len(elem) == 1:
        list_ = elem[0]
        return [(_parse_special(x) if len(x) else _parse_literal(x.text)) for x in list_]
    raise ValueError(elem.attrib['file'])

def _parse_literal(text):
    if text == 'TRUE':
        return True
    elif text == 'FALSE':
        return False
    return text

def _parse_special(x):
    return (x.text or '').rstrip().join((y.text or '').rstrip() for y in x)

if __name__ == '__main__':
    ObjectTree.from_file('data/objtree.xml')
