# Utilities for the object tree

from xml.etree import ElementTree
from collections import namedtuple, defaultdict, OrderedDict, ChainMap, MutableMapping

ENCODING = 'utf-8'

PARENT_TYPES = {
    '/datum': '',
    '/atom': '/datum',
    '/turf': '/atom',
    '/area': '/atom',
    '/obj': '/atom/movable',
    '/mob': '/atom/movable',
}


class ObjectTree:
    __slots__ = ['root', '_types']

    @staticmethod
    def from_file(fname):
        with open(fname, encoding=ENCODING) as f:
            data = f.read()
        while data.startswith('loading '):
            data = data[data.index('\n')+1:]
        tree = ObjectTree()
        _parse_children(tree.root, ElementTree.fromstring(data))
        for ty in tree._types.values():
            ty._update_parent_type()
        return tree

    def __init__(self):
        self.root = _RootType(self)
        self._types = OrderedDict({'': self.root})

    # quick access to the types dictionary
    def __getitem__(self, key):
        return self._types[key]

    def children_of(self, key, inclusive=False):
        return self._types[key].all_children(inclusive)

    def new(self, key, loc=None, vars=None):
        return Atom(self._types[key], loc, vars)

    # in theory, makes access marginally faster at the expense of mutability
    def _bake(self):
        for ty in self._types.values():
            ty._bake()


# Base class for things which both contain vars and inherit them
class _Base:
    __slots__ = ['_parent', 'this_vars']

    def __init__(self, parent, vars=None):
        self._parent = parent
        self.this_vars = vars or {}

    # act sort of like a chainmap for our vars
    def get(self, key, default=None):
        try:
            return self[key]
        except:
            return default

    def __getitem__(self, key):
        current = self
        while current:
            try:
                return current.this_vars[key]
            except KeyError:
                current = current._parent
        raise KeyError(key)

    def __setitem__(self, key, value):
        self.this_vars[key] = value

    def __delitem__(self, key):
        del self.this_vars[key]

    def __contains__(self, key):
        current = self
        while current:
            if key in current.this_vars:
                return True
            current = current._parent
        return False

    def _bake(self):
        current = self._parent
        while current:
            for k, v in current.this_vars.items():
                if k not in self.this_vars:
                    self.this_vars[k] = v
            current = current._parent
        self._parent = None


class Type(_Base):
    # 'parent' is always the parent according to the tree
    # 'parent_type' differs for types which set it, and affects inheritance
    __slots__ = ['root', 'parent', 'parent_type', 'name', 'path', 'children', 'procs']

    def __init__(self, parent, name, vars=None):
        super().__init__(parent, vars)
        self.root = parent.root
        self.parent = parent
        self.name = name
        self.path = f"{parent.path}/{name}"
        self.children = OrderedDict()
        self.procs = set()

        assert self.path not in self.root._types
        assert name not in self.parent.children
        self.root._types[self.path] = self
        self.parent.children[name] = self

        if self.path in PARENT_TYPES:
            self.this_vars['parent_type'] = PARENT_TYPES[self.path]
        elif parent == parent.root.root:
            self.this_vars['parent_type'] = '/datum'

    def _update_parent_type(self):
        if 'parent_type' in self.this_vars:
            self._parent = self.parent_type = self.root[self.this_vars['parent_type']]
        else:
            self._parent = self.parent_type = self.parent

    def __setitem__(self, key, value):
        super().__setitem__(key, value)
        if key == 'parent_type':
            self._parent = self.parent_type = self.root[value]

    def __delitem__(self, key):
        del self.this_vars[key]
        if key == 'parent_type':
            self._parent = self.parent_type = self.parent

    def all_children(self, inclusive=False):
        if inclusive:
            yield self
        for child in self.children.values():
            yield child
            yield from child.all_children(False)

    def subtype_of(self, possible_parent):
        if isinstance(possible_parent, Type):
            possible_parent = possible_parent.path
        return self.path == possible_parent or self.path.startswith(possible_parent + '/')

    def prefab(self, vars=None):
        return Prefab(self, vars)

    def new(self, loc=None, vars=None):
        return Atom(self, loc, vars)

    def __str__(self):
        return self.path


class _RootType(Type):
    def __init__(self, root):
        _Base.__init__(self, None)
        self.root = root
        self.parent = self.parent_type = None
        self.name = self.path = ''
        self.children = OrderedDict()
        self.procs = set()

    def __str__(self):
        return '<root>'


class Prefab(_Base):
    __slots__ = ['type', 'this_vars']

    def __init__(self, type, vars=None):
        super().__init__(type, vars)
        self.type = type

    def new(self, loc=None):
        return Atom(self.type, loc, self.this_vars.copy())

    def __str__(self):
        return f"{self.type.path}{{{';'.join(f'{k}={v}' for k, v in self.this_vars.items())}}}"

    def __eq__(self, other):
        return self.type == other.type and self.this_vars == other.this_vars


class Atom(_Base):
    __slots__ = ['type', 'loc']

    def __init__(self, type, loc=None, vars=None):
        super().__init__(type, vars)
        self.type = type
        self.loc = loc

    def __str__(self):
        return f"{self.type.path} @ {self.loc}"

    def copy(self):
        return Atom(self.type, self.loc, self.this_vars.copy())


def _parse_children(ty, element):
    for child in element:
        if child.tag in ('object', 'turf', 'mob', 'obj', 'area'):
            name = child.text.rstrip()
            child_ty = Type(ty, name)
            _parse_children(child_ty, child)
        elif child.tag == 'var':
            name, value = _parse_var(child)
            ty[name] = value
        elif child.tag in ('proc', 'verb'):
            ty.procs.add(child.text.rstrip())
        else:
            raise ValueError(child.tag)

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
