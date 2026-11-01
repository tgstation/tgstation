import collections
from collections import OrderedDict
import glob
import json
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dmi

CONFIG = 'modular_redtard/rockhill/config.json'
OUT_DIR = 'modular_redtard/rockhill/ported'
ICON_DIR = 'modular_redtard/rockhill/icons'
REPORT = 'modular_redtard/rockhill/PORTED_CONTENT.md'
CHECKOUT = '.cache/ratwood'
BLANK_WORN = 'modular_redtard/rockhill/icons/blank_worn.dmi'
FEMALE_WORN_SUFFIX = '_f'
TG_WORN_SLOTS = ('ITEM_SLOT_BACK', 'ITEM_SLOT_ID', 'ITEM_SLOT_GLOVES', 'ITEM_SLOT_EYES', 'ITEM_SLOT_EARS', 'ITEM_SLOT_NECK', 'ITEM_SLOT_MASK', 'ITEM_SLOT_BELT')
WEAR_COVERAGE = {'/obj/item/clothing/gloves': ('hands', {'HAND_LEFT', 'HAND_RIGHT'}), '/obj/item/clothing/shoes': ('feet', {'FOOT_LEFT', 'FOOT_RIGHT'})}
DECLARATION_ROOTS = ['code', 'modular_redtard']

TYPE_LINE = re.compile(r'^(/[A-Za-z0-9_/]+)\s*$')
VAR_LINE = re.compile(r'^(?:var/(?:[A-Za-z0-9_]+/)*)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$')
DEFINE_LINE = re.compile(r'^\s*#define\s+([A-Za-z_][A-Za-z0-9_]*)\b')
STRING_LITERAL = re.compile(r'^"(?:[^"\\\[]|\\.)*"$')
ICON_LITERAL = re.compile(r"^'([^']+)'$")
NUMBER = re.compile(r'^-?\d+(?:\.\d+)?$')
COLOR = re.compile(r'^"#[0-9A-Fa-f]{3,8}"$')
PROC_LINE = re.compile(r'^(/[A-Za-z0-9_/]+?)/(?:proc/|verb/)?([A-Za-z_][A-Za-z0-9_]*)\(')
PROCS = collections.defaultdict(set)
PRE_EQUIP = {}
ONMOB = {}
INIT_BODIES = {}
FILL_BODIES = {}
STORAGE_NEW = {}
SKIN_LISTS = {}
OUTFIT_PROCS = {}
HUMAN_PROCS = {}
NPC_ROOT = '/mob/living/carbon/human'
NPC_PROCS = ('Initialize', 'after_creation')
NPC_OUTFIT_ROOT = '/datum/outfit/job/roguetown'
NPC_SLOTS = {'id': 'ring'}
NPC_STATS = {'STR': 'strength', 'PER': 'perception', 'INT': 'intelligence', 'CON': 'constitution', 'WIL': 'willpower', 'END': 'endurance', 'SPD': 'speed', 'LUC': 'fortune'}
STAT_ASSIGN = re.compile(r'\b(?:H|human|user)\.STA([A-Z]{3})\s*(=|\+=|-=)\s*(-?\d+)\b')
ITEM_PATH = re.compile(r'/obj/item/[A-Za-z0-9_/]*[A-Za-z0-9_]')
HOLD_LIST =re.compile(r'(?:typecacheof|set_holdable)\(\s*list\(')
NEW_IN_SRC = re.compile(r'new\s+(/obj/item/[A-Za-z0-9_/]+)\s*\(\s*src\s*\)')
LOOT_LIST = re.compile(r'\bloot\s*=\s*list\(([^)]*)\)')
PROB_CALL = re.compile(r'\bprob\((\d+)\)')
ONMOB_TAGS = ('onback', 'onbelt', 'gen', 'wielded')
DEFINE_VALUES = {}
SOURCE_REVISION = []
ARMOR_DATUMS = {}
ROGUE_ARMOR_DATUMS = {}
USED_INTENTS = set()
BAKE_JOBS = collections.defaultdict(dict)
BAKE_NAMES = {}
ABOVE_KEYS = ('northabove', 'southabove', 'eastabove', 'westabove')
ALT_GRIP_ROOT = '/datum/alt_grip'
DEFAULT_INTENTS = ('/datum/intent/use',)
BLANK_USERS = set()
FEMALE_USERS = set()
BITMASK_TURFS = set()
NO_SPRITE = []
LISTINGS = {}
# A folder of Ratwood's that carries a terms file of its own is never ported: the port takes only what the repository's own
# terms cover. EXCLUDED: such a folder -> the types that wanted something from it (they get no sprite).
TERMS_FILE = re.compile(r'(?i)^(licen[cs]e|copying)([-_.][\w.-]*)?$')
CURRENT = [None]
# --offline: no git in the Ratwood cache (no sync, no sparse-checkout of missing files); the cache is read as it stands.
OFFLINE = '--offline' in sys.argv
EXCLUDED = collections.defaultdict(set)


def excluded_folder(rel):
    parts = rel.split('/')[:-1]
    for depth in range(len(parts), 0, -1):
        folder = os.path.join(CHECKOUT, *parts[:depth])
        if folder not in LISTINGS:
            LISTINGS[folder] = {name.lower(): name for name in os.listdir(folder)} if os.path.isdir(folder) else {}
        for name in LISTINGS[folder].values():
            if TERMS_FILE.match(name) and os.path.isfile(os.path.join(folder, name)):
                return '/'.join(parts[:depth])
    return None


def asset_allowed(rel):
    folder = excluded_folder(rel)
    if folder is None:
        return True
    EXCLUDED[folder].add(CURRENT[0])
    return False


def exact_case(root, rel):
    parts = rel.replace('\\', '/').split('/')
    current = root
    fixed = []
    for part in parts:
        if current not in LISTINGS:
            LISTINGS[current] = {name.lower(): name for name in os.listdir(current)} if os.path.isdir(current) else {}
        name = LISTINGS[current].get(part.lower(), part)
        fixed.append(name)
        current = os.path.join(current, name)
    return '/'.join(fixed)
COVERAGE_MAP = {
    'HEAD': 'HEAD', 'MOUTH': 'HEAD', 'NOSE': 'HEAD', 'EARS': 'HEAD', 'HAIR': 'HEAD', 'LEFT_EYE': 'HEAD', 'RIGHT_EYE': 'HEAD',
    'CHEST': 'CHEST', 'VITALS': 'CHEST', 'GROIN': 'GROIN', 'NECK': 'NECK',
    'LEG_LEFT': 'LEG_LEFT', 'LEG_RIGHT': 'LEG_RIGHT', 'FOOT_LEFT': 'FOOT_LEFT', 'FOOT_RIGHT': 'FOOT_RIGHT',
    'ARM_LEFT': 'ARM_LEFT', 'ARM_RIGHT': 'ARM_RIGHT', 'HAND_LEFT': 'HAND_LEFT', 'HAND_RIGHT': 'HAND_RIGHT',
}
# Ratwood's body part flags (code/__DEFINES/inventory.dm) as the flags of the module's rogue_coverage, in the order written:
# TG's own for the parts TG has, ROGUE_COVER_* (clothing/_defines.dm) for the rest.
EXACT_COVERAGE = OrderedDict((
    ('HEAD', 'HEAD'), ('HAIR', 'ROGUE_COVER_HAIR'), ('EARS', 'ROGUE_COVER_EARS'),
    ('RIGHT_EYE', 'ROGUE_COVER_RIGHT_EYE'), ('LEFT_EYE', 'ROGUE_COVER_LEFT_EYE'),
    ('NOSE', 'ROGUE_COVER_NOSE'), ('MOUTH', 'ROGUE_COVER_MOUTH'), ('NECK', 'NECK'),
    ('CHEST', 'CHEST'), ('VITALS', 'ROGUE_COVER_VITALS'), ('GROIN', 'GROIN'),
    ('ARM_RIGHT', 'ARM_RIGHT'), ('ARM_LEFT', 'ARM_LEFT'), ('HAND_RIGHT', 'HAND_RIGHT'), ('HAND_LEFT', 'HAND_LEFT'),
    ('LEG_RIGHT', 'LEG_RIGHT'), ('LEG_LEFT', 'LEG_LEFT'), ('FOOT_RIGHT', 'FOOT_RIGHT'), ('FOOT_LEFT', 'FOOT_LEFT'),
))
# Pairs and groups written by one name, the largest first.
EXACT_COVERAGE_GROUPS = (
    ('ROGUE_COVER_HEAD_PARTS', ('HAIR', 'EARS', 'RIGHT_EYE', 'LEFT_EYE', 'NOSE', 'MOUTH')),
    ('ROGUE_COVER_FACE', ('EARS', 'RIGHT_EYE', 'LEFT_EYE', 'NOSE', 'MOUTH')),
    ('ROGUE_COVER_EYES', ('RIGHT_EYE', 'LEFT_EYE')),
    ('ARMS', ('ARM_RIGHT', 'ARM_LEFT')), ('HANDS', ('HAND_RIGHT', 'HAND_LEFT')),
    ('LEGS', ('LEG_RIGHT', 'LEG_LEFT')), ('FEET', ('FOOT_RIGHT', 'FOOT_LEFT')),
)
HEAD_PARTS = {'HAIR', 'EARS', 'RIGHT_EYE', 'LEFT_EYE', 'NOSE', 'MOUTH'}
OUTFIT_SLOTS = {
    'head': 'head', 'mask': 'mask', 'mouth': 'mouth', 'neck': 'neck', 'cloak': 'cloak', 'armor': 'suit',
    'shirt': 'shirt', 'pants': 'uniform', 'wrists': 'wrists', 'gloves': 'gloves', 'shoes': 'shoes',
    'belt': 'belt', 'beltl': 'l_pocket', 'beltr': 'r_pocket', 'backl': 'back', 'backr': 'backr',
    'ring': 'ring', 'l_hand': 'l_hand', 'r_hand': 'r_hand',
}
SLOT_FLAG_MAP = {
    'ITEM_SLOT_PANTS': 'ITEM_SLOT_ICLOTHING', 'ITEM_SLOT_ICLOTHING': 'ITEM_SLOT_ICLOTHING',
    'ITEM_SLOT_SHIRT': 'ITEM_SLOT_ROGUE_SHIRT', 'ITEM_SLOT_ARMOR': 'ITEM_SLOT_OCLOTHING',
    'ITEM_SLOT_OCLOTHING': 'ITEM_SLOT_OCLOTHING', 'ITEM_SLOT_SHOES': 'ITEM_SLOT_FEET',
    'ITEM_SLOT_GLOVES': 'ITEM_SLOT_GLOVES', 'ITEM_SLOT_RING': 'ITEM_SLOT_ROGUE_RING',
    'ITEM_SLOT_MOUTH': 'ITEM_SLOT_ROGUE_MOUTH', 'ITEM_SLOT_MASK': 'ITEM_SLOT_MASK', 'ITEM_SLOT_HEAD': 'ITEM_SLOT_HEAD',
    'ITEM_SLOT_CLOAK': 'ITEM_SLOT_ROGUE_CLOAK', 'ITEM_SLOT_NECK': 'ITEM_SLOT_NECK', 'ITEM_SLOT_BELT': 'ITEM_SLOT_BELT',
    'ITEM_SLOT_BACK_R': 'ITEM_SLOT_BACK', 'ITEM_SLOT_BACK_L': 'ITEM_SLOT_BACK', 'ITEM_SLOT_BACK': 'ITEM_SLOT_BACK',
    'ITEM_SLOT_HIP': 'ITEM_SLOT_POCKETS', 'ITEM_SLOT_WRISTS': 'ITEM_SLOT_ROGUE_WRISTS',
}
SMOOTH_DIR = 'modular_redtard/rockhill/icons/smooth'
SOUND_DIR = 'modular_redtard/rockhill/sound'
EDGES_FILE = 'turf_edges.dm'
SMOOTHING_FILE = '_smoothing.dm'
AREAS_JSON = 'areas.json'
SUNLIT_LEAF = 'sunlit'
TG_LAYERS = 'code/__DEFINES/layers.dm'
SMOOTH_BITS = {'SMOOTH_TRUE': 1, 'SMOOTH_MORE': 2, 'SMOOTH_DIAGONAL': 4, 'SMOOTH_BORDER': 8}
BYOND_LAYERS = {'AREA_LAYER': '1', 'TURF_LAYER': '2', 'OBJ_LAYER': '3', 'MOB_LAYER': '4', 'FLY_LAYER': '5', 'EFFECTS_LAYER': '5000', 'TOPDOWN_LAYER': '10000', 'BACKGROUND_LAYER': '20000'}
BYOND_DIRECTIONS = {'NORTH', 'SOUTH', 'EAST', 'WEST', 'NORTHEAST', 'NORTHWEST', 'SOUTHEAST', 'SOUTHWEST', 'UP', 'DOWN'}
TURF_GROUP_BASE = 1000
OBJ_GROUP_BASE = 2000


def strip_comments(text):
    out = []
    i = 0
    n = len(text)
    state = None
    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ''
        if state == 'block':
            if c == '*' and nxt == '/':
                state = None
                i += 2
                continue
            if c == '\n':
                out.append(c)
            i += 1
            continue
        if state == 'dq':
            out.append(c)
            if c == '\\':
                out.append(nxt)
                i += 2
                continue
            if c == '"' or c == '\n':
                state = None
            i += 1
            continue
        if state == 'sq':
            out.append(c)
            if c == "'" or c == '\n':
                state = None
            i += 1
            continue
        if state == 'long':
            out.append(c)
            if c == '"' and nxt == '}':
                out.append(nxt)
                state = None
                i += 2
                continue
            i += 1
            continue
        if c == '/' and nxt == '*':
            state = 'block'
            i += 2
            continue
        if c == '/' and nxt == '/':
            while i < n and text[i] != '\n':
                i += 1
            continue
        if c == '{' and nxt == '"':
            out.append('{"')
            state = 'long'
            i += 2
            continue
        if c == '"':
            state = 'dq'
        elif c == "'":
            state = 'sq'
        out.append(c)
        i += 1
    return ''.join(out)


def included_files(code_root):
    dme = [f for f in os.listdir(code_root) if f.endswith('.dme')]
    if len(dme) > 1:
        # The module build leaves a temporary copy beside the upstream one while it compiles
        # (tgstation.redtard.m.dme, build/build_modular.ts); the upstream tgstation.dme is the one to read.
        upstream = [f for f in dme if f.count('.') == 1]
        dme = ['tgstation.dme'] if 'tgstation.dme' in dme else upstream
    if len(dme) != 1:
        raise SystemExit(f'expected one .dme in {code_root}, found {dme}')
    files = []
    for line in open(os.path.join(code_root, dme[0]), encoding='utf-8', errors='ignore'):
        m = re.match(r'^#include "(.+)"', line.strip())
        if m and m.group(1).endswith('.dm'):
            files.append(os.path.join(code_root, m.group(1).replace('\\', '/')))
    return files


def parse_codebase(code_root):
    types = collections.defaultdict(dict)
    defines = set()
    for path in included_files(code_root):
        if not os.path.exists(path):
            continue
        text = strip_comments(open(path, encoding='utf-8', errors='ignore').read())
        lines = text.split('\n')
        current = None
        i = 0
        while i < len(lines):
            line = lines[i].rstrip()
            i += 1
            if not line.strip():
                continue
            dm = DEFINE_LINE.match(line)
            if dm:
                defines.add(dm.group(1))
                rest = line[dm.end():]
                while rest.rstrip().endswith('\\') and i < len(lines):
                    rest = rest.rstrip()[:-1] + ' ' + lines[i].strip()
                    i += 1
                if not rest.startswith('('):
                    DEFINE_VALUES[dm.group(1)] = rest.strip()
                continue
            if line.startswith('#'):
                continue
            if not line.startswith(('\t', ' ')):
                m = TYPE_LINE.match(line)
                if m and '/proc/' not in m.group(1) and '/verb/' not in m.group(1):
                    current = m.group(1).rstrip("/")
                    types[current]
                else:
                    current = None
                    pm = PROC_LINE.match(line)
                    if pm:
                        owner, name = pm.group(1), pm.group(2)
                        PROCS[owner].add(name)
                        bodies = {
                            'pre_equip': ('/datum/outfit/', PRE_EQUIP),
                            'getonmobprop': ('/obj/item', ONMOB),
                            'Initialize': (('/turf/', '/obj/structure', '/obj/machinery', '/obj/item'), INIT_BODIES),
                            'PopulateContents': ('/obj/structure/closet', FILL_BODIES),
                            'New': ('/datum/component/storage', STORAGE_NEW),
                            'get_skin_list': ('/datum/species', SKIN_LISTS),
                        }.get(name)
                        stores = []
                        if bodies and owner.startswith(bodies[0]):
                            stores.append((bodies[1], owner))
                        if owner.startswith('/datum/outfit/'):
                            stores.append((OUTFIT_PROCS, (owner, name)))
                        if boundary_match(owner, NPC_ROOT) and name in NPC_PROCS:
                            stores.append((HUMAN_PROCS, (owner, name)))
                        if stores:
                            body = []
                            while i < len(lines) and (not lines[i].strip() or lines[i].startswith(('\t', ' '))):
                                body.append(lines[i].rstrip())
                                i += 1
                            for store, key in stores:
                                store[key] = body
                continue
            if current is None:
                continue
            body = line[1:] if line.startswith('\t') else line.lstrip(' ')
            if body.startswith(('\t', ' ')):
                continue
            m = VAR_LINE.match(body.strip())
            if not m:
                continue
            name, value = m.group(1), m.group(2).strip()
            while value.endswith('\\') and i < len(lines):
                value = value[:-1].rstrip() + ' ' + lines[i].strip()
                i += 1
            if value.startswith('list('):
                while value.count('(') > value.count(')') and i < len(lines):
                    value = value + ' ' + lines[i].strip()
                    i += 1
            if value.startswith('{"') and not value.endswith('"}'):
                parts = [value]
                while i < len(lines) and not parts[-1].rstrip().endswith('"}'):
                    parts.append(lines[i].rstrip())
                    i += 1
                value = '\n'.join(parts)
            types[current][name] = value
    return types, defines


class Codebase:
    def __init__(self, types):
        self.types = types

    def parent(self, path):
        pt = self.types.get(path, {}).get('parent_type')
        if pt and pt.startswith('/'):
            return pt
        if path.count('/') <= 1:
            return None
        return path.rsplit('/', 1)[0]

    def resolve(self, path, var):
        seen = set()
        p = path
        while p and p not in seen:
            seen.add(p)
            value = self.types.get(p, {}).get(var)
            if value is not None:
                return value
            p = self.parent(p)
        return None


def declared_paths(roots, exclude):
    declared = set()
    exclude = [os.path.normpath(e) for e in exclude]
    for root in roots:
        for dp, dn, fn in os.walk(root):
            if any(os.path.normpath(dp).startswith(e) for e in exclude):
                continue
            for f in fn:
                if not f.endswith('.dm'):
                    continue
                for line in open(os.path.join(dp, f), encoding='utf-8', errors='ignore'):
                    m = re.match(r'^(/[A-Za-z0-9_/]+)(\()?', line)
                    if not m:
                        continue
                    # A proc defined by its full path (/obj/item/x/proc/y(), /obj/item/x/y()) or a var by
                    # /obj/item/x/var/y declares /obj/item/x, not a type named after the proc or var.
                    parts = m.group(1).rstrip('/').split('/')
                    if m.group(2):
                        parts = parts[:-1]
                    for keyword in ('proc', 'verb', 'var'):
                        if keyword in parts:
                            parts = parts[:parts.index(keyword)]
                    for k in range(2, len(parts) + 1):
                        declared.add('/'.join(parts[:k]))
    if len(declared) < 10000:
        raise SystemExit(f'type scanner found only {len(declared)} paths; run from the repository root')
    return declared


def tg_defines(root):
    names = set()
    for dp, dn, fn in os.walk(os.path.join(root, '__DEFINES')):
        for f in fn:
            if f.endswith('.dm'):
                for line in open(os.path.join(dp, f), encoding='utf-8', errors='ignore'):
                    m = DEFINE_LINE.match(line)
                    if m:
                        names.add(m.group(1))
    return names


def random_pick(rw, path):
    p = path
    while p:
        body = '\n'.join(INIT_BODIES.get(p, []))
        if body:
            match = re.search(r'pick\(\s*list\(([^)]*)\)\s*\)', body)
            if match and 'INITIALIZE_HINT_QDEL' in body and re.search(r'\bnew\b', body):
                return [found for found, _ in list_paths(match.group(1))]
            return []
        p = rw.parent(p)
    return []


def state_leaf(state):
    return 'state_' + re.sub(r'[^A-Za-z0-9_]', '_', state)


def smooth_bits(raw):
    value = (raw or '').strip()
    if NUMBER.match(value):
        return int(float(value))
    bits = 0
    for token in re.findall(r'[A-Z_]+', value):
        bits |= SMOOTH_BITS.get(token, 0)
    return bits


def smooth_rule(rw, path):
    bits = smooth_bits(rw.resolve(path, 'smooth'))
    if not bits & (SMOOTH_BITS['SMOOTH_TRUE'] | SMOOTH_BITS['SMOOTH_MORE']):
        return None
    raw = (rw.resolve(path, 'canSmoothWith') or '').strip()
    return {
        'more': bool(bits & SMOOTH_BITS['SMOOTH_MORE']),
        'entries': None if not raw or raw == 'null' else re.findall(r'(/(?:turf|obj)/[A-Za-z0-9_/]+)', raw),
        'diagonal': (rw.resolve(path, 'smooth_diag') or 'TRUE').strip() not in ('FALSE', '0'),
        'border': bool(bits & SMOOTH_BITS['SMOOTH_BORDER']),
    }


def smooth_matches(path, rule, candidates):
    if rule['entries'] is None:
        return [path] if path in candidates else []
    return sorted(q for q in candidates if any(q == e or (rule['more'] and q.startswith(e + '/')) for e in rule['entries']))


def group_define(runtime):
    return 'SMOOTH_GROUP_ROCKHILL_' + re.sub(r'[^A-Za-z0-9]+', '_', runtime.split('/', 2)[2]).upper().strip('_')


def define_number(expr, table, depth=0):
    if depth > 16:
        raise ValueError(expr)

    def value_of(match):
        name = match.group(0)
        raw = BYOND_LAYERS.get(name) if name in BYOND_LAYERS else table.get(name)
        if raw is None:
            raise ValueError(name)
        return '(' + repr(define_number(raw, table, depth + 1)) + ')'

    text = re.sub(r'[A-Za-z_][A-Za-z0-9_]*', value_of, (expr or '').strip())
    if not text or not re.fullmatch(r'[\d\s.+\-*/()]+', text):
        raise ValueError(expr)
    return float(eval(text, {'__builtins__': {}}))


def tg_define_values(path):
    values = {}
    for line in open(path, encoding='utf-8', errors='ignore'):
        m = re.match(r'^\s*#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+(.+?)\s*(?://.*)?$', line)
        if m:
            values[m.group(1)] = m.group(2)
    return values


def number_or_none(raw, table):
    try:
        return define_number(raw, table) if raw else None
    except ValueError:
        return None


def layer_expression(raw, value, tg_values):
    m = re.fullmatch(r'([A-Z_][A-Z0-9_]*)(?:\s*([+-])\s*(\d+(?:\.\d+)?))?', raw.strip())
    if m:
        tg = number_or_none(m.group(1), tg_values)
        ours = number_or_none(m.group(1), DEFINE_VALUES)
        if tg is not None and ours is not None and abs(tg - ours) < 1e-9 and tg < define_number('TOPDOWN_LAYER', tg_values):
            return m.group(1) if not m.group(2) else f'{m.group(1)} {m.group(2)} {m.group(3)}'
    return f'{value:g}'



TG_PLANES = {'floor': 'FLOOR_PLANE', 'lower': 'GAME_PLANE', 'game': 'GAME_PLANE', 'upper': 'ABOVE_GAME_PLANE'}


def plane_kind(rw, path, decal):
    plane = number_or_none(rw.resolve(path, 'plane') or rw.types.get('/atom', {}).get('plane'), DEFINE_VALUES)
    if plane is None:
        return 'floor' if decal else 'game'
    if plane <= define_number('WALL_PLANE', DEFINE_VALUES):
        return 'floor'
    if plane < define_number('GAME_PLANE_FOV_HIDDEN', DEFINE_VALUES):
        return 'lower'
    if plane == define_number('GAME_PLANE_FOV_HIDDEN', DEFINE_VALUES):
        return 'game'
    return 'upper'


def placement_lines(rw, path, runtime, tg_values, placed=frozenset()):
    raw_layer = rw.resolve(path, 'layer')
    layer = number_or_none(raw_layer, DEFINE_VALUES)
    decal = boundary_match(runtime, '/obj/effect/decal') or boundary_match(runtime, '/obj/effect/turf_decal')
    base_plane = 'FLOOR_PLANE' if decal else 'GAME_PLANE'
    kind = plane_kind(rw, path, decal)
    tg_plane = TG_PLANES[kind]
    # The plane the type has without a line of its own: its placed parent's (which always ends up with its own TG plane),
    # else the base plane of the TG type it hangs on. Comparing with the base only let a lower child (Ratwood's floor
    # grille, GAME_PLANE_LOWER) keep its upper parent's ABOVE_GAME_PLANE (bars) and draw over the mobs on it.
    parent = rw.parent(path)
    inherited = TG_PLANES[plane_kind(rw, parent, decal)] if parent in placed else base_plane
    lines = [f'\tplane = {tg_plane}'] if tg_plane != inherited else []
    if kind == 'floor':
        if not decal:
            lines.append('\tlayer = ABOVE_OPEN_TURF_LAYER')
        return lines
    if layer is None:
        if decal:
            lines.append('\tlayer = LOW_OBJ_LAYER')
        return lines
    if kind == 'lower' and layer > define_number('BELOW_MOB_LAYER', tg_values):
        lines.append('\tlayer = BELOW_MOB_LAYER')
        return lines
    lines.append(f'\tlayer = {layer_expression(raw_layer, layer, tg_values)}')
    return lines


def turf_state_edits(map_path):
    edits = set()
    current = None
    for line in open(map_path, encoding='utf-8'):
        line = line.rstrip('\n')
        if line.startswith('('):
            break
        match = re.match(r'^(/turf/[A-Za-z0-9_/]+)\{$', line)
        if match:
            current = match.group(1)
            continue
        if current:
            state = re.match(r'^\s*icon_state = "([^"\[\\]*)";?$', line)
            if state:
                edits.add((current, state.group(1)))
            if re.match(r'^\s*\}[,)]$', line):
                current = None
    return edits


def source_maps(cfg, rw=None):
    maps = [cfg['source']['map']]
    listing = cfg['source'].get('map_json')
    entries = []
    if listing:
        world = json.load(open(os.path.join(CHECKOUT, listing), encoding='utf-8'))
        entries += world.get('other_z', [])
    entries += cfg['source'].get('always_other_z', [])
    for entry in entries:
        conf = json.load(open(os.path.join(CHECKOUT, entry), encoding='utf-8'))
        maps.append(f"_maps/{conf['map_path']}/{conf['map_file']}")
    spec = cfg['port'].get('dungeon_templates')
    if spec and rw:
        maps += [template['source'] for template in dungeon_templates(rw, spec)]
    return maps


def dungeon_templates(rw, spec):
    out = []
    for path in sorted(rw.types):
        if not boundary_match(path, spec['prefix']):
            continue
        mappath = (rw.resolve(path, 'mappath') or '').strip().strip('"')
        abstract = (rw.resolve(path, 'abstract_type') or '').strip() == path
        if abstract or mappath in ('', 'null'):
            continue
        rel = mappath[len('_maps/'):] if mappath.startswith('_maps/') else mappath
        out.append({'type': path, 'source': mappath, 'output': f"{spec['output_dir']}/{rel.split('/', 1)[1] if '/' in rel else rel}"})
    return out


def generate_dungeon_templates(rw, spec, tg_names):
    templates = dungeon_templates(rw, spec)
    blocks = []
    for path in sorted(p for p in rw.types if boundary_match(p, spec['prefix']) and p != spec['prefix']):
        block = [path]
        if (rw.types[path].get('abstract_type') or '').strip() == path:
            block.append(f'\tabstract_type = {path}')
        for name in spec['vars']:
            value = literal(rw.types[path].get(name), tg_names)
            if value is not None:
                block.append(f'\t{name} = {value}')
        found = next((t for t in templates if t['type'] == path), None)
        if found:
            block.append(f'\tmappath = "{found["output"]}"')
        blocks.append(block)
    open(f"{OUT_DIR}/{spec['file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    open(spec['manifest'], 'w', encoding='utf-8', newline='\n').write(json.dumps([{'source': t['source'], 'output': t['output']} for t in templates], indent='\t') + '\n')
    print(f"{spec['file']}: {len(blocks)} dungeon templates, {len(templates)} maps")


SKILL_CALL = re.compile(r'\b(?:H|human|user)\.(?:mind\??\.)?(adjust_skillrank(?:_up_to)?)\(\s*(/datum/skill/[A-Za-z0-9_/]+)\s*,\s*([A-Z_0-9]+|-?\d+)')
STAT_CALL = re.compile(r'\b(?:H|human|user)\.change_stat\(\s*(STATKEY_[A-Z]+|"[a-z]+")\s*,\s*(-?\d+)\s*\)')
TRAIT_CALL = re.compile(r'\bADD_TRAIT\(\s*(?:H|human|user)\s*,\s*(TRAIT_[A-Z0-9_]+)\s*,')
CONTROL_LINE = re.compile(r'^(if|else|for|switch|while|do)\b(.*)$')
ROGUE_TRAITS_FILE = 'code/__DEFINES/traits.dm'


def unconditional_lines(body):
    lines = []
    stack = []
    for line in body:
        text = line.strip()
        if not text:
            continue
        indent = len(line) - len(line.lstrip('\t'))
        while stack and stack[-1][0] >= indent:
            stack.pop()
        control = CONTROL_LINE.match(text)
        if control:
            mind_only = control.group(1) == 'if' and re.fullmatch(r'\(\s*H\.mind\s*\)', control.group(2).strip()) is not None
            stack.append((indent, mind_only))
            continue
        if all(ok for _, ok in stack):
            lines.append(text)
    return lines


def rogue_trait_table():
    text = strip_comments(open(os.path.join(CHECKOUT, ROGUE_TRAITS_FILE), encoding='utf-8', errors='ignore').read())
    start = text.find('GLOBAL_LIST_INIT(roguetraits, list(')
    if start < 0:
        raise SystemExit(f'{ROGUE_TRAITS_FILE}: no roguetraits list')
    body = text[start:text.find('\n))', start)]
    table = {}
    for name, span, desc in re.findall(r'(TRAIT_[A-Z0-9_]+)\s*=\s*(span_[a-z_]+)\(\s*("(?:[^"\\]|\\.)*")\s*\)', body):
        if STRING_LITERAL.match(desc):
            table[name] = (span, desc)
    return table


def generate_traits(cfg, tg_names, needed):
    spec = cfg['traits']
    table = rogue_trait_table()
    extra = spec.get('extra', {})
    for name, entry in {**extra, **spec.get('descriptions', {})}.items():
        table[name] = (entry['span'], json.dumps(entry['text']))
    wanted = sorted(set(table) | set(needed))
    defines = []
    skipped = []
    for name in wanted:
        if name in tg_names:
            continue
        value = json.dumps(extra[name]['value']) if name in extra else DEFINE_VALUES.get(name, '').strip()
        if not STRING_LITERAL.match(value):
            skipped.append(name)
            continue
        defines.append(f'#define {name} {value}')
    known = (set(tg_names) | {line.split()[1] for line in defines})
    descriptions = [f'\t{name} = {span}({desc}),' for name, (span, desc) in sorted(table.items()) if name in known and span in tg_names]
    out = defines + ['', 'GLOBAL_LIST_INIT(rogue_trait_descriptions, list('] + descriptions + ['\t))']
    open(spec['output'], 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
    print(f"traits: {len(defines)} defines, {len(descriptions)} descriptions, {len(skipped)} without a string value")
    return known


def role_attributes(rw, job, advclass, outfit_source, attr_cfg):
    scale = attr_cfg['level_scale']
    stats = collections.Counter()
    skills = {}
    traits = []

    def stat_key(token):
        return attr_cfg['stats'].get(expand_define(token).strip('"'))

    def level(token):
        value = expand_define(token)
        return int(float(value)) * scale if NUMBER.match(value) else None

    def raise_skill(path, token, additive):
        value = level(token)
        if value is None:
            return
        skills[path] = skills.get(path, 0) + value if additive else max(skills.get(path, 0), value)

    if advclass:
        for token, amount in re.findall(r'(STATKEY_[A-Z]+|"[a-z]+")\s*=\s*(-?\d+)', rw.resolve(advclass, 'subclass_stats') or ''):
            if stat_key(token):
                stats[stat_key(token)] += int(amount)
        for path, token in re.findall(r'(/datum/skill/[A-Za-z0-9_/]+)\s*=\s*([A-Z_0-9]+|\d+)', rw.resolve(advclass, 'subclass_skills') or ''):
            raise_skill(path, token, False)
        traits += re.findall(r'(TRAIT_[A-Z0-9_]+)', rw.resolve(advclass, 'traits_applied') or '')
    else:
        for token, amount in re.findall(r'(STATKEY_[A-Z]+|"[a-z]+")\s*=\s*(-?\d+)', rw.resolve(job, 'job_stats') or ''):
            if stat_key(token):
                stats[stat_key(token)] += int(amount)
    traits += re.findall(r'(TRAIT_[A-Z0-9_]+)', rw.resolve(job, 'job_traits') or '')
    parts = (outfit_source or '').split('/')
    for k in range(3, len(parts) + 1):
        outfit = '/'.join(parts[:k])
        for text in unconditional_lines(PRE_EQUIP.get(outfit, [])):
            for call, path, token in SKILL_CALL.findall(text):
                raise_skill(path, token, call == 'adjust_skillrank')
            for token, amount in STAT_CALL.findall(text):
                if stat_key(token):
                    stats[stat_key(token)] += int(amount)
            traits += TRAIT_CALL.findall(text)
    traits += attr_cfg.get('extra_traits', {}).get(job, [])
    return {'stats': {k: v for k, v in stats.items() if v}, 'skills': skills, 'traits': list(dict.fromkeys(traits))}


def generate_skills(cfg, rw):
    spec = cfg['attributes']
    blocks = []
    for path, meta in spec['meta'].items():
        if path not in rw.types:
            raise SystemExit(f'attributes.meta: {path} is not a Ratwood skill')
        target = spec['skill_target'] + path[len(spec['skill_root']):]
        block = [target]
        for var in ('name', 'desc'):
            value = string_value(rw.resolve(path, var))
            if value and value != '""':
                block.append(f'\t{var} = {value}')
        block.append(f"\tcategory = {meta['category']}")
        block.append(f"\tdifficulty = {meta['difficulty']}")
        if meta.get('governing'):
            block.append(f"\tgoverning_attribute = {meta['governing']}")
        if meta.get('defaults'):
            block += ['\tdefault_attributes = list('] + [f'\t\t{k} = {v},' for k, v in meta['defaults'].items()] + ['\t\t)']
        dreams = [d for d in re.findall(r'"(?:[^"\\]|\\.)*"', rw.resolve(path, 'dreams') or '') if STRING_LITERAL.match(d)]
        if dreams:
            block += ['\tdreams = list('] + [f'\t\t{d},' for d in dreams] + ['\t\t)']
        blocks.append(block)
    missing = sorted(p for p in rw.types if p.startswith(spec['skill_root'] + '/') and p not in spec['meta'] and (rw.types[p].get('abstract_type') or '').strip() != p)
    if missing:
        raise SystemExit('Ratwood skills without attributes.meta entries:\n  ' + '\n  '.join(missing))
    open(f"{OUT_DIR}/{spec['skills_file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['skills_file']}: {len(blocks)} skills")


def generate_attribute_sheets(cfg, rw, jobs, role_outfits, known_traits):
    spec = cfg['attributes']
    blocks = []
    per_job = {}
    unknown_skills = collections.Counter()
    unknown_traits = collections.Counter()
    for job in jobs:
        dressed = role_outfits.get(job, {})
        data = role_attributes(rw, job, dressed.get('advclass'), dressed.get('source'), spec)
        entries = [f'\t\t{stat} = {amount},' for stat, amount in sorted(data['stats'].items())]
        for path, value in sorted(data['skills'].items()):
            if path not in spec['meta']:
                unknown_skills[path] += 1
                continue
            entries.append(f"\t\t{spec['skill_target'] + path[len(spec['skill_root']):]} = {min(value, 60)},")
        traits = []
        for trait in data['traits']:
            if trait in known_traits:
                traits.append(trait)
            else:
                unknown_traits[trait] += 1
        sheet = None
        if entries:
            sheet = spec['sheet_root'] + job[len(JOB_ROOT):]
            blocks.append([sheet, '\traw_attribute_list = list('] + entries + ['\t\t)'])
        per_job[job] = {'sheet': sheet, 'traits': traits}
    open(f"{OUT_DIR}/{spec['sheets_file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['sheets_file']}: {len(blocks)} role sheets")
    if unknown_skills:
        print('  skills without a port:', ', '.join(f'{p} ({n})' for p, n in unknown_skills.most_common()))
    if unknown_traits:
        print('  traits without a define:', ', '.join(f'{p} ({n})' for p, n in unknown_traits.most_common()))
    return per_job


def map_usage(map_path):
    lines = open(map_path, encoding='utf-8').read().split('\n')
    models = {}
    tiles = collections.Counter()
    levels = collections.defaultdict(collections.Counter)
    i = 0
    while i < len(lines):
        m = re.match(r'^"([^"]+)" = \($', lines[i])
        if m:
            paths = []
            j = i + 1
            while True:
                pm = re.match(r'^(/[A-Za-z0-9_/]+)', lines[j])
                if pm:
                    paths.append(pm.group(1))
                if re.match(r'^\s*\}?\)$', lines[j]) or lines[j].endswith(')'):
                    break
                j += 1
            models[m.group(1)] = paths
            i = j + 1
            continue
        m = re.match(r'^\((\d+),(\d+),(\d+)\) = \{"$', lines[i])
        if m:
            z = int(m.group(3))
            j = i + 1
            while lines[j] != '"}':
                tiles[lines[j]] += 1
                levels[z][lines[j]] += 1
                j += 1
            i = j + 1
            continue
        i += 1
    usage = collections.Counter()
    for key, count in tiles.items():
        for p in models[key]:
            usage[p] += count
    per_level = {}
    for z, counter in levels.items():
        c = collections.Counter()
        for key, count in counter.items():
            for p in models[key]:
                c[p] += count
        per_level[z] = c
    return usage, per_level


def boundary_match(path, prefix):
    return path == prefix or path.startswith(prefix + '/')


def replacement_for(path, rules):
    best = None
    for rule in rules:
        matched = path == rule['prefix'] if rule.get('exact') else boundary_match(path, rule['prefix'])
        if matched and (best is None or len(rule['prefix']) > len(best['prefix'])):
            best = rule
    return best


def loot_entries(raw):
    if not raw:
        return []
    return [(item, int(weight) if weight else 1) for item, weight in re.findall(r'(/obj/item/[A-Za-z0-9_/]+)\s*(?:=\s*(\d+))?', raw)]


def closet_fill(rw, path):
    contents, loot, chance = [], [], 100
    p = path
    while p and p.startswith('/obj/structure/closet'):
        for bodies in (INIT_BODIES, FILL_BODIES):
            body = '\n'.join(bodies.get(p, []))
            contents += NEW_IN_SRC.findall(body)
            m = LOOT_LIST.search(body)
            if m and not loot:
                loot = [(item, int(float(weight)) if weight else 1) for item, weight in list_paths(m.group(1))]
                pm = PROB_CALL.search(body)
                chance = int(pm.group(1)) if pm else 100
        p = rw.parent(p)
    return contents, loot, chance


def runtime_path(path, rules):
    rule = replacement_for(path, rules)
    if rule is None:
        return path
    if rule.get('drop'):
        return None
    if rule.get('rebase'):
        return rule['rebase'] + path[len(rule['prefix']):]
    return rule['to']


def tg_spelling(text):
    return re.sub(r'eciev', lambda m: m.group(0)[:2] + m.group(0)[3] + m.group(0)[2] + m.group(0)[4], text, flags=re.IGNORECASE)


def literal(value, tg_names):
    if value is None:
        return None
    v = value.strip()
    if v in ('TRUE', 'FALSE', 'null') or NUMBER.match(v):
        return v
    if STRING_LITERAL.match(v) or (v.startswith('{"') and v.endswith('"}')):
        return tg_spelling(v)
    if ICON_LITERAL.match(v):
        return v
    if re.match(r'^[A-Z_][A-Z0-9_]*$', v) and (v in tg_names or v in BYOND_DIRECTIONS):
        return v
    time = re.fullmatch(r'(\d+(?:\.\d+)?)\s*(SECONDS|MINUTES|DECISECONDS)', v)
    if time:
        return f'{time.group(1)} {time.group(2)}'
    return None


def checkout_root():
    return os.path.abspath(CHECKOUT)


def checkout_git_dir():
    return os.path.join(checkout_root(), '.git')


def same_path(a, b):
    return os.path.normcase(os.path.normpath(os.path.abspath(a))) == os.path.normcase(os.path.normpath(os.path.abspath(b)))


def git_env():
    env = dict(os.environ, GIT_CEILING_DIRECTORIES=os.path.dirname(checkout_root()))
    for name in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_COMMON_DIR'):
        env.pop(name, None)
    return env


def git(*args):
    command = ['git', '--git-dir', checkout_git_dir(), '--work-tree', checkout_root(), '-c', 'gc.auto=0', '-c', 'maintenance.auto=false', *args]
    return subprocess.run(command, check=True, capture_output=True, text=True, env=git_env(), cwd=os.path.dirname(checkout_root())).stdout


def checkout_valid():
    if not os.path.isfile(os.path.join(checkout_git_dir(), 'HEAD')):
        return False
    result = subprocess.run(['git', '--git-dir', checkout_git_dir(), 'rev-parse', '--absolute-git-dir'], capture_output=True, text=True, env=git_env(), cwd=os.path.dirname(checkout_root()))
    return result.returncode == 0 and same_path(result.stdout.strip(), checkout_git_dir())


def sync_source(source):
    cache_root = os.path.abspath('.cache')
    if not same_path(os.path.dirname(checkout_root()), cache_root) or same_path(checkout_git_dir(), '.git'):
        raise SystemExit(f'refusing to use {checkout_root()} as the Ratwood cache: it must be a folder inside {cache_root}')
    if not checkout_valid():
        if os.path.exists(checkout_root()):
            print('the Ratwood cache', CHECKOUT, 'is not a valid git repository; recloning it')
            shutil.rmtree(checkout_root())
        os.makedirs(os.path.dirname(checkout_root()), exist_ok=True)
        print('cloning', source['repository'], source['branch'], 'into', CHECKOUT)
        subprocess.run(['git', 'clone', '--depth', '1', '--filter=blob:none', '--no-checkout', '--config', 'gc.auto=0', '--config', 'maintenance.auto=false', '--branch', source['branch'], source['repository'], checkout_root()], check=True, env=git_env(), cwd=os.path.dirname(checkout_root()))
        if not checkout_valid():
            raise SystemExit(f'{CHECKOUT}: the fresh clone is not a valid git repository; refusing to run git there')
    elif '--no-pull' not in sys.argv:
        print('syncing', CHECKOUT, 'to', source['repository'], source['branch'])
        git('remote', 'set-url', 'origin', source['repository'])
        git('fetch', '--depth', '1', 'origin', source['branch'])
        git('reset', '--hard', 'FETCH_HEAD')
    git('config', 'gc.auto', '0')
    git('config', 'maintenance.auto', 'false')
    git('sparse-checkout', 'set', '--no-cone', *source['sparse'])
    git('read-tree', '-mu', 'HEAD')
    absent = [os.path.relpath(path, CHECKOUT).replace('\\', '/') for path in included_files(CHECKOUT) if not os.path.exists(path)]
    if absent:
        git('sparse-checkout', 'add', *('/' + path for path in absent))
        git('read-tree', '-mu', 'HEAD')
    absent = [path for path in included_files(CHECKOUT) if not os.path.exists(path)]
    if absent:
        raise SystemExit('files the Ratwood .dme includes are missing from ' + CHECKOUT + ':\n  ' + '\n  '.join(absent))
    SOURCE_REVISION[:] = git('log', '-1', '--format=%H %cs').split()
    print('ratwood revision:', ' '.join(SOURCE_REVISION))


def offline_source():
    # --offline: the Ratwood cache is used as it stands and no git runs in it; the revision for the report is the one the
    # last synced run wrote into PORTED_CONTENT.md.
    if not os.path.isdir(CHECKOUT) or not any(f.endswith('.dme') for f in os.listdir(CHECKOUT)):
        raise SystemExit(f'--offline needs the Ratwood cache at {CHECKOUT}; run the porter once without --offline')
    if os.path.exists(REPORT):
        found = re.search(r'^Ratwood revision: `([0-9a-f]+)` \(([^)]+)\)\.', open(REPORT, encoding='utf-8').read(), re.M)
        if found:
            SOURCE_REVISION[:] = [found.group(1), found.group(2)]
    print('offline: the Ratwood cache is used as it is, revision', ' '.join(SOURCE_REVISION) or 'unknown')


def main():
    if not os.path.exists(CONFIG):
        raise SystemExit('run from the repository root')
    cfg = json.load(open(CONFIG, encoding='utf-8'))
    code_root = CHECKOUT
    if OFFLINE:
        offline_source()
    else:
        sync_source(cfg['source'])
    port = cfg['port']
    rules = cfg['replacements']
    print('parsing', code_root)
    types, _ = parse_codebase(code_root)
    rw = Codebase(types)
    print('ratwood types:', len(types))
    declared = declared_paths(DECLARATION_ROOTS, [OUT_DIR])
    tg_declared = declared_paths(['code'], [])
    tg_names = tg_defines('code')
    maps = source_maps(cfg, rw)
    usage, per_level = map_usage(os.path.join(CHECKOUT, maps[0]))
    station_usage = collections.Counter(usage)
    for extra in maps[1:]:
        usage.update(map_usage(os.path.join(CHECKOUT, extra))[0])
    print('maps:', ', '.join(maps))

    if '--inventory' in sys.argv:
        for z in sorted(per_level):
            c = per_level[z]
            areas = collections.Counter()
            for p, n in c.items():
                if p.startswith('/area/'):
                    areas['/'.join(p.split('/')[:4])] += n
            print(f'z{z}:', ', '.join(f'{a} {n}' for a, n in areas.most_common(4)))
        for kind in ('/area', '/turf', '/obj', '/mob'):
            todo = collections.Counter()
            for p, n in usage.items():
                if p.split('/')[1] != kind[1:]:
                    continue
                rule = replacement_for(p, rules)
                if rule or p in declared:
                    continue
                todo[p] = n
            print(f'{kind}: {len(todo)} unported, unreplaced types, {sum(todo.values())} uses')
        return

    jobs = select_jobs(cfg, rw)
    role_outfits = {job: role_outfit(rw, job) for job in jobs}
    class_jobs = collections.defaultdict(list)
    for job in jobs:
        if len(role_outfits[job]['subclasses']) > 1:
            for advclass in role_outfits[job]['subclasses']:
                class_jobs[advclass].append(job)
    migrants = select_migrants(cfg, rw)
    for info in migrants['roles'].values():
        for advclass in info['classes']:
            if cfg['port']['migrants']['job'] not in class_jobs[advclass]:
                class_jobs[advclass].append(cfg['port']['migrants']['job'])
    class_outfits = {advclass: outfit_slots(rw, rw.resolve(advclass, 'outfit')) for advclass in class_jobs}
    outfit_items = set()
    migrant_outfits = [info['outfit'] for info in migrants['roles'].values() if info['outfit']]
    for dressed in list(role_outfits.values()) + list(class_outfits.values()) + migrant_outfits:
        outfit_items |= set(dressed['slots'].values())
        outfit_items |= {item for item, _ in dressed['contents'] or []}
    mapgen = mapgen_spec(rw, usage)
    mapgen_types = {path for gen in mapgen.values() for module in gen['modules'] for key in ('spawnableAtoms', 'spawnableTurfs') for path, _ in module[key]}
    fill_items = set(cfg['port'].get('extra_types', []))
    for path in set(usage) | mapgen_types:
        if path.startswith('/obj/structure'):
            fill_items |= set(random_pick(rw, path))
    for path in usage:
        if path.startswith('/mob/living'):
            # What the beasts eat comes along, so they find it on the map (Ratwood food_type).
            fill_items |= set(ITEM_PATH.findall(rw.resolve(path, 'food_type') or ''))
        if (replacement_for(path, rules) or {}).get('port', {}).get('fill'):
            contents, loot, _ = closet_fill(rw, path)
            fill_items |= set(contents) | {item for item, _ in loot}
    npcs = npc_candidates(rw, rules, usage)
    npc_items = npc_outfit_items(rw, rules, npcs)
    fill_items |= anvil_recipe_items(cfg, rw, rules)
    fill_items |= craft_recipe_items(cfg, rw, rules)
    fill_items |= artificer_recipe_items(cfg, rw, rules)
    fill_items |= pottery_recipe_items(cfg, rw, rules)
    fill_items |= food_chain_items(cfg, rw, set(usage) | outfit_items | mapgen_types | fill_items | npc_items)
    fill_items |= husbandry_types(cfg, rw, set(usage) | fill_items)
    fill_items |= alchemy_types(cfg, rw)
    generated = generate(cfg, port, rules, rw, declared, tg_declared, tg_names, usage, outfit_items | mapgen_types | fill_items | npc_items, set(jobs))
    generate_mapgen(mapgen, rules, declared | generated, tg_names)
    generate_anvil_recipes(cfg, rw, rules, declared | generated)
    generate_craft_recipes(cfg, rw, rules, declared | generated)
    generate_artificer_recipes(cfg, rw, rules, declared | generated)
    generate_pottery_recipes(cfg, rw, rules, declared | generated)
    generate_trade(cfg, rw, rules, declared | generated)
    generate_food(cfg, rw, generated, tg_declared, tg_names, declared)
    generate_husbandry(cfg, rw, generated, tg_declared)
    generate_alchemy(cfg, rw, declared | generated, generated)
    npcs = [p for p in npcs if p in generated]
    role_traits = npc_trait_names(rw, npcs, cfg['attributes'])
    for species in cfg['port']['bodies']['species_map']:
        role_traits |= set(re.findall(r'TRAIT_[A-Z0-9_]+', rw.resolve(species, 'inherent_traits') or ''))
    for job in jobs:
        dressed = role_outfits.get(job, {})
        role_traits |= set(role_attributes(rw, job, dressed.get('advclass'), dressed.get('source'), cfg['attributes'])['traits'])
    for advclass, owners in class_jobs.items():
        role_traits |= set(role_attributes(rw, owners[0], advclass, class_outfits[advclass]['source'], cfg['attributes'])['traits'])
    known_traits = generate_traits(cfg, tg_names, role_traits)
    generate_skills(cfg, rw)
    role_attrs = generate_attribute_sheets(cfg, rw, jobs, role_outfits, known_traits)
    role_outfit_paths = generate_jobs(cfg, rw, usage, role_outfits, declared | generated, station_usage, role_attrs)
    generate_advclasses(cfg, rw, class_jobs, class_outfits, declared | generated, known_traits)
    generate_migrants(cfg, rw, migrants, declared | generated)
    hair_names = generate_bodies(cfg, rw, declared | generated, npcs, known_traits)
    generate_races(cfg, rw)
    generate_npcs(cfg, rw, rules, npcs, declared | generated, known_traits, role_outfit_paths, hair_names)


MAPGEN_LANDMARK = '/obj/effect/landmark/mapGenerator'
MAPGEN_WEIGHTED = ('spawnableAtoms', 'spawnableTurfs')
MAPGEN_PATHS = ('allowed_turfs', 'excluded_turfs', 'allowed_areas')
MAPGEN_SCALARS = ('clusterCheckFlags', 'clusterMin', 'clusterMax', 'include_subtypes')


def list_paths(raw):
    return [(p, w) for p, w in re.findall(r'(/[A-Za-z0-9_/]+)\s*(?:=\s*(-?[\d.]+))?', raw or '')]


def mapgen_spec(rw, usage):
    spec = {}
    for landmark in sorted(p for p in usage if p.startswith(MAPGEN_LANDMARK + '/')):
        generator = (rw.resolve(landmark, 'mapGeneratorType') or '').strip()
        if not generator.startswith('/datum/'):
            continue
        modules = []
        for module, _ in list_paths(rw.resolve(generator, 'modules')):
            data = {'path': module}
            for key in MAPGEN_WEIGHTED:
                data[key] = list_paths(rw.resolve(module, key))
            for key in MAPGEN_PATHS:
                data[key] = [p for p, _ in list_paths(rw.resolve(module, key))]
            for key in MAPGEN_SCALARS:
                data[key] = rw.resolve(module, key)
            modules.append(data)
        spec[landmark] = {'generator': generator, 'modules': modules}
    return spec


def generate_mapgen(spec, rules, valid, tg_names):
    implicit = {v.rsplit('/', k)[0] for v in valid for k in range(1, v.count('/'))}

    def kept(path, atoms):
        rule = replacement_for(path, rules)
        if rule and (atoms and not rule.get('rebase')):
            return None
        target = runtime_path(path, rules)
        return target if target in valid or (not atoms and target in implicit) else None

    blocks = []
    emitted = set()
    for landmark, gen in spec.items():
        name = gen['generator'].rsplit('/', 1)[1]
        generator = f'/datum/map_generator/rockhill/{name}'
        blocks.append([landmark, f'\tmapGeneratorType = {generator}'])
        if generator in emitted:
            continue
        emitted.add(generator)
        module_paths = []
        for module in gen['modules']:
            path = f"/datum/map_generator_module/rockhill/{module['path'].rsplit('/', 1)[1]}"
            block = [path]
            for key in MAPGEN_WEIGHTED:
                entries = {}
                for p, w in module[key]:
                    target = kept(p, key == 'spawnableAtoms')
                    if target:
                        entries[target] = w or '1'
                entries = list(entries.items())
                if entries:
                    block.append(f'\t{key} = list(' + ', '.join(f'{p} = {w}' for p, w in entries) + ')')
            skip = False
            for key in MAPGEN_PATHS:
                if not module[key]:
                    continue
                entries = sorted({kept(p, False) for p in module[key]} - {None})
                if not entries:
                    skip = key != 'excluded_turfs'
                    continue
                block.append(f'\t{key} = list(' + ', '.join(entries) + ')')
            for key in MAPGEN_SCALARS:
                value = literal(module[key], tg_names)
                if value is not None:
                    block.append(f'\t{key} = {value}')
            if skip:
                continue
            module_paths.append(path)
            if path not in emitted:
                emitted.add(path)
                blocks.append(block)
        blocks.append([generator, '\tmodules = list(' + ', '.join(module_paths) + ')'])
    open(f'{OUT_DIR}/mapgen.dm', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f'mapgen.dm: {len(spec)} landmarks, {len(emitted)} generator and module types')


def parse_look_line(text, look):
    if 'dir' not in look and re.fullmatch(r'dir\s*=\s*pick\(\s*(?:GLOB\.cardinals|NORTH\s*,\s*SOUTH\s*,\s*(?:EAST\s*,\s*WEST|WEST\s*,\s*EAST))\s*\)', text):
        look['dir'] = True
        return
    m = re.fullmatch(r'icon_state\s*=\s*(.+)', text)
    if not m or 'icon' in look:
        return
    value = m.group(1).strip()
    if re.fullmatch(r'[A-Za-z_]\w*', value):
        look['icon'] = ('var', value)
        return
    lit = re.fullmatch(r'"([^"\[\]]*)"', value)
    if lit:
        look['icon'] = ('state', lit.group(1))
        return
    var = re.fullmatch(r'"(\[(?:initial\()?icon_state\)?\])?([^"\[\]]*)\[(rand|pick)\(([\d\s,]+)\)\]([^"\[\]]*)"', value)
    if not var:
        return
    numbers = sorted(int(n) for n in var.group(4).split(',') if n.strip())
    if var.group(3) == 'rand':
        low, high = numbers[0], numbers[-1]
    elif numbers == list(range(numbers[0], numbers[-1] + 1)):
        low, high = numbers[0], numbers[-1]
    else:
        return
    look['icon'] = ('variant', (bool(var.group(1)), var.group(2), var.group(5), low, high))


def parse_look(body):
    look = {}
    guard = False
    for line in body:
        text = line.strip()
        if not text or text.startswith('//'):
            continue
        indent = len(line) - len(line.lstrip('\t'))
        if indent == 1:
            guard = re.fullmatch(r'if\s*\(\s*icon_state\s*==\s*(?:"[^"]*"|initial\(icon_state\))\s*\)', text) is not None
            if not guard:
                parse_look_line(text, look)
        elif indent == 2 and guard:
            parse_look_line(text, look)
    return look


def runtime_look(rw, path):
    look = {}
    seen = set()
    p = path
    while p and p not in seen:
        seen.add(p)
        if p in INIT_BODIES:
            for aspect, value in parse_look(INIT_BODIES[p]).items():
                look.setdefault(aspect, value)
        p = rw.parent(p)
    if look.get('icon', (None,))[0] == 'var':
        value = (rw.resolve(path, look['icon'][1]) or '').strip()
        if re.fullmatch(r'"[^"\[\]]*"', value):
            look['icon'] = ('state', value.strip('"'))
        else:
            del look['icon']
    return look


def init_overlay(rw, path):
    p = path
    seen = set()
    while p and p not in seen:
        seen.add(p)
        body = '\n'.join(INIT_BODIES.get(p, []))
        if body:
            found = re.search(r'mutable_appearance\(\s*icon\s*,\s*"([^"\[\]]+)"', body)
            if found and 'add_overlay(' in body:
                return found.group(1)
        p = rw.parent(p)
    return None


def parse_onmob(body):
    text = '\n'.join(body)
    found = {}
    for tag in ONMOB_TAGS:
        label = re.search(r'if\(([^)]*"' + tag + r'"[^)]*)\)', text)
        if not label:
            continue
        ret = re.compile(r'return\b\s*(list\(|null\b)?').search(text, label.end())
        if not ret:
            continue
        if ret.group(1) != 'list(':
            found[tag] = 'null'
            continue
        depth = 1
        k = ret.end()
        while k < len(text) and depth:
            depth += {'(': 1, ')': -1}.get(text[k], 0)
            k += 1
        inner = text[ret.end():k - 1]
        pairs = [p.strip() for p in inner.split(',') if p.strip()]
        if pairs and all(re.fullmatch(r'"\w+"\s*=\s*-?\d+(?:\.\d+)?', p) for p in pairs):
            found[tag] = 'list(' + ', '.join(re.sub(r'\s*=\s*', ' = ', p) for p in pairs) + ')'
    return found


def onmob_numbers(raw):
    """A getonmobprop list literal as {key: number}."""
    return {key: float(value) if '.' in value else int(value) for key, value in re.findall(r'"(\w+)"\s*=\s*(-?\d+(?:\.\d+)?)', raw or '')}


def onmob_prop(rw, path, tag):
    """The getonmobprop table an item answers for a tag ("gen", "wielded", "onbelt", "onback"), walking its
    parents as Ratwood's `return ..()` does; None when a type stops the walk without one."""
    p = path
    while p and p.startswith('/obj/item'):
        body = ONMOB.get(p)
        if body is not None:
            found = parse_onmob(body)
            if tag in found:
                return None if found[tag] == 'null' else onmob_numbers(found[tag])
            if not any('..()' in line for line in body):
                return None
        p = rw.parent(p)
    return None


def onmob_parts(prop, behind):
    """Whether the table draws anything in front of the body (above = 1) or behind it (above = 0)."""
    return any(prop.get(key) == (0 if behind else 1) for key in ABOVE_KEYS)


def bake_name(group, base, signature):
    """A state name in a baked sheet group: the sprite's own state, or "<state>~<n>" when another item with the
    same sprite holds it differently."""
    name = base
    n = 1
    while BAKE_NAMES.get((group, name), signature) != signature:
        n += 1
        name = f'{base}~{n}'
    BAKE_NAMES[(group, name)] = signature
    return name


def bake_jobs(out, name, icon, state, prop, mirrored):
    """Queues the front and behind states a table draws; returns how many it queued (none when no side is drawn)."""
    queued = 0
    for behind in (False, True):
        if onmob_parts(prop, behind):
            job_name = f'{name}_behind' if behind else name
            BAKE_JOBS[out][job_name] = {'name': job_name, 'icon': icon, 'state': state, 'prop': prop, 'mirrored': mirrored, 'behind': behind}
            queued += 1
    return queued


def write_bake_manifest(spec):
    sheets = [{'out': out, 'states': [jobs[name] for name in sorted(jobs)]} for out, jobs in sorted(BAKE_JOBS.items())]
    manifest = {'mask32': spec['mask32'], 'mask64': spec['mask64'], 'canvas': 64, 'sheets': sheets}
    with open(spec['manifest'], 'w', encoding='utf-8', newline='\n') as handle:
        json.dump(manifest, handle, indent='\t', sort_keys=True)
        handle.write('\n')
    print(f"{spec['manifest']}: {len(sheets)} sheets, {sum(len(s['states']) for s in sheets)} states to bake")


TYPED_NEW = re.compile(r'\bvar(/obj/item/[A-Za-z0-9_/]*[A-Za-z0-9_])/[A-Za-z_][A-Za-z0-9_]*\s*=\s*new\b')


def typed_fill(path):
    """What an item creates in its own Initialize() to fill itself: Ratwood's quivers loop
    "var/obj/item/ammo_casing/caseless/rogue/arrow/iron/A = new()" up to max_storage."""
    found = TYPED_NEW.search('\n'.join(INIT_BODIES.get(path, [])))
    return found.group(1) if found else None


def graft_point(path, declared):
    parts = path.split('/')
    for k in range(3, len(parts) + 1):
        candidate = '/'.join(parts[:k])
        if candidate not in declared:
            return candidate
    return None


def category_for(path, categories):
    best = None
    for cat in categories:
        for prefix in cat['prefixes']:
            if boundary_match(path, prefix) and (best is None or len(prefix) > best[1]):
                best = (cat, len(prefix))
    return best[0] if best else None


def generate(cfg, port, rules, rw, declared, tg_declared, tg_names, usage, extra_items, jobs=frozenset()):
    categories = port['categories']
    tg_values = tg_define_values(TG_LAYERS)
    outdoor_areas = []
    chosen = collections.defaultdict(list)
    skipped = collections.Counter()
    port_usage = collections.Counter(usage)
    for spawner in [p for p in usage if p.startswith('/obj/effect/spawner/')]:
        for item, _ in loot_entries(rw.resolve(spawner, 'loot')):
            port_usage[item] += 0
    for item in extra_items:
        port_usage[item] += 0
    for path in list(port_usage):
        for name in port.get('linked_types', []):
            for item, _ in list_paths(rw.resolve(path, name)):
                port_usage[item.rstrip('/')] += 0
    # Links that only one branch has: what an arrow shoots (projectile_type), what a raw clay piece fires into
    # (cooked_type: without its port the piece would inherit plain clay's and fire into a stone).
    for prefix, names in port.get('linked_types_by_prefix', {}).items():
        for path in [p for p in port_usage if boundary_match(p, prefix)]:
            for name in names:
                for item, _ in list_paths(rw.resolve(path, name)):
                    port_usage[item.rstrip('/')] += 0
    # What a quiver fills itself with in its Initialize() comes along with the quiver.
    for prefix in port.get('typed_fills', {}):
        for path in [p for p in port_usage if boundary_match(p, prefix)]:
            fill = typed_fill(path)
            if fill:
                port_usage[fill] += 0
    for path, count in sorted(port_usage.items()):
        if replacement_for(path, rules) or path in tg_declared:
            continue
        cat = category_for(path, categories)
        if cat is None:
            # A type the module writes by hand (rockhill/map_helpers.dm and the like) stays on the map without a port.
            if path not in declared:
                skipped[path] = count
            continue
        chosen[cat['file']].append(path)

    icons = {}

    def icon_ref(raw):
        m = ICON_LITERAL.match(raw.strip())
        if not m:
            return None
        rel = exact_case(CHECKOUT, m.group(1))
        src = os.path.join(CHECKOUT, rel)
        if not os.path.exists(src) or not asset_allowed(rel):
            return None
        dest_rel = rel[len('icons/'):] if rel.startswith('icons/') else rel
        dest = f'{ICON_DIR}/{dest_rel}'
        icons[src] = dest
        return f"'{dest}'"

    sheet_states = {}

    def sheet_states_of(ref):
        rel = ref.strip("'")
        src = next((source for source, dest in icons.items() if dest == rel), rel)
        if src not in sheet_states:
            sheet_states[src] = dmi.state_names(src) if os.path.exists(src) else set()
        return sheet_states[src]

    runtime_sounds = {}

    sounds = {}

    def sound_ref(raw):
        rel = exact_case(CHECKOUT, ICON_LITERAL.match(raw.strip()).group(1))
        src = os.path.join(CHECKOUT, rel)
        if not os.path.exists(src) or not asset_allowed(rel):
            return None
        sounds[src] = f"{SOUND_DIR}/{rel[len('sound/'):] if rel.startswith('sound/') else rel}"
        return f"'{sounds[src]}'"

    def runtime_sound(rel, root):
        dest = f"{root}/{rel[len('sound/'):] if rel.startswith('sound/') else rel}"
        runtime_sounds[os.path.join(CHECKOUT, rel)] = dest
        return dest

    grid_spec = port.get('grid_storage', {})
    grid_used = set()

    def grid_type(component):
        component = (component or '').strip()
        if not grid_spec or not boundary_match(component, grid_spec['from']):
            return None
        grid_used.add(component)
        return grid_spec['to'] + component[len(grid_spec['from']):]

    def added_storage(path):
        p = path
        while p:
            body = INIT_BODIES.get(p)
            if body is not None:
                found = re.search(r'AddComponent\((/datum/component/storage[A-Za-z0-9_/]*)', '\n'.join(body))
                if found:
                    return found.group(1)
                if not any('..()' in line for line in body):
                    return None
            p = rw.parent(p)
        return None

    def grid_storage_lines(path):
        lines = []
        if boundary_match(path, '/obj/item/storage'):
            target = grid_type(rw.resolve(path, 'component_type'))
            if target:
                lines.append(f'\tstorage_type = {target}')
        target = grid_type(added_storage(path))
        if target:
            lines.append(f'\trogue_storage_type = {target}')
        return lines

    def fix_sprites(path, block):
        values = {}
        for line in block[1:]:
            name, sep, value = line.strip().partition(' = ')
            if sep:
                values[name] = value

        def text(name):
            value = values.get(name, '')
            return value[1:-1] if len(value) > 1 and value[0] == '"' and value[-1] == '"' else None

        def put(name, value):
            block[:] = [line for line in block if not line.startswith(f'\t{name} = ')]
            block.append(f'\t{name} = {value}')

        if any(path in users for users in EXCLUDED.values()):
            NO_SPRITE.append((path, 'excluded folder', text('icon_state') or ''))
            put('icon_state', 'null')
            put('inhand_icon_state', 'null')
            put('worn_icon', f"'{BLANK_WORN}'")
            put('worn_icon_state', 'null')
            BLANK_USERS.add(path)
            return
        world = values.get('icon')
        state = text('icon_state')
        if world and ICON_LITERAL.match(world) and state is not None and state not in sheet_states_of(world):
            NO_SPRITE.append((path, world.strip("'"), state))
            put('icon_state', 'null')

        hands = [values.get(name) for name in ('lefthand_file', 'righthand_file')]
        if any(ICON_LITERAL.match(sheet or '') for sheet in hands):
            held = text('inhand_icon_state')
            fits = held is not None and all(ICON_LITERAL.match(sheet or '') and held in sheet_states_of(sheet) for sheet in hands)
            put('inhand_icon_state', f'"{held}"' if fits else 'null')

        flags = values.get('slot_flags', '')
        wearable = bool(flags) or boundary_match(path, '/obj/item/clothing')
        pockets = ('ITEM_SLOT_POCKETS', 'ITEM_SLOT_LPOCKET', 'ITEM_SLOT_RPOCKET')
        carried = pockets + ('ITEM_SLOT_BACK', 'ITEM_SLOT_BELT')
        if not wearable or (any(pocket in flags for pocket in pockets) and all(slot in carried for slot in re.findall(r'ITEM_SLOT_[A-Z_]+', flags))):
            return
        sheet = values.get('worn_icon')
        sheet_states_here = sheet_states_of(sheet) if sheet and ICON_LITERAL.match(sheet) else set()
        look = next((state for state in (text('icon_state'), text('worn_icon_state')) if state and state in sheet_states_here), None)
        if look:
            put('worn_icon_state', f'"{look}"')
            ratwood_slots = set(re.findall(r'ITEM_SLOT_[A-Z_]+', rw.resolve(path, 'slot_flags') or ''))
            if look + FEMALE_WORN_SUFFIX in sheet_states_of(sheet) and ratwood_slots & set(port.get('female_worn_slots', [])):
                put('rogue_female_worn', 'TRUE')
                FEMALE_USERS.add(path)
            return
        if sheet or any(slot in flags for slot in TG_WORN_SLOTS) or boundary_match(path, '/obj/item/clothing'):
            BLANK_USERS.add(path)
            put('worn_icon', f"'{BLANK_WORN}'")
            put('worn_icon_state', 'null')

    def bake_onmob(path, block, spec):
        """Held, belted and slung sprites of Ratwood's experimental_* items as jobs for ai-skills
        bake_onmob_sheets.py: TG lefthand/righthand sheets (inhand_icon_state = the sprite's state, "_wielded" and
        the alternate grips' suffixes beside it) and one sheet of back/hip states, "_behind" for the parts under
        the body. The item then draws with TG's own inhand code and no icon() at runtime."""
        values = {}
        for line in block[1:]:
            name, sep, value = line.strip().partition(' = ')
            if sep:
                values[name] = value

        def put(name, value):
            block[:] = [line for line in block if not line.startswith(f'\t{name} = ')]
            block.append(f'\t{name} = {value}')

        icon = (values.get('icon') or '').strip("'")
        state = (values.get('icon_state') or '').strip('"')
        if not icon.startswith(ICON_DIR + '/') or not state or state == 'null':
            return
        states = sheet_states_of(f"'{icon}'")
        sheets = f"{spec['dir']}/{icon[len(ICON_DIR) + 1:-len('.dmi')]}"
        flag = lambda name: (rw.resolve(path, name) or '').strip() in ('TRUE', '1')
        if flag('experimental_inhand') and onmob_prop(rw, path, 'gen'):
            hands = {'': onmob_prop(rw, path, 'gen')}
            wielded = onmob_prop(rw, path, 'wielded')
            if wielded:
                hands['_wielded'] = wielded
            for grip in alt_grip_paths(rw, rw.resolve(path, 'alt_grips')):
                prop = re.search(r'"altgrip"\s*=\s*list\((.*?)\)', rw.resolve(grip, 'onmobprop_overrides') or '', re.S)
                if prop and onmob_numbers(prop.group(1)):
                    hands['_' + grip.rsplit('/', 1)[1]] = onmob_numbers(prop.group(1))
            name = bake_name((icon, 'hands'), state, json.dumps(hands, sort_keys=True))
            queued = 0
            sprites = [(name, state)]
            if name == state:
                sprites += [(state + suffix, state + suffix) for suffix in spec.get('variants', []) if state + suffix in states]
                sprites += [(state.replace(old, new), state.replace(old, new)) for old, new in spec.get('swaps', []) if old in state and state.replace(old, new) in states]
            for baked, sprite in sprites:
                if baked != name and bake_name((icon, 'hands'), baked, json.dumps(hands, sort_keys=True)) != baked:
                    continue
                for suffix, prop in hands.items():
                    queued += bake_jobs(f'{sheets}_righthand.dmi', baked + suffix, icon, sprite, prop, False)
                    queued += bake_jobs(f'{sheets}_lefthand.dmi', baked + suffix, icon, sprite, prop, True)
            if queued:
                put('lefthand_file', f"'{sheets}_lefthand.dmi'")
                put('righthand_file', f"'{sheets}_righthand.dmi'")
                put('inhand_icon_state', 'null' if name == state else f'"{name}"')
                put('inhand_x_dimension', '64')
                put('inhand_y_dimension', '64')
                put('rogue_baked_inhand', 'TRUE')
        worn = {}
        if flag('experimental_onback') and onmob_prop(rw, path, 'onback'):
            worn['back'] = onmob_prop(rw, path, 'onback')
        if flag('experimental_onhip') and onmob_prop(rw, path, 'onbelt'):
            worn['hip'] = onmob_prop(rw, path, 'onbelt')
        if worn:
            name = bake_name((icon, 'worn'), state, json.dumps(worn, sort_keys=True))
            out = f'{sheets}_onmob.dmi'
            queued = 0
            if 'back' in worn:
                queued += bake_jobs(out, f'back_{name}', icon, state, worn['back'], True)
                queued += bake_jobs(out, f'backr_{name}', icon, state, worn['back'], False)
            if 'hip' in worn:
                queued += bake_jobs(out, f'hipl_{name}', icon, state, worn['hip'], True)
                queued += bake_jobs(out, f'hipr_{name}', icon, state, worn['hip'], False)
            if queued:
                put('rogue_onmob_sheet', f"'{out}'")
                if name != state:
                    put('rogue_onmob_state', f'"{name}"')

    def slot_worn_icon(path, sheets):
        """The slot's default sheet of Ratwood's update_inv_* when it holds the worn state; Ratwood draws worn
        sprites by icon_state (item_state is for hands), so that is tried first."""
        flags = rw.resolve(path, 'slot_flags') or ''
        states = [v.strip().strip('"') for v in (rw.resolve(path, 'icon_state'), rw.resolve(path, 'item_state')) if v and v.strip() != 'null']
        for flag, sheet in sheets.items():
            if flag not in re.findall(r'ITEM_SLOT_[A-Z_]+', flags):
                continue
            src = os.path.join(CHECKOUT, sheet)
            if src not in sheet_states:
                sheet_states[src] = {s['name'] for s in dmi.read(src).states} if os.path.exists(src) else set()
            if any(state in sheet_states[src] for state in states):
                return f"'{sheet}'"
        return None

    generated = {p for paths in chosen.values() for p in paths}
    grip_paths = {g for paths in chosen.values() for p in paths if p.startswith('/obj/item') for g in alt_grip_paths(rw, rw.resolve(p, 'alt_grips'))}
    generated |= grip_paths
    used_turfs = sorted(p for p in usage if p.startswith('/turf/'))
    runtime = {p: runtime_path(p, rules) for p in used_turfs}
    reskins = [p for p in used_turfs if (replacement_for(p, rules) or {}).get('reskin')]
    valid = declared | generated | {runtime[p] for p in reskins}
    valid |= {'/'.join(p.split('/')[:k]) for p in generated for k in range(3, p.count('/') + 1)}
    valid |= {runtime_path(p, rules) for p in usage if (replacement_for(p, rules) or {}).get('rebase') and replacement_for(p, rules).get('port')}
    sheets = {}
    used_objs = sorted(p for p in usage if p.startswith('/obj/'))
    smooth_candidates = set(used_turfs) | set(used_objs)
    smoothing_paths = {p for cat in categories if cat.get('smoothing') for p in chosen.get(cat['file'], [])} | set(reskins)
    placed_paths = {p for cat in categories if cat.get('placement') for p in chosen.get(cat['file'], [])}
    if os.path.isdir(SMOOTH_DIR):
        shutil.rmtree(SMOOTH_DIR)

    def convert_sheet(raw_icon, preview):
        m = ICON_LITERAL.match((raw_icon or '').strip())
        if not m:
            return None
        src = os.path.join(CHECKOUT, m.group(1))
        if not os.path.exists(src):
            return None
        if src not in sheets:
            sheet = dmi.read(src)
            if sheet.frame_width != 32 or sheet.frame_height != 32 or not dmi.has_corners(sheet):
                sheets[src] = None
            else:
                prefix = os.path.splitext(os.path.basename(src))[0]
                os.makedirs(SMOOTH_DIR, exist_ok=True)
                dmi.write(f'{SMOOTH_DIR}/{prefix}.dmi', 32, 32, dmi.corners_to_bitmask(sheet, prefix, preview))
                sheets[src] = prefix
        return sheets[src]

    state_edits = sorted(set().union(*(turf_state_edits(os.path.join(CHECKOUT, source)) for source in source_maps(cfg))))
    bitmask = {}
    for path in sorted(smoothing_paths):
        if not smooth_rule(rw, path):
            continue
        raw = rw.resolve(path, 'smooth_icon')
        if not raw or raw.strip() == 'null':
            raw = rw.resolve(path, 'icon')
        prefix = convert_sheet(raw, (rw.resolve(path, 'icon_state') or '').strip().strip('"'))
        if prefix:
            bitmask[path] = prefix
    BITMASK_TURFS.update(bitmask)
    state_variants = collections.defaultdict(set)
    for path, state in state_edits:
        target = runtime_path(path, rules)
        if (target in valid or target in generated) and path not in bitmask and not (replacement_for(path, rules) or {}).get('reskin') and runtime_look(rw, path).get('icon', (None, None))[0] != 'state':
            state_variants[path].add(f'{target}/{state_leaf(state)}')

    def matched_runtimes(path):
        found = set()
        for q in smooth_matches(path, smooth_rule(rw, path), smooth_candidates):
            target = runtime_path(q, rules)
            if target and target in valid:
                found.add(target)
        return found

    friends = {path: matched_runtimes(path) for path in bitmask}
    owners = {runtime_path(p, rules) for p in bitmask} | {t for found in friends.values() for t in found}
    group_numbers = {o: TURF_GROUP_BASE + i for i, o in enumerate(sorted(o for o in owners if o.startswith('/turf/')))}
    group_numbers.update({o: -(OBJ_GROUP_BASE + i) for i, o in enumerate(sorted(o for o in owners if not o.startswith('/turf/')))})
    group_defines = {o: group_define(o) for o in owners}
    if len(set(group_defines.values())) != len(group_defines):
        raise SystemExit('two smoothing owners map to the same group define')
    grouped = set()

    def group_list(targets):
        return ' + '.join(group_defines[t] for t in sorted(targets, key=lambda t: group_numbers[t]))

    def group_lines(target):
        if target not in group_defines:
            return []
        grouped.add(target)
        return [f'\tsmoothing_groups = {group_defines[target]}']

    def smooth_targets(path):
        rule = smooth_rule(rw, path)
        if not rule:
            return []
        found = set()
        for q in smooth_matches(path, rule, set(used_turfs)):
            if runtime[q] in valid:
                found.add(runtime[q])
                found |= state_variants.get(q, set())
        return sorted(found)

    def smoothing_lines(path):
        prefix = bitmask.get(path)
        if not prefix:
            return None
        rule = smooth_rule(rw, path)
        lines = [
            f"\ticon = '{SMOOTH_DIR}/{prefix}.dmi'",
            f'\ticon_state = "{prefix}-0"',
            f'\tbase_icon_state = "{prefix}"',
        ]
        if friends[path]:
            flags = 'SMOOTH_BITMASK' if rule['diagonal'] else 'SMOOTH_BITMASK_CARDINALS'
            if rule['border']:
                flags += ' | SMOOTH_BORDER'
            lines += [f'\tsmoothing_flags = {flags}', f'\tcanSmoothWith = {group_list(friends[path])}']
        else:
            lines += ['\tsmoothing_flags = NONE', '\tcanSmoothWith = null']
        own = runtime_path(path, rules)
        return lines + (group_lines(own) or ['\tsmoothing_groups = null'])

    def edge_receiver(path):
        p = path
        while p and p.startswith('/turf/open'):
            if 'cardinal_smooth' in PROCS.get(p, ()):
                return 'SMOOTH_FALSE' not in (rw.resolve(path, 'smooth') or 'SMOOTH_FALSE') and bool(smooth_targets(path))
            p = rw.parent(p)
        return False

    edge_states = {}
    edge_overrides = {}
    edge_sources = {}
    for path in used_turfs:
        target = runtime[path]
        if not target or target not in valid:
            continue
        state = string_value(rw.resolve(path, 'neighborlay'))
        if state and state != '""':
            edge_states[target] = state
        override = string_value(rw.resolve(path, 'neighborlay_override'))
        if override and override != '""':
            edge_overrides[target] = override

    inherited_values = {}

    def own_value(cat, path, name):
        """What the port makes of Ratwood's value of an inherited var (inherited_vars) on a type: a DM value, or None when it
        has none to give (an unported path, a value the maps do not know, a var the type does not have)."""
        if name in cat.get('clothing_only', []) and not path.startswith('/obj/item/clothing/'):
            return None
        raw = rw.resolve(path, cat.get('rename', {}).get(name, name))
        if raw is None:
            return None
        raw = raw.strip()
        if name in cat.get('coverage_vars', []):
            return exact_coverage_value(raw)
        if name in cat.get('mapped_vars', {}):
            return cat['mapped_vars'][name].get(raw.strip('()').strip())
        if name in cat.get('paths', []):
            if raw == 'null':
                return 'null'
            target = runtime_path(raw.rstrip('/'), rules) if raw.startswith('/') else None
            return target if target in valid else None
        return literal(raw, tg_names)

    def inherited_value(cat, path, name):
        """The value DM gives a ported type of an inherited var without a line of its own: that of the nearest ported type
        above it on its path (the port keeps Ratwood's paths), else the module's default of the var."""
        parent = path.rsplit('/', 1)[0]
        while parent.count('/') >= 2:
            if parent in generated:
                return effective_value(cat, parent, name)
            parent = parent.rsplit('/', 1)[0]
        return cat['inherited_vars'][name]

    def effective_value(cat, path, name):
        key = (path, name)
        if key not in inherited_values:
            value = own_value(cat, path, name)
            inherited_values[key] = value if value is not None else inherited_value(cat, path, name)
        return inherited_values[key]

    def inherited_lines(cat, path):
        """Vars whose Ratwood value a type states only where it differs from what it inherits in the port: written on
        every item they would be noise, and skipped where Ratwood sets the default back (a pauldron under a shirt, a
        null) the type would inherit its ported parent's value instead."""
        lines = []
        for name in cat.get('inherited_vars', {}):
            value = own_value(cat, path, name)
            if value is not None and value != inherited_value(cat, path, name):
                lines.append(f'\t{name} = {value}')
        return lines

    if os.path.isdir(OUT_DIR):
        shutil.rmtree(OUT_DIR)
    os.makedirs(OUT_DIR)
    report_rows = collections.defaultdict(list)
    smoothed = collections.Counter()
    for cat in categories:
        paths = chosen.get(cat['file'], [])
        if not paths:
            continue
        blocks = []
        grafted = set()
        for path in paths:
            g = graft_point(path, tg_declared)
            if g and any(boundary_match(g, n) or g.startswith(n + '/') for n in cat.get('natural', [])):
                continue
            if g and g not in grafted and cat.get('graft'):
                grafted.add(g)
                block = [g, f"\tparent_type = {cat.get('graft_overrides', {}).get(g, cat['graft'])}"]
                for name, value in cat.get('graft_vars', {}).items():
                    block.append(f'\t{name} = {value}')
                # A branch grafted onto a TG type of its own (graft_overrides) may need a TG var set to fit Ratwood: the
                # scroll is TG paper, but its sheet has no "<state>_words" for written paper.
                for name, value in cat.get('graft_override_vars', {}).get(g, {}).items():
                    block.append(f'\t{name} = {value}')
                if g not in paths:
                    blocks.append(block)
                else:
                    cat.setdefault('_graft_blocks', {})[g] = block[1:]
        if cat.get('sound_vars'):
            fetch_sources([f for p in paths for source_name in cat['sound_vars'].values() for f in sound_files(rw.resolve(p, source_name))])
        if cat.get('sound_lists'):
            fetch_sources([f for p in paths for name in cat['sound_lists'] for f in sound_files(rw.resolve(p, cat.get('rename', {}).get(name, name)))])
        # Sounds the module's own code plays (a tree falling): copied with the rest, no var names them.
        if cat.get('code_sounds'):
            fetch_sources(cat['code_sounds'])
            for rel in cat['code_sounds']:
                sound_ref(f"'{rel}'")
        # A var of limit_vars is written only for the types under its prefixes (the destruction of what grows, not of every
        # structure).
        limited = {}
        for prefix, names in cat.get('limit_vars', {}).items():
            for name in names:
                limited.setdefault(name, []).append(prefix)
        for path in paths:
            CURRENT[0] = path
            block = [path]
            block += cat.get('_graft_blocks', {}).get(path, [])
            smooth = smoothing_lines(path) if cat.get('smoothing') else None
            for name in cat['vars']:
                if smooth and name in ('icon', 'icon_state'):
                    continue
                if name in limited and not any(boundary_match(path, prefix) for prefix in limited[name]):
                    continue
                if name == 'layer' and cat.get('placement'):
                    continue
                source_name = cat.get('rename', {}).get(name, name)
                value = rw.resolve(path, source_name)
                if name in cat.get('skip_default', []) and (value or 'null').strip() in ('null', '0', 'FALSE', '""'):
                    continue
                if name in cat.get('mapped_vars', {}):
                    mapped = cat['mapped_vars'][name].get((value or '').strip().strip('()').strip())
                    if mapped:
                        block.append(f'\t{name} = {mapped}')
                    continue
                if name in cat.get('clothing_only', []) and not path.startswith('/obj/item/clothing/'):
                    continue
                if name in cat.get('numeric_vars', []):
                    number = define_value_number(value)
                    if number is not None and not (number == 0 and name in cat.get('skip_default', [])) and number != cat.get('numeric_defaults', {}).get(name):
                        block.append(f'\t{name} = {number}')
                    continue
                if name in cat.get('sounds', []):
                    # One sound file (a projectile's hitsound), copied like the rest of the sounds.
                    ref = sound_ref(value) if value and ICON_LITERAL.match(value.strip()) else None
                    if ref:
                        block.append(f'\t{name} = {ref}')
                    continue
                if name in cat.get('grip_lists', []):
                    entries = [p for p in alt_grip_paths(rw, value) if p in valid]
                    if entries:
                        block.append(f'\t{name} = list(' + ', '.join(entries) + ')')
                    elif (value or '').strip() == 'null' and alt_grip_paths(rw, rw.resolve(rw.parent(path), name)):
                        block.append(f'\t{name} = null')
                    continue
                if name in cat.get('intent_lists', []):
                    entries = intent_paths(rw, value)
                    if entries and tuple(entries) != DEFAULT_INTENTS:
                        USED_INTENTS.update(entries)
                        block.append(f'\t{name} = list(' + ', '.join(entries) + ')')
                    continue
                if name in cat.get('skill_vars', []):
                    target = skill_target(cfg, value)
                    if target:
                        block.append(f'\t{name} = {target}')
                    continue
                if name in cat.get('stat_lists', {}):
                    stat_map = cat['stat_lists'][name]
                    entries = []
                    for source_var, stat in stat_map['stats'].items():
                        number = define_value_number(rw.resolve(path, source_var))
                        if number is not None and number != stat_map['default']:
                            entries.append(f'{stat} = {number}')
                    if entries:
                        block.append(f'\t{name} = list(' + ', '.join(entries) + ')')
                    continue
                if name in cat.get('string_lists', []):
                    entries = string_list(value)
                    if entries:
                        block.append(f'\t{name} = list(' + ', '.join(entries) + ')')
                    continue
                if name in cat.get('string_define_vars', []):
                    expanded = expand_define(value)
                    if STRING_LITERAL.match(expanded):
                        block.append(f'\t{name} = {expanded}')
                    continue
                if name in cat.get('sound_lists', []):
                    refs = [ref for ref in (sound_ref(f"'{f}'") for f in sound_files(value)) if ref]
                    if refs:
                        block.append(f'\t{name} = list(' + ', '.join(refs) + ')')
                    continue
                if name == 'rogue_armor':
                    armor = rogue_armor_value(rw.resolve(path, 'armor'))
                    if armor:
                        block.append(f'\trogue_armor = {armor}')
                    continue
                if name in cat.get('flag_vars', []):
                    if value is not None:
                        kept = [token for token in re.findall(r'[A-Z_][A-Z0-9_]*', value) if token in tg_names]
                        block.append(f'\t{name} = ' + (' | '.join(kept) if kept else 'NONE'))
                    continue
                if name in cat.get('paths', []):
                    target = runtime_path(value.strip().rstrip('/'), rules) if value and value.strip().startswith('/') else None
                    if target in valid:
                        block.append(f'\t{name} = {target}')
                    # Ratwood clears a path its parent sets (a stump's stump_type = FALSE); left out, the port would inherit it.
                    elif name in cat.get('nullable', []) and (value or 'null').strip() in ('null', 'FALSE', '0') and (rw.resolve(rw.parent(path), source_name) or '').strip().startswith('/'):
                        block.append(f'\t{name} = null')
                    continue
                if name in cat.get('path_counts', []):
                    # Types with how many of each (Ratwood debris, static_debris): list(/obj/item/natural/fibers = 1).
                    entries = [(runtime_path(p, rules), count) for p, count in list_paths(value)]
                    entries = [f'{p} = {count or 1}' for p, count in entries if p in valid]
                    if entries:
                        block.append(f'\t{name} = list(' + ', '.join(entries) + ')')
                    continue
                if name in cat.get('path_lists', []):
                    entries = [runtime_path(p, rules) for p, _ in list_paths(value)]
                    entries = [p for p in entries if p in valid]
                    if entries:
                        block.append(f'\t{name} = list(' + ', '.join(entries) + ')')
                    continue
                if name in cat.get('true_only', []):
                    if value and value.strip() == 'TRUE':
                        block.append(f'\t{name} = TRUE')
                    continue
                if name == 'slot_flags':
                    flags = slot_flags_value(value)
                    if flags:
                        block.append(f'\tslot_flags = {flags}')
                    continue
                if name == 'armor_type':
                    armor = armor_type_value(rw.resolve(path, 'armor'), port['armor'], armor_wear(path, coverage_value(rw.resolve(path, 'body_parts_covered'))))
                    if armor:
                        block.append(f'\tarmor_type = {armor}')
                    continue
                if name == 'body_parts_covered':
                    covered = coverage_value(value)
                    if covered:
                        block.append(f'\tbody_parts_covered = {covered}')
                    # Ratwood bares what the parent covers (a nightgown under a dress: body_parts_covered = null);
                    # left out, the port would inherit the parent's coverage.
                    elif coverage_value(rw.resolve(rw.parent(path), source_name)):
                        block.append('\tbody_parts_covered = NONE')
                    continue
                if name == 'loot':
                    entries = [(item, weight) for item, weight in loot_entries(value) if item in valid]
                    if entries:
                        block += ['\tloot = list('] + [f'\t\t{item} = {weight},' for item, weight in entries] + ['\t\t)']
                    continue
                if name == 'worn_icon' and (not value or value.strip() == 'null'):
                    value = slot_worn_icon(path, cat.get('slot_worn_icons', {}).get(name, {})) or value
                if value and ICON_LITERAL.match(value.strip()):
                    value = icon_ref(value)
                else:
                    value = literal(value, tg_names)
                if value is None or cat.get('value_defaults', {}).get(name) == value:
                    continue
                block.append(f'\t{name} = {value}')
            block += inherited_lines(cat, path)
            own_worn = rw.resolve(path, cat.get('rename', {}).get('worn_icon', 'worn_icon'))
            for name, slot_sheets in cat.get('slot_worn_icons', {}).items():
                if name in cat['vars'] or (own_worn and own_worn.strip() != 'null'):
                    continue
                sheet = slot_worn_icon(path, slot_sheets)
                if sheet:
                    block.append(f'\t{name} = {icon_ref(sheet)}')
            if cat.get('sprite_checks'):
                fix_sprites(path, block)
            if cat.get('bake') and port.get('bake'):
                bake_onmob(path, block, port['bake'])
            if cat.get('runtime_look') and not smooth:
                look = runtime_look(rw, path)
                kind, data = look.get('icon', (None, None))
                if kind == 'state':
                    block = [line for line in block if not line.startswith('\ticon_state = ')]
                    block.append(f'\ticon_state = "{data}"')
                elif kind == 'variant':
                    current, prefix, suffix, low, high = data
                    if current:
                        prefix = (rw.resolve(path, 'icon_state') or '').strip().strip('"') + prefix
                    block += [f'\trockhill_variant = "{prefix}#{suffix}"', f'\trockhill_variant_min = {low}', f'\trockhill_variant_max = {high}']
                if look.get('dir'):
                    block.append('\trockhill_random_dir = TRUE')
            if cat.get('random_pick'):
                picks = [target for target in (runtime_path(found, rules) for found in random_pick(rw, path)) if target in valid]
                if picks:
                    block.append('\trockhill_random_pick = list(' + ', '.join(picks) + ')')
            for name, value in cat.get('fixed_vars', {}).items():
                block.append(f'\t{name} = {value}')
            if cat.get('grid_storage'):
                block += grid_storage_lines(path)
            for name, source_name in cat.get('sound_vars', {}).items():
                files = [f for f in sound_files(rw.resolve(path, source_name)) if os.path.exists(os.path.join(CHECKOUT, f))]
                listed = ', '.join(f'"{runtime_sound(f, cat["runtime_sounds"])}"' for f in files)
                block.append(f'\t{name} = ' + (f'list({listed})' if files else 'null'))
            if cat.get('placement'):
                block += placement_lines(rw, path, path, tg_values, placed_paths)
            for prefix, names in cat.get('type_vars', {}).items():
                if boundary_match(path, prefix):
                    for name in names:
                        raw = rw.resolve(path, name)
                        value = literal(raw, tg_names)
                        text = (raw or '').strip()
                        if value is None and text.startswith('list('):
                            pairs = re.findall(r'(/[a-z][A-Za-z0-9_/]+)\s*=\s*(-?\d+(?:\.\d+)?)', raw)
                            if name == 'list_reagents':
                                pairs = fill_to_volume(pairs, rw.resolve(path, 'volume'))
                            pairs = [(p, n) for p, n in pairs if p in valid]
                            value = 'list(' + ', '.join(f'{p} = {n}' for p, n in pairs) + ')' if pairs else None
                            # A vessel with a drink of its own the port lacks (Ratwood's ales under its beer) stays empty
                            # rather than inheriting its parent's.
                            if value is None and name == 'list_reagents' and rw.types.get(path, {}).get(name) is not None:
                                value = 'null'
                            # A list of plain numbers (a vessel's possible_transfer_amounts), empty included.
                            numbers = re.fullmatch(r'list\(\s*((?:-?\d+(?:\.\d+)?\s*,?\s*)*)\)', text)
                            if value is None and numbers:
                                value = 'list(' + ', '.join(re.findall(r'-?\d+(?:\.\d+)?', numbers.group(1))) + ')'
                        if value is None and text.startswith('/'):
                            # A path (raw clay's cooked_type): its port, or null when there is none, so that the type
                            # does not inherit its parent's value (a clay vase that fires into the plain clay's stone).
                            target = runtime_path(text.rstrip('/'), rules)
                            value = target if target in valid else 'null'
                        if value is not None:
                            block.append(f'\t{name} = {value}')
            for prefix, names in cat.get('type_sounds', {}).items():
                if boundary_match(path, prefix):
                    for name in names:
                        raw = (rw.resolve(path, name) or '').strip()
                        ref = sound_ref(raw) if ICON_LITERAL.match(raw) else None
                        if ref:
                            block.append(f'\t{name} = {ref}')
            for prefix, name in port.get('typed_fills', {}).items():
                fill = typed_fill(path) if boundary_match(path, prefix) else None
                if fill and runtime_path(fill, rules) in valid:
                    block.append(f'\t{name} = {runtime_path(fill, rules)}')
            transfer = {line.split(' = ', 1)[0].strip(): line.split(' = ', 1)[1] for line in block[1:] if line.startswith(('\tamount_per_transfer_from_this = ', '\tpossible_transfer_amounts = '))}
            if len(transfer) == 2 and transfer['amount_per_transfer_from_this'] not in re.findall(r'-?\d+(?:\.\d+)?', transfer['possible_transfer_amounts']):
                # TG's reagent_container_defaults test wants the default among the choices; Ratwood's mortar pours 9 from
                # choices of 5 to 50, so it keeps its 9 alone (as survival/vessels.dm has it).
                block = [line for line in block if not line.startswith('\tpossible_transfer_amounts = ')]
                block.append(f"\tpossible_transfer_amounts = list({transfer['amount_per_transfer_from_this']})")
            if cat.get('init_overlays'):
                overlay = init_overlay(rw, path)
                if overlay:
                    block.append(f'\trockhill_overlay = "{overlay}"')
            if smooth:
                block += smooth
                smoothed['bitmask'] += 1
            else:
                block += group_lines(path)
                if cat.get('smoothing') and edge_receiver(path):
                    block.append('\tsmoothing_flags = SMOOTH_BITMASK_CARDINALS')
                    edge_sources[path] = smooth_targets(path)
                    smoothed['edges'] += 1
            blocks.append(block)
            if cat.get('sunlit'):
                blocks.append([f'{path}/{SUNLIT_LEAF}', '\trockhill_sunlit = TRUE', '\tbase_lighting_alpha = 255', '\tbase_lighting_color = COLOR_STARLIGHT'])
                if (rw.resolve(path, 'outdoors') or '').strip() in ('TRUE', '1'):
                    outdoor_areas.append(path)
            report_rows[cat['file']].append((path, usage[path]))
        text = '\n\n'.join('\n'.join(b) for b in blocks) + '\n'
        open(f"{OUT_DIR}/{cat['file']}", 'w', encoding='utf-8', newline='\n').write(text)
        print(f"{cat['file']}: {len(paths)} types")

    if grid_spec:
        generate_grid_storage(rw, grid_spec, grid_used, tg_names, valid, rules)
    if port.get('dungeon_templates'):
        generate_dungeon_templates(rw, port['dungeon_templates'], tg_names)

    rogue_armor_lines = []
    for path, fields in sorted(ROGUE_ARMOR_DATUMS.items()):
        rogue_armor_lines += [path] + [f'\t{k} = {v}' for k, v in fields.items() if v] + ['']
    open(f'{OUT_DIR}/rogue_armor.dm', 'w', encoding='utf-8', newline='\n').write('\n'.join(rogue_armor_lines).rstrip() + '\n')
    print(f'rogue_armor.dm: {len(ROGUE_ARMOR_DATUMS)} armor datums')
    generate_alt_grips(rw, port.get('alt_grips', {}), sorted(grip_paths))
    generate_intents(rw, port.get('intents', {}), sound_ref, valid)

    armor_lines = []
    for path, fields in sorted(ARMOR_DATUMS.items()):
        armor_lines += [path] + [f'\t{k} = {v}' for k, v in fields.items() if v] + ['']
    open(f'{OUT_DIR}/armor.dm', 'w', encoding='utf-8', newline='\n').write('\n'.join(armor_lines).rstrip() + '\n')
    print(f'armor.dm: {len(ARMOR_DATUMS)} armor datums')

    reskin_blocks = []
    for path in reskins:
        target = runtime[path]
        block = [target]
        if path in declared:
            block.append(f'\tparent_type = {path}')
        for name, value in port.get('reskin_vars', {}).items():
            block.append(f'\t{name} = {value}')
        for name in ('name', 'desc'):
            value = literal(rw.resolve(path, name), tg_names)
            if value is not None:
                block.append(f'\t{name} = {value}')
        raw_icon = rw.resolve(path, 'icon')
        smooth = smoothing_lines(path)
        if smooth:
            block += smooth
            smoothed['bitmask'] += 1
        else:
            icon = icon_ref(raw_icon) if raw_icon else None
            state = literal(rw.resolve(path, 'icon_state'), tg_names)
            if icon:
                block.append(f'\ticon = {icon}')
            if state:
                block.append(f'\ticon_state = {state}')
            block += group_lines(target) or ['\tsmoothing_groups = null']
            block.append('\tcanSmoothWith = null')
            if edge_receiver(path):
                block.append('\tsmoothing_flags = SMOOTH_BITMASK_CARDINALS')
                edge_sources[target] = smooth_targets(path)
                smoothed['edges'] += 1
            else:
                block.append('\tsmoothing_flags = NONE')
        reskin_blocks.append(block)
        report_rows['turfs_reskin.dm'].append((path, usage[path]))
    open(f'{OUT_DIR}/turfs_reskin.dm', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in reskin_blocks) + '\n')
    print(f'turfs_reskin.dm: {len(reskin_blocks)} types')


    for rel in port.get('extra_sounds', []):
        if not sound_ref(f"'{rel}'"):
            raise SystemExit(f'extra_sounds: {rel} is missing from the Ratwood checkout or in a folder the port does not take')

    ported = set(generated)
    rebased = collections.defaultdict(list)
    for path in sorted(usage):
        rule = replacement_for(path, rules) or {}
        spec = rule.get('port')
        if not rule.get('rebase') or not spec:
            continue
        block = [runtime_path(path, rules)]
        for name in spec['vars']:
            if name == 'layer' and spec.get('placement'):
                continue
            value = rw.resolve(path, name)
            if name in spec.get('path_strings', []):
                entries = [p for p, _ in list_paths(value)]
                value = ('list(' + ', '.join(f'"{p}"' for p in entries) + ')') if entries else None
            elif name in spec.get('ported_paths', []):
                raw = (value or '').strip()
                target = runtime_path(raw, rules) if raw.startswith('/') else None
                value = 'null' if raw == 'null' else (target if target in ported else None)
            elif name in spec.get('paths', []):
                target = runtime_path(value.strip(), rules) if value and value.strip().startswith('/') else None
                value = target if target in valid or target in jobs else None
            elif name in spec.get('define_strings', []):
                expanded = expand_define(value)
                value = expanded if expanded and STRING_LITERAL.match(expanded) else None
            elif name in spec.get('string_lists', []):
                entries = re.findall(r'"((?:[^"\\]|\\.)*)"', value or '')
                value = ('list(' + ', '.join(f'"{entry}"' for entry in entries) + ')') if entries else None
            elif name in spec.get('sounds', []) and value and ICON_LITERAL.match(value.strip()):
                value = sound_ref(value)
            elif value and ICON_LITERAL.match(value.strip()):
                value = icon_ref(value)
            else:
                value = literal(value, tg_names)
            if value is not None:
                block.append(f'\t{name} = {value}')
        if spec.get('runtime_look'):
            look = runtime_look(rw, path)
            kind, data = look.get('icon', (None, None))
            if kind == 'state':
                block = [line for line in block if not line.startswith('\ticon_state = ')] + [f'\ticon_state = "{data}"']
            elif kind == 'variant':
                current, prefix, suffix, low, high = data
                if current:
                    prefix = (rw.resolve(path, 'icon_state') or '').strip().strip('"') + prefix
                block += [f'\trockhill_variant = "{prefix}#{suffix}"', f'\trockhill_variant_min = {low}', f'\trockhill_variant_max = {high}']
            if look.get('dir'):
                block.append('\trockhill_random_dir = TRUE')
        if spec.get('placement'):
            block += placement_lines(rw, path, block[0], tg_values)
        if spec.get('fill'):
            contents, loot, chance = closet_fill(rw, path)
            contents = [p for p in (runtime_path(c, rules) for c in contents) if p in valid]
            loot = [(p, w) for p, w in ((runtime_path(i, rules), w) for i, w in loot) if p in valid]
            if contents:
                block.append('\trockhill_contents = list(' + ', '.join(contents) + ')')
            if loot:
                block += ['\trockhill_loot = list('] + [f'\t\t{p} = {w},' for p, w in loot] + ['\t\t)']
                if chance != 100:
                    block.append(f'\trockhill_loot_chance = {chance}')
        rebased[spec['file']].append(block)
        report_rows.setdefault(spec['file'], []).append((path, usage[path]))
        generated.add(block[0])
    state_blocks = []
    for path, variants in sorted(state_variants.items()):
        for variant in sorted(variants):
            state = next(state for p, state in state_edits if p == path and variant.endswith('/' + state_leaf(state)))
            state_blocks.append([variant, f'\ticon_state = "{state}"', '\trockhill_variant = null'])
    open(f'{OUT_DIR}/turf_states.dm', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in state_blocks) + '\n')
    print(f'turf_states.dm: {len(state_blocks)} turf subtypes for map icon_state edits')

    for file, blocks in rebased.items():
        open(f'{OUT_DIR}/{file}', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
        print(f'{file}: {len(blocks)} rebased types')

    smoothing_out = [f'#define {group_defines[o]} {"S_TURF" if group_numbers[o] >= 0 else "S_OBJ"}({abs(group_numbers[o])})' for o in sorted(owners, key=lambda o: group_numbers[o])]
    for owner in sorted(owners - grouped):
        smoothing_out += ['', owner, f'\tsmoothing_groups = {group_defines[owner]}']
    open(f'{OUT_DIR}/{SMOOTHING_FILE}', 'w', encoding='utf-8', newline='\n').write('\n'.join(smoothing_out) + '\n')
    print(f'{SMOOTHING_FILE}: {len(owners)} smoothing groups, {len(owners - grouped)} set on types declared elsewhere')
    open(f'{OUT_DIR}/{AREAS_JSON}', 'w', encoding='utf-8', newline='\n').write(json.dumps({'sunlit': SUNLIT_LEAF, 'outdoors': sorted(outdoor_areas)}, indent='\t') + '\n')

    for rel in port.get('extra_icons', []):
        found = sorted(glob.glob(os.path.join(CHECKOUT, rel))) if any(c in rel for c in '*?[') else [os.path.join(CHECKOUT, rel)]
        for source in found:
            icons[source] = icon_dest(os.path.relpath(source, CHECKOUT).replace(os.sep, '/'))

    edge_lines = []
    for name in ('rockhill_turf_edges', 'rockhill_turf_edge_overrides', 'rockhill_turf_edge_sources'):
        edge_lines.append(f'GLOBAL_LIST_INIT({name}, {name}())')
    edge_lines += ['', '/proc/rockhill_turf_edges()', '\treturn list(']
    edge_lines += [f'\t\t{p} = {s},' for p, s in sorted(edge_states.items())]
    edge_lines += ['\t\t)', '', '/proc/rockhill_turf_edge_overrides()', '\treturn list(']
    edge_lines += [f'\t\t{p} = {s},' for p, s in sorted(edge_overrides.items())]
    edge_lines += ['\t\t)', '', '/proc/rockhill_turf_edge_sources()', '\treturn list(']
    for p, sources in sorted(edge_sources.items()):
        edge_lines.append(f'\t\t{p} = list(')
        edge_lines += [f'\t\t\t{s},' for s in sorted(set(sources))]
        edge_lines.append('\t\t\t),')
    edge_lines.append('\t\t)')
    open(f'{OUT_DIR}/{EDGES_FILE}', 'w', encoding='utf-8', newline='\n').write('\n'.join(edge_lines) + '\n')
    print(f"smoothing: {smoothed['bitmask']} bitmask types from {sum(1 for v in sheets.values() if v)} sheets, {smoothed['edges']} edge receivers, {len(edge_states)} edge sources")

    # A copy left from an earlier run goes with the folder it came from.
    for folder in EXCLUDED:
        copied = f"{ICON_DIR}/{folder[len('icons/'):] if folder.startswith('icons/') else folder}"
        if os.path.isdir(copied):
            shutil.rmtree(copied)
            print('removed copies of an excluded folder:', copied)
    if BLANK_USERS:
        os.makedirs(os.path.dirname(BLANK_WORN), exist_ok=True)
        dmi.write(BLANK_WORN, 32, 32, [('', bytes(32 * 32 * 4))])
        print(f'blank worn sheet: {len(BLANK_USERS)} wearables without a worn sprite')
    print(f'female worn sprites: {len(FEMALE_USERS)} wearables')
    for src, dest in list(icons.items()) + list(sounds.items()):
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copyfile(src, dest)
    for src, dest in runtime_sounds.items():
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copyfile(src, dest)
    extra_files = port.get('extra_files', {})
    fetch_sources(list(extra_files))
    for rel, dest in extra_files.items():
        src = os.path.join(CHECKOUT, rel)
        if not os.path.exists(src):
            raise SystemExit(f'extra_files: {rel} is missing from the Ratwood checkout')
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        shutil.copyfile(src, dest)
    print('extra files copied:', len(extra_files))
    print('icons copied:', len(icons), 'bytes:', sum(os.path.getsize(d) for d in icons.values()))
    print('runtime sounds copied:', len(runtime_sounds), 'bytes:', sum(os.path.getsize(d) for d in runtime_sounds.values()))
    print('sounds copied:', len(sounds))

    with open(REPORT, 'w', encoding='utf-8', newline='\n') as out:
        out.write('# Ported Ratwood content\n\n')
        out.write('Generated by `modular_redtard/tools/port_rockhill.py` from the Ratwood-2.0 code tree and the Rockhill map. ')
        out.write('Each type keeps its Ratwood path, so the map loads it unchanged; `parent_type` grafts the Ratwood branch onto a TG or module base. ')
        out.write('Re-run the tool after the map gains new types (the map generator fails on a missing turf or area and warns on a missing object).\n\n')
        if SOURCE_REVISION:
            out.write(f'Ratwood revision: `{SOURCE_REVISION[0]}` ({SOURCE_REVISION[1]}).\n\n')
        for file in [cat['file'] for cat in categories] + ['turfs_reskin.dm']:
            rows = report_rows.get(file, [])
            if not rows:
                continue
            out.write(f"## {file} ({len(rows)} types)\n\n| Type | Tiles |\n|---|---|\n")
            for path, count in sorted(rows, key=lambda r: -r[1]):
                out.write(f'| `{path}` | {count} |\n')
            out.write('\n')
        out.write(f'## Not ported ({len(skipped)} types, dropped from the map)\n\n| Type | Tiles |\n|---|---|\n')
        for path, count in skipped.most_common():
            out.write(f'| `{path}` | {count} |\n')
        out.write('\n## Icons\n\n')
        for src, dest in sorted(icons.items(), key=lambda kv: kv[1]):
            rel = os.path.relpath(src, CHECKOUT).replace('\\', '/')
            out.write(f'- `{dest}` from Ratwood `{rel}`\n')
        if NO_SPRITE:
            out.write(f'\n## Items without a world sprite ({len(NO_SPRITE)})\n\n')
            out.write('Ratwood names an `icon_state` its sheet does not have (a sprite chosen at runtime, or a broken one). The port writes `icon_state = null`, as TG does for an item with no sprite, so the TG icon tests pass and the item stays listed here.\n\n| Type | Sheet | Missing state |\n|---|---|---|\n')
            for path, sheet, state in sorted(NO_SPRITE):
                out.write(f'| `{path}` | `{sheet}` | `{state}` |\n')
        if BLANK_USERS:
            out.write(f'\n## Wearables without a worn sprite ({len(BLANK_USERS)})\n\n')
            out.write(f'No sheet holds their worn state: `worn_icon = \'{BLANK_WORN}\'` (one empty state) and `worn_icon_state = null`, the TG way to say "no worn sprite".\n\n')
            for path in sorted(BLANK_USERS):
                out.write(f'- `{path}`\n')
        if extra_files:
            out.write('\n## Files\n\n')
            for rel, dest in sorted(extra_files.items(), key=lambda kv: kv[1]):
                out.write(f'- `{dest}` from Ratwood `{rel}`\n')
        if runtime_sounds:
            out.write('\n## Runtime sounds\n\n')
            out.write('Area music and ambience are kept in the repository, as Ratwood keeps them, and read from disk at runtime by path (credits of the third-party tracks: Ratwood `sound/music/credits.txt`). A missing file is skipped.\n\n')
            for src, dest in sorted(runtime_sounds.items(), key=lambda kv: kv[1]):
                rel = os.path.relpath(src, CHECKOUT).replace('\\', '/')
                out.write(f'- `{dest}` from Ratwood `{rel}`\n')
        if sounds:
            out.write('\n## Sounds\n\n')
            for src, dest in sorted(sounds.items(), key=lambda kv: kv[1]):
                rel = os.path.relpath(src, CHECKOUT).replace('\\', '/')
                out.write(f'- `{dest}` from Ratwood `{rel}`\n')
    if port.get('bake'):
        write_bake_manifest(port['bake'])
    print('report:', REPORT, 'skipped types:', len(skipped))
    return generated


SOUND_LITERAL = re.compile(r"'(sound/[^']+?\.(?:ogg|wav|mp3))'")


SFX_ENTRY = re.compile(r'if\s*\(\s*"([^"]+)"\s*\)\s*\n\s*soundin\s*=\s*pick\(([^)]*)\)')
SFX_FILES = {}


def sfx_files(key):
    """The files of one of Ratwood's sound keys ("plantcross" and the like): its get_sfx() in code/game/sound.dm picks one."""
    if not SFX_FILES:
        source = os.path.join(CHECKOUT, 'code', 'game', 'sound.dm')
        text = open(source, encoding='utf-8', errors='replace').read() if os.path.exists(source) else ''
        for found in SFX_ENTRY.finditer(text):
            SFX_FILES[found.group(1)] = SOUND_LITERAL.findall(found.group(2))
        SFX_FILES.setdefault('', [])
    return SFX_FILES.get(key, [])


def sound_files(raw):
    text = raw or ''
    for _ in range(8):
        names = [name for name in set(re.findall(r'\b[A-Z_][A-Z0-9_]*\b', text)) if name in DEFINE_VALUES]
        if not names:
            break
        for name in names:
            text = re.sub(rf'\b{name}\b', lambda _match, value=DEFINE_VALUES[name]: value, text)
    files = SOUND_LITERAL.findall(text)
    key = text.strip()
    if not files and len(key) > 1 and key[0] == key[-1] == '"':
        files = sfx_files(key[1:-1])
    return files


def fetch_sources(paths):
    absent = sorted({p for p in paths if not os.path.exists(os.path.join(CHECKOUT, p))})
    if absent and not OFFLINE:
        git('sparse-checkout', 'add', *('/' + p for p in absent))
        git('read-tree', '-mu', 'HEAD')
    missing = [p for p in absent if not os.path.exists(os.path.join(CHECKOUT, p))]
    if missing:
        print('runtime sounds missing from Ratwood:', ', '.join(missing))


def held_paths(body):
    text = '\n'.join(body)
    found = HOLD_LIST.search(text)
    if not found:
        return None
    depth = 1
    k = found.end()
    while k < len(text) and depth:
        depth += {'(': 1, ')': -1}.get(text[k], 0)
        k += 1
    return re.findall(r'/[A-Za-z0-9_]+(?:/[A-Za-z0-9_]+)*', text[found.end():k - 1])


def generate_grid_storage(rw, spec, used, tg_names, valid, rules):
    root = spec['from']
    chain = set()
    for component in used:
        p = component
        while p and boundary_match(p, root):
            chain.add(p)
            p = rw.parent(p)
    blocks = []
    holders = 0
    for component in sorted(chain, key=lambda p: (p.count('/'), p)):
        target = spec['to'] + component[len(root):]
        block = [target]
        for name, source in spec['vars'].items():
            raw = rw.resolve(component, source) if component == root else rw.types.get(component, {}).get(source)
            value = literal(raw, tg_names)
            if value is not None:
                block.append(f'\t{name} = {value}')
        blocks.append(block)
        held = held_paths(STORAGE_NEW.get(component, []))
        if held is not None:
            kept = sorted({runtime_path(p, rules) for p in held} & valid)
            blocks.append([f'{target}/New()', '\t. = ..()', '\tset_holdable(list(' + ', '.join(kept) + '))'])
            holders += 1
    open(f'{OUT_DIR}/{spec["file"]}', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f'{spec["file"]}: {len(chain)} grid storages, {holders} with a can-hold list')


def icon_dest(rel):
    return f"{ICON_DIR}/{rel[len('icons/'):] if rel.startswith('icons/') else rel}"


JOB_ROOT = '/datum/job/roguetown'
ADVCLASS_ROOT = '/datum/advclass'
ADVCLASS_TARGET = '/datum/rockhill_advclass'
ADVCLASS_OUTFIT = '/datum/outfit/job/roguetown/rockhill_class'
ADVCLASS_SHEET = '/datum/attribute_holder/sheet/job/rockhill_class'
ADVCLASS_FILE = 'advclasses.dm'
LANDMARK_ROOT = '/obj/effect/landmark/start'
LANDMARK_REBASE = '/obj/effect/landmark/start/rockhill'


def string_value(raw):
    if raw is None:
        return None
    v = raw.strip()
    if STRING_LITERAL.match(v):
        return tg_spelling(v)
    return None


def number_value(raw):
    if raw is None or not NUMBER.match(raw.strip()):
        return None
    return int(float(raw.strip()))


def define_name(title):
    return 'JOB_ROCKHILL_' + re.sub(r'[^A-Z0-9]+', '_', title.upper()).strip('_')


def tg_job_titles():
    titles = set()
    for line in open('code/__DEFINES/jobs.dm', encoding='utf-8', errors='ignore'):
        m = re.match(r'^#define JOB_[A-Z0-9_]+\s+"([^"]+)"', line)
        if m:
            titles.add(m.group(1))
    return titles


def map_adjustment(path):
    text = strip_comments(open(path, encoding='utf-8', errors='ignore').read())
    def block(name):
        m = re.search(name + r'\s*=\s*list\(', text)
        if not m:
            return ''
        depth = 1
        i = m.end()
        while i < len(text) and depth:
            depth += {'(': 1, ')': -1}.get(text[i], 0)
            i += 1
        return text[m.end():i - 1]
    blacklist = set(re.findall(r'(/datum/job/roguetown/[\w/]+)', block('blacklist')))
    slots = {p: int(n) for p, n in re.findall(r'(/datum/job/roguetown/[\w/]+)\s*=\s*(\d+)', block('slot_adjust'))}
    titles = {}
    for p, body in re.findall(r'(/datum/job/roguetown/[\w/]+)\s*=\s*list\(([^)]*)\)', block('title_adjust')):
        titles[p] = re.findall(r'"([^"]+)"', body)
    return blacklist, slots, titles


def expand_define(raw):
    value = (raw or '').strip()
    for _ in range(8):
        if re.match(r'^[A-Z_][A-Z0-9_]*$', value) and value in DEFINE_VALUES:
            value = DEFINE_VALUES[value].strip()
        else:
            break
    return value


def coverage_value(raw):
    tokens = set()
    stack = re.findall(r'[A-Z_][A-Z0-9_]*', raw or '')
    seen = set()
    while stack:
        token = stack.pop()
        if token in seen:
            continue
        seen.add(token)
        value = DEFINE_VALUES.get(token, '')
        if value and not re.match(r'^\(?\s*1\s*<<', value) and re.search(r'[A-Z]', value):
            stack += re.findall(r'[A-Z_][A-Z0-9_]*', value)
            continue
        if token in COVERAGE_MAP:
            tokens.add(COVERAGE_MAP[token])
    return '|'.join(sorted(tokens)) if tokens else None


def coverage_tokens(raw):
    """Ratwood's body part flags a body_parts_covered value names, through its defines (FULL_HEAD, FACE, EYES)."""
    tokens = set()
    stack = re.findall(r'[A-Z_][A-Z0-9_]*', raw or '')
    seen = set()
    while stack:
        token = stack.pop()
        if token in seen:
            continue
        seen.add(token)
        value = DEFINE_VALUES.get(token, '')
        if value and not re.match(r'^\(?\s*1\s*<<', value) and re.search(r'[A-Z]', value):
            stack += re.findall(r'[A-Z_][A-Z0-9_]*', value)
            continue
        tokens.add(token)
    return tokens


def fill_to_volume(pairs, volume_raw):
    """A container's list_reagents as it fills: each reagent in turn until the container is full, as add_reagent() does
    (Ratwood's starsugar powder lists more than it holds, and its nutriment never gets in). Reagents the port lacks keep their
    place, so what follows them gets what it got at Ratwood's."""
    volume = define_value_number(volume_raw) if volume_raw else None
    if volume is None:
        return pairs
    left = float(volume)
    filled = []
    for path, amount in pairs:
        taken = min(float(amount), max(left, 0))
        left -= taken
        if taken > 0:
            filled.append((path, f'{taken:g}'))
    return filled


def exact_coverage_value(raw):
    """Ratwood's coverage as it is, for the module's rogue_coverage (TG's flags and ROGUE_COVER_*, clothing/_defines.dm), where
    the folded body_parts_covered (coverage_value()) would say otherwise or the item covers part of the head; 'null' elsewhere:
    the module then reads TG's flags, HEAD as the whole head and CHEST as the chest and the vitals."""
    tokens = coverage_tokens(raw) & set(EXACT_COVERAGE)
    if not tokens & (HEAD_PARTS | {'HEAD'}) and ('CHEST' in tokens) == ('VITALS' in tokens):
        return 'null'
    left = set(tokens)
    flags = []
    for token, flag in EXACT_COVERAGE.items():
        if token not in left:
            continue
        group = next((name for name, parts in EXACT_COVERAGE_GROUPS if token in parts and set(parts) <= left), None)
        if group:
            flags.append(group)
            left -= set(dict(EXACT_COVERAGE_GROUPS)[group])
        else:
            flags.append(flag)
            left.discard(token)
    return ' | '.join(flags) if flags else 'NONE'


def armor_wear(path, coverage):
    if boundary_match(path, '/obj/item/clothing/under'):
        return 'under'
    for root, (wear, extremity) in WEAR_COVERAGE.items():
        if boundary_match(path, root) and set((coverage or '|'.join(extremity)).split('|')) == extremity:
            return wear
    return None


def armor_numbers(raw):
    """Ratings of a Ratwood armor list; values may be numbers or tier defines (ARMOR_PLATE -> list("blunt" = DR_LIGHT, ...))."""
    value = expand_define(raw)
    numbers = {}
    for key, token in re.findall(r'"(\w+)"\s*=\s*([A-Za-z0-9_.\-]+)', value or ''):
        number = define_value_number(token)
        if number is not None:
            numbers[key] = float(number)
    return numbers


def armor_type_value(raw, armor_cfg, wear=None):
    numbers = armor_numbers(raw)
    if not numbers:
        return None
    tiers = max(numbers.values()) <= armor_cfg.get('max_tier', 5)
    scale, cap = armor_cfg['scale'], armor_cfg['cap']
    def scaled(n):
        if tiers:
            # Ratwood DR tiers: damage * 1 / (1 + coefficient * tier) reaches the body; TG armor is the percent stopped.
            return int(round(100 * (1 - 1 / (1 + armor_cfg['dr_coefficient'] * max(n, 0)))))
        return int(round(min(max(n, 0) * scale, cap)))
    fields = {
        'fire': scaled(numbers.get('fire', 0)),
        'acid': scaled(numbers.get('acid', 0)),
    }
    if not any(fields.values()):
        return None
    name = (raw or '').strip()
    if re.match(r'^ARMOR_[A-Z0-9_]+$', name):
        leaf = 'rockhill_' + name[len('ARMOR_'):].lower()
    else:
        leaf = 'rockhill_f{fire}_a{acid}'.format(**fields)
    if wear in ('hands', 'feet'):
        leaf += '_' + wear
    path = ('/datum/armor/clothing_under/' if wear == 'under' else '/datum/armor/') + leaf
    ARMOR_DATUMS[path] = fields
    return path


def rogue_armor_value(raw):
    numbers = {k: int(n) for k, n in armor_numbers(raw).items()}
    fields = OrderedDict((k, max(0, numbers.get(k, 0))) for k in ('blunt', 'slash', 'stab', 'piercing', 'fire', 'acid', 'magic'))
    if not any(fields.values()):
        return None
    name = (raw or '').strip()
    if re.match(r'^ARMOR_[A-Z0-9_]+$', name):
        leaf = name[len('ARMOR_'):].lower()
    else:
        leaf = 'b{blunt}_s{slash}_t{stab}_p{piercing}_f{fire}_a{acid}'.format(**fields)
    path = '/datum/rogue_armor/' + leaf
    ROGUE_ARMOR_DATUMS[path] = fields
    return path


def define_value_number(raw):
    if raw is None:
        return None
    value = expand_define(raw.strip())
    for _ in range(4):
        stripped = value.strip()
        if stripped.startswith('(') and stripped.endswith(')'):
            value = expand_define(stripped[1:-1])
        else:
            break
    value = value.strip()
    if not NUMBER.match(value):
        return None
    number = float(value)
    return int(number) if number == int(number) else number


def alt_grip_paths(rw, raw):
    """Grip datums of a Ratwood item's alt_grips, a list or a define such as LONGSWORD_STOCK_ALT_GRIPS."""
    out = []
    for path in re.findall(r'/datum/alt_grip[A-Za-z0-9_/]*', expand_define(raw or '')):
        path = path.rstrip('/')
        if path in rw.types and path not in out:
            out.append(path)
    return out


def assigned_numbers(raw):
    """"key" = value pairs of a list literal, values turned into numbers through the defines."""
    out = OrderedDict()
    for key, token in re.findall(r'"(\w+)"\s*=\s*([A-Za-z0-9_.\-]+)', raw or ''):
        number = define_value_number(token)
        if number is not None:
            out[key] = number
    return out


def generate_alt_grips(rw, spec, grips):
    """Alternate grips of Azure Peak as Ratwood has them (alt_grip.dm): name, two hands, skill rank, traits, intents, on-hand pose, stat changes."""
    blocks = []
    for path in grips:
        block = [path]
        name = string_value(rw.resolve(path, 'name'))
        if name:
            block.append(f'\tname = {name}')
        if (rw.resolve(path, 'two_handed') or '').strip() in ('TRUE', '1'):
            block.append('\ttwo_handed = TRUE')
        rank = define_value_number(rw.resolve(path, 'skill_req'))
        if rank:
            block.append(f'\tskill_rank = {rank}')
        traits = [t for t in re.findall(r'TRAIT_[A-Z0-9_]+', rw.resolve(path, 'trait_applied') or '') if t in DEFINE_VALUES]
        if traits:
            block.append('\ttrait_applied = list(' + ', '.join(traits) + ')')
        intents = intent_paths(rw, rw.resolve(path, 'grip_intents'))
        if intents:
            USED_INTENTS.update(intents)
            block.append('\tgrip_intents = list(' + ', '.join(intents) + ')')
        if re.search(r'"altgrip"\s*=\s*list\(', rw.resolve(path, 'onmobprop_overrides') or ''):
            block.append(f'\tinhand_suffix = "_{path.rsplit("/", 1)[1]}"')
        for source_name in spec.get('stat_vars', ['var_overrides', 'additive_var_overrides']):
            numbers = assigned_numbers(rw.resolve(path, source_name))
            if numbers:
                block.append(f'\t{source_name} = list(' + ', '.join(f'"{k}" = {v}' for k, v in numbers.items()) + ')')
        blocks.append(block)
    open(f"{OUT_DIR}/{spec.get('file', 'alt_grips.dm')}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec.get('file', 'alt_grips.dm')}: {len(blocks)} alternate grips")


def intent_paths(rw, raw):
    out = []
    for token in re.findall(r'(/datum/intent[A-Za-z0-9_/]*|[A-Z_][A-Z0-9_]*)', raw or ''):
        path = token if token.startswith('/') else expand_define(token)
        if path.startswith('/datum/intent') and path in rw.types and path not in out:
            out.append(path)
    return out


def skill_target(cfg, raw):
    spec = cfg['attributes']
    path = (raw or '').strip()
    if path in spec['meta']:
        return spec['skill_target'] + path[len(spec['skill_root']):]
    return None


def string_list(raw):
    out = []
    for token in re.findall(r'"(?:[^"\\]|\\.)*"|[A-Z_][A-Z0-9_]*', raw or ''):
        value = token if token.startswith('"') else expand_define(token)
        if STRING_LITERAL.match(value) and value not in out:
            out.append(value)
    return out


def intent_effect_lines(rw, path, spec):
    """The status effect a Ratwood effect intent puts on a hit (intent_effect, target_parts) as data: name, stat changes, duration, zones."""
    effect = (rw.resolve(path, 'intent_effect') or '').strip()
    if not effect.startswith('/datum/status_effect') or effect not in rw.types:
        return []
    stats = [f"{spec['stats'][key]} = {value}" for key, value in re.findall(r'(STATKEY_[A-Z]+)\s*=\s*(-?[\d.]+)', rw.resolve(effect, 'effectedstats') or '') if key in spec['stats']]
    if not stats:
        return []
    lines = ['\teffect_stats = list(' + ', '.join(stats) + ')']
    raw_duration = (rw.resolve(effect, 'duration') or '').strip()
    seconds = re.fullmatch(r'([\d.]+)\s*SECONDS', raw_duration)
    duration = float(seconds.group(1)) * 10 if seconds else define_value_number(raw_duration)
    if duration:
        lines.append(f'\teffect_duration = {int(duration) if duration == int(duration) else duration}')
    alert = (rw.resolve(effect, 'alert_type') or '').strip()
    name = string_value(rw.resolve(alert, 'name')) if alert in rw.types else None
    if name:
        lines.append(f'\teffect_name = {name}')
    zones = [expand_define(token) for token in re.findall(r'BODY_ZONE_[A-Z_]+', rw.resolve(path, 'target_parts') or '')]
    zones = [zone for zone in zones if STRING_LITERAL.match(zone)]
    if zones:
        lines.append('\teffect_zones = list(' + ', '.join(zones) + ')')
    return lines


def generate_intents(rw, spec, sound_ref, valid=frozenset()):
    renames = spec.get('rename', {})
    numeric = spec.get('numeric', [])
    flags = spec.get('flags', [])
    strings = spec.get('strings', [])
    blocks = []
    fetch_sources([f for path in USED_INTENTS for f in sound_files(rw.resolve(path, 'hitsound'))])
    for path in sorted(USED_INTENTS):
        block = [path]
        for name in strings:
            value = string_value(rw.resolve(path, renames.get(name, name)))
            if value is None:
                value = expand_define(rw.resolve(path, renames.get(name, name)) or '')
                value = value if STRING_LITERAL.match(value) else None
            if value is not None and not (value == '""' and name in spec.get('strings_skip_empty', [])):
                block.append(f'\t{name} = {value}')
        verbs = string_list(rw.resolve(path, 'attack_verb'))
        if verbs:
            block.append('\tattack_verb = list(' + ', '.join(verbs) + ')')
        defaults = spec.get('numeric_defaults', {})
        for name in numeric:
            number = define_value_number(rw.resolve(path, renames.get(name, name)))
            if number is not None and (name not in defaults or number != defaults[name]):
                block.append(f'\t{name} = {number}')
        true_only = spec.get('flags_true_only', [])
        for name in flags:
            value = (rw.resolve(path, renames.get(name, name)) or '').strip()
            if value in ('TRUE', 'FALSE', '0', '1'):
                if name in true_only and value not in ('TRUE', '1'):
                    continue
                block.append(f"\t{name} = {'TRUE' if value in ('TRUE', '1') else 'FALSE'}")
        for name in spec.get('paths', []):
            raw = (rw.resolve(path, name) or '').strip()
            if raw.startswith('/') and raw in valid:
                block.append(f'\t{name} = {raw}')
        if spec.get('effects'):
            block += intent_effect_lines(rw, path, spec['effects'])
        sounds = sound_files(rw.resolve(path, 'hitsound'))
        refs = [ref for ref in (sound_ref(f"'{f}'") for f in sounds) if ref]
        if refs:
            block.append('\thitsound = list(' + ', '.join(refs) + ')')
        blocks.append(block)
    open(f"{OUT_DIR}/{spec.get('file', 'intents.dm')}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec.get('file', 'intents.dm')}: {len(blocks)} intents")


def slot_flags_value(raw):
    if not raw:
        return None
    mapped = sorted({SLOT_FLAG_MAP[t] for t in re.findall(r'ITEM_SLOT_[A-Z_]+', raw) if t in SLOT_FLAG_MAP})
    return '|'.join(mapped) if mapped else None


def masculine(text):
    return 'should_wear_masc_clothes' in text or re.search(r'gender\s*==\s*MALE\b', text) is not None


def feminine(text):
    return 'should_wear_femme_clothes' in text or re.search(r'gender\s*==\s*FEMALE\b', text) is not None


def parse_pre_equip(body):
    slots = {}
    contents = None
    stack = []
    chains = {}
    switches = {}
    choices = {}
    i = 0
    while i < len(body):
        line = body[i]
        i += 1
        text = line.strip()
        if not text:
            continue
        indent = len(line) - len(line.lstrip('\t'))
        while stack and stack[-1][0] >= indent:
            stack.pop()
        listed = re.match(r'^var/(?:list/)?(\w+)\s*=\s*list\(', text)
        if listed:
            gathered = text
            while gathered.count('(') > gathered.count(')') and i < len(body):
                gathered += ' ' + body[i].strip()
                i += 1
            first = re.search(r'(/obj/item/[A-Za-z0-9_/]+)', gathered)
            if first:
                choices[listed.group(1)] = first.group(1)
            continue
        if text.startswith('switch'):
            switches[indent] = False
            stack.append((indent, True))
            continue
        if re.match(r'^if\b', text):
            parent = stack[-1][0] if stack else -1
            if parent in switches and not switches[parent]:
                switches[parent] = True
                accepted = True
            elif parent in switches:
                accepted = False
            elif 'prob(' in text:
                accepted = True
                chains[indent] = 'taken'
            elif 'map_name' in text or 'current_map' in text:
                accepted = False
                chains[indent] = 'else'
            else:
                accepted = masculine(text) or re.match(r'^if\s*\(\s*H\.mind\s*\)$', text) is not None
                chains[indent] = 'else' if feminine(text) else 'masc'
            stack.append((indent, accepted))
            continue
        if re.match(r'^else\s+if\b', text):
            stack.append((indent, chains.get(indent) != 'taken' and masculine(text)))
            continue
        if re.match(r'^else\b', text):
            stack.append((indent, chains.get(indent) == 'else'))
            continue
        if re.match(r'^(for|while)\b', text):
            stack.append((indent, False))
            continue
        if not all(ok for _, ok in stack):
            continue
        m = re.match(r'^(\w+)\s*=\s*(/obj/item/[A-Za-z0-9_/]+)\s*$', text)
        if m and m.group(1) in OUTFIT_SLOTS:
            slots[m.group(1)] = m.group(2)
            continue
        m = re.match(r'^(\w+)\s*=\s*(\w+)\[', text)
        if m and m.group(1) in OUTFIT_SLOTS and m.group(2) in choices:
            slots[m.group(1)] = choices[m.group(2)]
            continue
        if re.match(r'^backpack_contents\s*=\s*list\(', text):
            gathered = text
            while gathered.count('(') > gathered.count(')') and i < len(body):
                gathered += ' ' + body[i].strip()
                i += 1
            contents = [(p, int(n) if n else 1) for p, n in re.findall(r'(/obj/item/[A-Za-z0-9_/]+)\s*(?:=\s*(\d+))?', gathered)]
    return slots, contents


def job_subclasses(rw, job):
    subclasses = re.findall(r'(/datum/advclass/[A-Za-z0-9_/]+)', rw.resolve(job, 'job_subclasses') or '')
    if not subclasses:
        tags = set(re.findall(r'(CTAG_[A-Z0-9_]+)', rw.resolve(job, 'advclass_cat_rolls') or ''))
        if tags:
            subclasses = sorted(p for p in rw.types if p.startswith('/datum/advclass/') and tags & set(re.findall(r'(CTAG_[A-Z0-9_]+)', rw.resolve(p, 'category_tags') or '')) and rw.resolve(p, 'outfit'))
    return [p for p in dict.fromkeys(subclasses) if p in rw.types]


def role_outfit(rw, job):
    """What a role wears at roundstart: Ratwood equips the job's own outfit at spawn and the subclass outfit over it
    once a class is picked. The first subclass that dresses the role is taken (a Wretch's first class, the licker,
    brings no clothes); a map branch of pre_equip (`map_name == "Desert Town"`) falls through to its else."""
    subclasses = job_subclasses(rw, job)
    base = outfit_slots(rw, rw.resolve(job, 'outfit') or '')

    def over_base(worn):
        contents = worn['contents'] if worn['contents'] is not None else base['contents']
        return {'source': worn['source'] or base['source'], 'slots': {**base['slots'], **worn['slots']}, 'contents': contents}

    chosen = next((advclass for advclass in subclasses if outfit_slots(rw, rw.resolve(advclass, 'outfit') or '')['slots']), subclasses[0] if subclasses else None)
    dressed = over_base(outfit_slots(rw, rw.resolve(chosen, 'outfit') or '')) if chosen else base
    dressed['advclass'] = chosen
    dressed['subclasses'] = subclasses
    return dressed


def outfit_slots(rw, source):
    source = (source or '').strip()
    chain = []
    parts = source.split('/')
    for k in range(3, len(parts) + 1):
        chain.append('/'.join(parts[:k]))
    ratwood_slots = {}
    contents = []
    for outfit in chain:
        for slot, value in rw.types.get(outfit, {}).items():
            path = re.match(r'^(/obj/item/[A-Za-z0-9_/]+)$', value.strip())
            if slot in OUTFIT_SLOTS and path:
                ratwood_slots[slot] = path.group(1)
            elif slot == 'backpack_contents' and value.strip().startswith('list('):
                contents = [(p, int(n) if n else 1) for p, n in re.findall(r'(/obj/item/[A-Za-z0-9_/]+)\s*(?:=\s*(\d+))?', value)]
        if outfit in PRE_EQUIP:
            found, items = parse_pre_equip(PRE_EQUIP[outfit])
            ratwood_slots.update(found)
            if items is not None:
                contents = items
    tg = {OUTFIT_SLOTS[slot]: path for slot, path in ratwood_slots.items() if slot not in ('backl', 'backr')}
    backs = [ratwood_slots[slot] for slot in ('backl', 'backr') if slot in ratwood_slots]
    backs.sort(key=lambda path: not path.startswith('/obj/item/storage'))
    tg.update(zip(('back', 'backr'), backs))
    return {'source': source, 'slots': tg, 'contents': contents}


def generate_advclasses(cfg, rw, class_jobs, class_outfits, valid, known_traits):
    spec = cfg['attributes']
    blocks = []
    for advclass in sorted(class_jobs):
        suffix = advclass[len(ADVCLASS_ROOT):]
        owners = class_jobs[advclass]
        name = string_value(rw.resolve(advclass, 'name')) or '"' + suffix.rsplit('/', 1)[1] + '"'
        dressed = class_outfits[advclass]
        outfit = ADVCLASS_OUTFIT + suffix
        block = [outfit, f'\tname = {name}', f'\tjobtype = {owners[0]}']
        for var in ('uniform', 'shirt', 'suit', 'cloak', 'head', 'mask', 'mouth', 'neck', 'gloves', 'wrists', 'ring', 'shoes', 'belt', 'back', 'backr', 'l_pocket', 'r_pocket', 'l_hand', 'r_hand'):
            item = dressed['slots'].get(var)
            if item and item in valid:
                block.append(f'\t{var} = {item}')
        contents = [(item, count) for item, count in (dressed['contents'] or []) if item in valid]
        if contents and dressed['slots'].get('back') in valid:
            block += ['\tbackpack_contents = list('] + [f'\t\t{item} = {count},' for item, count in contents] + ['\t\t)']
        blocks.append(block)
        data = role_attributes(rw, owners[0], advclass, dressed['source'], spec)
        entries = [f'\t\t{stat} = {amount},' for stat, amount in sorted(data['stats'].items())]
        for path, value in sorted(data['skills'].items()):
            if path in spec['meta']:
                entries.append(f"\t\t{spec['skill_target'] + path[len(spec['skill_root']):]} = {min(value, 60)},")
        sheet = None
        if entries:
            sheet = ADVCLASS_SHEET + suffix
            blocks.append([sheet, '\traw_attribute_list = list('] + entries + ['\t\t)'])
        block = [ADVCLASS_TARGET + suffix, f'\tname = {name}', f'\toutfit = {outfit}']
        tutorial = string_value(rw.resolve(advclass, 'tutorial'))
        if tutorial and '[' not in tutorial:
            block.append(f'\tdesc = {tutorial}')
        if sheet:
            block.append(f'\tattribute_sheet = {sheet}')
        traits = [trait for trait in data['traits'] if trait in known_traits]
        if traits:
            block += ['\trockhill_traits = list('] + [f'\t\t{trait},' for trait in traits] + ['\t\t)']
        slots = number_value(rw.resolve(advclass, 'maximum_possible_slots'))
        if slots is not None and slots >= 0:
            block.append(f'\tmaximum_slots = {slots}')
        blocks.append(block)
    open(f'{OUT_DIR}/{ADVCLASS_FILE}', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f'{ADVCLASS_FILE}: {len(class_jobs)} subclasses for {len({job for owners in class_jobs.values() for job in owners})} roles')


def select_jobs(cfg, rw):
    jobs_cfg = cfg['jobs']
    departments = jobs_cfg['departments']
    blacklist, _, _ = map_adjustment(os.path.join(CHECKOUT, cfg['source']['map_adjustment']))
    taken = tg_job_titles()
    retitle = {p: f'"{t}"' for p, t in jobs_cfg.get('retitle', {}).items()}
    ported = []
    collisions = []
    for path in sorted(p for p in rw.types if p.startswith(JOB_ROOT + '/')):
        if path in blacklist:
            continue
        dept = (rw.resolve(path, 'department_flag') or '').strip()
        if dept not in departments:
            continue
        positions = max(number_value(rw.resolve(path, 'total_positions')) or 0, number_value(rw.resolve(path, 'spawn_positions')) or 0)
        title = retitle.get(path) or string_value(rw.resolve(path, 'title'))
        if positions <= 0 or not title:
            continue
        if title.strip('"') in taken:
            collisions.append(f'{path} {title}')
        ported.append(path)
    if collisions:
        raise SystemExit('role titles collide with TG job titles; add them to jobs.retitle in the config:\n  ' + '\n  '.join(collisions))
    return ported


def generate_jobs(cfg, rw, usage, role_outfits, valid, station_usage, role_attrs=None):
    jobs_cfg = cfg['jobs']
    departments = jobs_cfg['departments']
    blacklist, slots, retitles = map_adjustment(os.path.join(CHECKOUT, cfg['source']['map_adjustment']))
    retitle = {p: f'"{t}"' for p, t in jobs_cfg.get('retitle', {}).items()}
    taken = tg_job_titles()
    ported = select_jobs(cfg, rw)

    titles = {p: retitle.get(p) or string_value(rw.resolve(p, 'title')) for p in ported}
    seen = {}
    for p, t in titles.items():
        if t in seen:
            raise SystemExit(f'{p} and {seen[t]} share the title {t}')
        seen[t] = p
    defines = {p: define_name(t.strip('"')) for p, t in titles.items()}
    access_traits = set()
    for prefix, var in jobs_cfg.get('access_traits', {}).items():
        for used in usage:
            if boundary_match(used, prefix):
                expanded = expand_define(rw.resolve(used, var))
                if expanded and STRING_LITERAL.match(expanded):
                    access_traits.add(expanded)

    lines = [f'#define {defines[p]} {titles[p]}' for p in ported]
    open(f'{OUT_DIR}/_job_titles.dm', 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')

    blocks = []
    abstract = set()
    for p in ported:
        parts = p.split('/')
        for k in range(len(JOB_ROOT.split('/')) + 1, len(parts)):
            parent = '/'.join(parts[:k])
            if parent not in ported:
                abstract.add(parent)
    for parent in sorted(abstract):
        blocks.append([parent, f'\tabstract_type = {parent}'])
    outfits = {}
    for p in ported:
        dept = rw.resolve(p, 'department_flag').strip()
        raw_outfit = (rw.resolve(p, 'outfit') or '').strip()
        outfit = raw_outfit if raw_outfit.startswith('/datum/outfit/job/roguetown/') and raw_outfit not in outfits.values() else '/datum/outfit/job/roguetown/' + p[len(JOB_ROOT) + 1:]
        outfits[p] = outfit
        tag = 'ROCKHILL_' + re.sub(r'[^A-Z0-9]+', '_', p[len(JOB_ROOT) + 1:].upper())
        total = number_value(rw.resolve(p, 'total_positions')) or 0
        spawn = number_value(rw.resolve(p, 'spawn_positions'))
        spawn = total if spawn is None else spawn
        block = [p, f'\ttitle = {defines[p]}']
        desc = string_value(rw.resolve(p, 'tutorial'))
        if desc:
            block.append(f'\tdescription = {desc}')
        block += [f'\ttotal_positions = {total}', f'\tspawn_positions = {spawn}', f'\tconfig_tag = "{tag}"', f'\toutfit = {outfit}']
        order = number_value(rw.resolve(p, 'display_order'))
        if order is not None:
            block.append(f'\tdisplay_order = {order}')
        block += ['\tdepartments_list = list(', f"\t\t{departments[dept]},", '\t\t)']
        traits = sorted(set(expand_define(token) for token in re.findall(r'[A-Z_][A-Z0-9_]*', rw.resolve(p, 'job_traits') or '')) & access_traits)
        if traits:
            block += ['\tmind_traits = list('] + [f'\t\t{trait},' for trait in traits] + ['\t\t)']
        if role_outfits.get(p, {}).get('advclass'):
            block.append(f'\trockhill_advclass = "{role_outfits[p]["advclass"]}"')
        subclasses = role_outfits.get(p, {}).get('subclasses', [])
        if len(subclasses) > 1:
            block += ['\trockhill_advclasses = list('] + [f'\t\t{ADVCLASS_TARGET}{advclass[len(ADVCLASS_ROOT):]},' for advclass in subclasses] + ['\t\t)']
        attrs = (role_attrs or {}).get(p, {})
        if attrs.get('sheet'):
            block.append(f"\tattribute_sheet = {attrs['sheet']}")
        if attrs.get('traits'):
            block += ['\trockhill_traits = list('] + [f'\t\t{trait},' for trait in attrs['traits']] + ['\t\t)']
        alternates = []
        f_title = string_value(rw.resolve(p, 'f_title'))
        if f_title and f_title != titles[p] and f_title.strip('"') not in taken:
            alternates.append(f_title)
        for extra in retitles.get(p, []):
            quoted = f'"{extra}"'
            if quoted != titles[p] and quoted not in alternates:
                alternates.append(quoted)
        if alternates:
            block += ['\talternate_titles = list('] + [f'\t\t{a},' for a in alternates] + ['\t\t)']
        blocks.append(block)
    for p in ported:
        block = [outfits[p], f'\tname = {defines[p]}', f'\tjobtype = {p}']
        dressed = role_outfits.get(p, {'slots': {}, 'contents': []})
        for var in ('uniform', 'shirt', 'suit', 'cloak', 'head', 'mask', 'mouth', 'neck', 'gloves', 'wrists', 'ring', 'shoes', 'belt', 'back', 'backr', 'l_pocket', 'r_pocket', 'l_hand', 'r_hand'):
            item = dressed['slots'].get(var)
            if item and item in valid:
                block.append(f'\t{var} = {item}')
        contents = [(item, count) for item, count in (dressed['contents'] or []) if item in valid]
        if contents and dressed['slots'].get('back') in valid:
            block += ['\tbackpack_contents = list('] + [f'\t\t{item} = {count},' for item, count in contents] + ['\t\t)']
        blocks.append(block)
    open(f'{OUT_DIR}/jobs.dm', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')

    by_suffix = {p.rsplit('/', 1)[1]: p for p in ported}
    by_title = {}
    for p in ported:
        for var in ('title', 'f_title'):
            source_title = string_value(rw.resolve(p, var))
            if source_title:
                by_title.setdefault(source_title.strip('"'), p)
        for extra in retitles.get(p, []):
            by_title.setdefault(extra, p)
    title_map = {source: titles[p].strip('"') for source, p in by_title.items()}
    open(f'{OUT_DIR}/titles.json', 'w', encoding='utf-8', newline='\n').write(json.dumps(title_map, indent='\t', ensure_ascii=False, sort_keys=True) + '\n')
    landmark_roles = {lm: role for lm, role in jobs_cfg.get('landmark_roles', {}).items() if role in ported}
    marks = []
    matched = 0
    late = {r['prefix'] for r in cfg['replacements'] if r.get('to') == '/obj/effect/landmark/latejoin'}
    for lm in sorted(p for p in usage if p.startswith(LANDMARK_ROOT + '/')):
        if any(lm == pre or lm.startswith(pre + '/') for pre in late):
            continue
        target = LANDMARK_REBASE + lm[len(LANDMARK_ROOT):]
        source_name = (string_value(rw.resolve(lm, 'name')) or '').strip('"')
        job = by_title.get(source_name) or by_suffix.get(lm.rsplit('/', 1)[1]) or landmark_roles.get(lm)
        roles = [title_map[role.strip('"')] for role in re.findall(r'"[^"]*"', rw.resolve(lm, 'jobspawn_override') or '') if role.strip('"') in title_map]
        block = [target]
        if job:
            block.append(f'\tname = {defines[job]}')
            matched += 1
        elif lm in station_usage:
            block.append('\tname = JOB_ASSISTANT')
        if roles:
            block.append('\trockhill_latejoin_roles = list(' + ', '.join(f'"{role}"' for role in roles) + ')')
        arrivals = [name.strip('"') for name in re.findall(r'"[^"]*"', rw.resolve(lm, 'jobspawn_override') or '') if name.strip('"') in MIGRANT_SPAWNS]
        if arrivals:
            block.append('\trockhill_migrant_spawns = list(' + ', '.join(f'"{name}"' for name in arrivals) + ')')
        marks.append(block)
    open(f'{OUT_DIR}/landmarks.dm', 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in marks) + '\n')

    map_json_path = 'modular_redtard/rockhill/rockhill.json'
    map_json = json.load(open(map_json_path, encoding='utf-8'))
    changes = {}
    for p, n in sorted(slots.items()):
        if p in titles:
            changes[titles[p].strip('"')] = {'total_positions': n, 'spawn_positions': n}
    map_json['job_changes'] = changes
    open(map_json_path, 'w', encoding='utf-8', newline='\n').write(json.dumps(map_json, indent='\t') + '\n')

    with open(REPORT, 'a', encoding='utf-8', newline='\n') as out:
        out.write(f'\n## Jobs ({len(ported)} roles, {matched} of {len(marks)} start landmarks bound to a role)\n\n| Role | Title | Department |\n|---|---|---|\n')
        for p in ported:
            out.write(f"| `{p}` | {titles[p].strip(chr(34))} | {departments[rw.resolve(p, 'department_flag').strip()]} |\n")
    print(f'jobs: {len(ported)} roles, {len(abstract)} abstract parents, landmarks {matched}/{len(marks)} bound, job_changes {len(changes)}')
    return set(outfits.values())


NPC_STAT_BASE = 10
LOCAL_VAR = re.compile(r'^\t*var/(?:list/)?(\w+) = ')
LOCAL_VALUE = re.compile(r'-?\d+(?:\.\d+)?|rand\(\s*-?\d+\s*,\s*-?\d+\s*\)|pick\(\s*(?:-?\d+|"[^"]*")(?:\s*,\s*(?:-?\d+|"[^"]*"))*\s*\)')
SUPER_CALL = re.compile(r'(?:\.\s*=\s*)?\.\.\(\)')


def code_lines(body):
    """A proc body's lines, a statement split over lines (an open parenthesis, a trailing backslash) joined into one."""
    out = []
    i = 0
    while i < len(body):
        line = body[i].rstrip()
        i += 1
        if not line.strip():
            continue
        while (line.count('(') > line.count(')') or line.endswith('\\')) and i < len(body):
            line = line.rstrip('\\').rstrip() + ' ' + body[i].strip()
            i += 1
        out.append(line)
    return out


def code_tree(body):
    """A proc body as [text, children] nodes by indentation."""
    root = []
    stack = [(-1, root)]
    for line in code_lines(body):
        lead = line[:len(line) - len(line.lstrip())]
        indent = lead.count('\t') + lead.count(' ') // 4
        while stack[-1][0] >= indent:
            stack.pop()
        node = [line.strip(), []]
        stack[-1][1].append(node)
        stack.append((indent, node[1]))
    return root


def split_condition(text):
    """'(condition) rest' as (condition, rest) with the parentheses balanced; None without a leading parenthesis."""
    text = text.strip()
    if not text.startswith('('):
        return None
    depth = 0
    quoted = False
    for index, char in enumerate(text):
        if char == '"' and text[index - 1:index] != '\\':
            quoted = not quoted
        if quoted:
            continue
        if char == '(':
            depth += 1
        elif char == ')':
            depth -= 1
            if depth == 0:
                return text[1:index].strip(), text[index + 1:].strip()
    return None


def control_parts(text):
    """(keyword, condition, statement on the same line) of a control line; (None, None, text) for a statement."""
    m = re.match(r'^(else\s+if|if|switch|for|while)\s*(\(.*)$', text)
    if m:
        keyword = 'else if' if m.group(1).startswith('else') else m.group(1)
        split = split_condition(m.group(2))
        return (keyword, split[0], split[1]) if split else (keyword, m.group(2), '')
    if re.match(r'^else\b', text):
        return 'else', None, text[4:].strip()
    if re.match(r'^do\b', text):
        return 'do', None, ''
    return None, None, text


def branch_body(tail, children):
    return ([[tail, []]] if tail else []) + children


def if_chain(nodes, i, first):
    """The branches of an if chain starting at nodes[i - 1] (whose parts are first), and the index after it."""
    keyword, cond, tail = first
    branches = [(keyword, cond, branch_body(tail, nodes[i - 1][1]))]
    while i < len(nodes) and control_parts(nodes[i][0])[0] in ('else if', 'else'):
        keyword, cond, tail = control_parts(nodes[i][0])
        branches.append((keyword, cond, branch_body(tail, nodes[i][1])))
        i += 1
    return branches, i


def npc_condition(cond, scope):
    """How an NPC outfit takes a branch: 'prob' for a chance kept as it is, True or False for one decided now. An NPC has no
    mind and is dressed as a man; whatever else the port cannot know (species, map, patron) takes the else branch."""
    c = (cond or '').strip()
    m = re.fullmatch(r'prob\(\s*([\w.]+)\s*\)', c)
    if m and (NUMBER.match(m.group(1)) or scope.get(m.group(1)) == 'value'):
        return 'prob'
    if re.fullmatch(r'!\s*\(?\s*H\.mind\s*\)?', c):
        return True
    if 'H.mind' in c:
        return False
    return masculine(c) and not feminine(c)


def static_statements(nodes):
    """The statements an NPC outfit surely runs: the unconditional ones and the branches decided now. A chance and a
    random switch are skipped, so a stat set in only one loadout is not counted."""
    out = []
    i = 0
    while i < len(nodes):
        parts = control_parts(nodes[i][0])
        i += 1
        if parts[0] == 'if':
            branches, i = if_chain(nodes, i, parts)
            for keyword, cond, kids in branches:
                verdict = True if keyword == 'else' else npc_condition(cond, {})
                if verdict == 'prob':
                    break
                if verdict:
                    out += static_statements(kids)
                    break
        elif parts[0] is None:
            out.append(parts[2])
    return out


def useful_lines(lines):
    return any(not LOCAL_VAR.match(line) for line in lines)


def prune_locals(lines):
    """Drops local variables nothing left in the proc reads (their switch or chance went with the items it chose)."""
    while True:
        unused = next((index for index, line in enumerate(lines) if LOCAL_VAR.match(line) and not any(re.search(rf'\b{LOCAL_VAR.match(line).group(1)}\b', other) for k, other in enumerate(lines) if k != index)), None)
        if unused is None:
            return lines
        lines = lines[:unused] + lines[unused + 1:]


class NpcOutfits:
    """Ratwood NPC outfits as TG outfits: the slots they set on the type, and pre_equip (with the helper procs it calls)
    rewritten to keep only what dresses the NPC: slot assignments, the chances and random switches that choose between
    loadouts, and the local numbers and lists they pick from. Items the port does not have are left out; without valid,
    every item is kept and only gathered (the first pass, before the items are ported)."""

    def __init__(self, rw, rules, valid=None):
        self.rw = rw
        self.rules = rules
        self.valid = valid
        self.items = set()
        self.helpers = {}

    def item(self, raw):
        path = raw.strip().rstrip('/')
        self.items.add(path)
        target = runtime_path(path, self.rules)
        if target and (self.valid is None or target in self.valid):
            return target
        return None

    def slot_value(self, value, scope):
        value = value.strip()
        if value == 'null':
            return 'null'
        if ITEM_PATH.fullmatch(value.rstrip('/')):
            return self.item(value)
        m = re.fullmatch(r'(pick|pick_n_take)\((.*)\)', value)
        if m:
            inner = m.group(2).strip()
            if scope.get(inner) == 'list':
                return f'{m.group(1)}({inner})'
            kept = [p for p in (self.item(p) for p in ITEM_PATH.findall(inner)) if p]
            return f"pick({', '.join(kept)})" if kept else None
        return value if scope.get(value) == 'path' else None

    def statics(self, outfit):
        lines = []
        for var, value in self.rw.types.get(outfit, {}).items():
            if var == 'name' and STRING_LITERAL.match(value.strip()):
                lines.append(f'\tname = {value.strip()}')
            elif var in OUTFIT_SLOTS or var in NPC_SLOTS:
                target = self.slot_value(value, {})
                if target:
                    lines.append(f'\t{NPC_SLOTS.get(var) or OUTFIT_SLOTS[var]} = {target}')
            elif var == 'backpack_contents':
                entries = [(self.item(p), n or '1') for p, n in re.findall(r'(/obj/item/[A-Za-z0-9_/]*[A-Za-z0-9_])/?\s*(?:=\s*(\d+))?', value)]
                entries = [f'{p} = {n}' for p, n in entries if p]
                if entries:
                    lines.append(f"\tbackpack_contents = list({', '.join(entries)})")
        return lines

    def statement(self, text, depth, scope, outfit):
        pad = '\t' * depth
        if SUPER_CALL.fullmatch(text):
            return [pad + '..()']
        if text == 'return':
            return [pad + 'return']
        m = re.fullmatch(r'var/(?:list/)?(\w+)\s*=\s*(.+)', text)
        if m:
            name, value = m.group(1), m.group(2).strip()
            if LOCAL_VALUE.fullmatch(value):
                scope[name] = 'value'
                return [pad + f'var/{name} = {value}']
            kept = [p for p in (self.item(p) for p in ITEM_PATH.findall(value)) if p]
            if kept and value.startswith('list('):
                scope[name] = 'list'
                return [pad + f"var/list/{name} = list({', '.join(kept)})"]
            if kept and value.startswith('pick('):
                scope[name] = 'path'
                return [pad + f"var/{name} = pick({', '.join(kept)})"]
            return []
        m = re.fullmatch(r'(\w+)\s*=\s*(.+)', text)
        if m and (m.group(1) in OUTFIT_SLOTS or m.group(1) in NPC_SLOTS):
            value = self.slot_value(m.group(2), scope)
            return [pad + f'{NPC_SLOTS.get(m.group(1)) or OUTFIT_SLOTS[m.group(1)]} = {value}'] if value else []
        m = re.fullmatch(r'backpack_contents\s*(=|\+=)\s*list\((.*)\)', text)
        if m:
            entries = [(self.item(p), n or '1') for p, n in re.findall(r'(/obj/item/[A-Za-z0-9_/]*[A-Za-z0-9_])/?\s*(?:=\s*(\d+))?', m.group(2))]
            entries = [f'{p} = {n}' for p, n in entries if p]
            return [pad + f"backpack_contents {m.group(1)} list({', '.join(entries)})"] if entries else []
        m = re.fullmatch(r'(\w+)\(\s*(?:H|human|user)\s*\)', text)
        if m and self.helper(outfit, m.group(1)):
            return [pad + f'{m.group(1)}(H)']
        return []

    def emit(self, nodes, depth, scope, outfit):
        out = []
        i = 0
        while i < len(nodes):
            parts = control_parts(nodes[i][0])
            children = nodes[i][1]
            i += 1
            if parts[0] == 'if':
                branches, i = if_chain(nodes, i, parts)
                out += self.chain(branches, depth, scope, outfit)
            elif parts[0] == 'switch':
                out += self.switch(parts[1], branch_body(parts[2], children), depth, scope, outfit)
            elif parts[0] is None:
                out += self.statement(parts[2], depth, scope, outfit)
        return out

    def chain(self, branches, depth, scope, outfit):
        """An if chain: chances stay as they are, a branch decided now is taken whole (or becomes the else of the chances
        before it), a branch decided against is dropped."""
        pad = '\t' * depth
        out = []
        useful = False
        for keyword, cond, kids in branches:
            verdict = True if keyword == 'else' else npc_condition(cond, scope)
            if verdict == 'prob':
                body = self.emit(kids, depth + 1, dict(scope), outfit)
                useful = useful or useful_lines(body)
                out.append(pad + ('else if' if out else 'if') + f'({cond.strip()})')
                out += body if useful_lines(body) else [pad + '\tEMPTY_BLOCK_GUARD']
            elif verdict:
                if not out:
                    return self.emit(kids, depth, scope, outfit)
                body = self.emit(kids, depth + 1, dict(scope), outfit)
                useful = useful or useful_lines(body)
                out += [pad + 'else'] + (body if useful_lines(body) else [pad + '\tEMPTY_BLOCK_GUARD'])
                break
        return out if useful else []

    def switch(self, expr, cases, depth, scope, outfit):
        """A switch on a random number keeps its cases; a switch on anything else takes its first case."""
        pad = '\t' * depth
        expr = (expr or '').strip()
        parsed = []
        for text, children in cases:
            keyword, cond, tail = control_parts(text)
            if keyword in ('if', 'else'):
                parsed.append((cond if keyword == 'if' else None, branch_body(tail, children)))
        if not parsed:
            return []
        if not (re.fullmatch(r'rand\(\s*-?\d+\s*,\s*-?\d+\s*\)', expr) or LOCAL_VALUE.fullmatch(expr) or scope.get(expr) == 'value'):
            return self.emit(parsed[0][1], depth, scope, outfit)
        out = [pad + f'switch({expr})']
        useful = False
        for cond, kids in parsed:
            body = self.emit(kids, depth + 2, dict(scope), outfit)
            useful = useful or useful_lines(body)
            out.append(pad + '\t' + (f'if({cond.strip()})' if cond is not None else 'else'))
            out += body if useful_lines(body) else [pad + '\t\tEMPTY_BLOCK_GUARD']
        return out if useful else []

    def helper(self, outfit, name):
        """A helper proc the outfit calls (Ratwood's add_random_deserter_weapon), written once for the outfit that owns it."""
        owner = outfit
        while owner and owner.startswith(NPC_OUTFIT_ROOT + '/'):
            key = (owner, name)
            if key in OUTFIT_PROCS:
                if key not in self.helpers:
                    self.helpers[key] = []
                    lines = prune_locals(self.emit(code_tree(OUTFIT_PROCS[key]), 1, {}, owner))
                    self.helpers[key] = lines if useful_lines(lines) else []
                return self.helpers[key]
            owner = self.rw.parent(owner)
        return []

    def pre_equip(self, outfit):
        body = PRE_EQUIP.get(outfit)
        return None if body is None else prune_locals(self.emit(code_tree(body), 1, {}, outfit))


def npc_chain(rw, path):
    chain = []
    while path and boundary_match(path, NPC_ROOT):
        chain.append(path)
        path = rw.parent(path)
    return chain


def npc_outfits(rw, path):
    """The Ratwood outfits an NPC wears, nearest code first: an outfit var its Initialize sets (several, as the spread
    skeletons pick one at random), an outfit after_creation equips by path, or the outfit var after_creation equips."""
    for owner in npc_chain(rw, path):
        for proc in NPC_PROCS:
            text = '\n'.join(HUMAN_PROCS.get((owner, proc), []))
            assigned = re.findall(r'\b\w+_outfit\s*=\s*(/datum/outfit/[A-Za-z0-9_/]*[A-Za-z0-9_])', text)
            if assigned:
                return [o for o in assigned if o.startswith(NPC_OUTFIT_ROOT + '/')]
            direct = re.search(r'equipOutfit\(\s*new\s+(/datum/outfit/[A-Za-z0-9_/]*[A-Za-z0-9_])', text)
            if direct:
                return [direct.group(1)] if direct.group(1).startswith(NPC_OUTFIT_ROOT + '/') else []
            named = re.search(r'\bnew\s+(\w+_outfit)\b', text)
            if named:
                value = (rw.resolve(path, named.group(1)) or '').strip().rstrip('/')
                return [value] if value.startswith(NPC_OUTFIT_ROOT + '/') else []
    return []


def npc_outfit_chain(outfit):
    parts = outfit.split('/')
    return ['/'.join(parts[:k]) for k in range(len(NPC_OUTFIT_ROOT.split('/')) + 1, len(parts) + 1)]


def npc_faction(rw, path):
    """Ratwood's faction of the NPC: the faction var, or the list after_creation sets when it sets it on the type or nearer
    to it than the var, with what after_creation adds (faction |= list("undead"))."""
    var_depth = None
    depth = 0
    p = path
    while p:
        if 'faction' in rw.types.get(p, {}):
            var_depth = depth
            break
        p = rw.parent(p)
        depth += 1
    faction = string_list(rw.resolve(path, 'faction'))
    added = []
    assigned = False
    for depth, owner in enumerate(npc_chain(rw, path)):
        text = '\n'.join(line for proc in NPC_PROCS for line in HUMAN_PROCS.get((owner, proc), []))
        found = re.search(r'\bfaction\s*=\s*list\(([^)]*)\)', text)
        if found and not assigned:
            assigned = True
            if var_depth is None or depth <= var_depth:
                faction = string_list(found.group(1))
        for listed, single in re.findall(r'\bfaction\s*(?:\|=|\+=)\s*(?:list\(([^)]*)\)|("[^"]*"))', text):
            added += string_list(listed or single)
    return list(dict.fromkeys(faction + added))


def npc_traits(rw, path):
    """Traits after_creation and Initialize give the NPC outside any condition."""
    traits = []
    for owner in npc_chain(rw, path):
        for proc in NPC_PROCS:
            for text in unconditional_lines(HUMAN_PROCS.get((owner, proc), [])):
                traits += re.findall(r'\bADD_TRAIT\(\s*src\s*,\s*(TRAIT_[A-Z0-9_]+)\s*,', text)
    return traits


def npc_outfit_attributes(rw, outfit, attr_cfg):
    """Stats, skills and traits a Ratwood NPC outfit gives in what its pre_equip surely runs (H.STASTR = 8, change_stat,
    adjust_skillrank, ADD_TRAIT), over its parent's when it calls ..(). A stat set outright counts from Ratwood's 10."""
    data = {'set': {}, 'add': collections.Counter(), 'skills': {}, 'traits': []}
    if not outfit or not outfit.startswith(NPC_OUTFIT_ROOT + '/'):
        return data
    body = PRE_EQUIP.get(outfit)
    if body is None:
        return npc_outfit_attributes(rw, rw.parent(outfit), attr_cfg)
    lines = static_statements(code_tree(body))
    if any(SUPER_CALL.fullmatch(text) for text in lines):
        data = npc_outfit_attributes(rw, rw.parent(outfit), attr_cfg)
    for text in lines:
        for short, op, amount in STAT_ASSIGN.findall(text):
            stat = attr_cfg['stats'].get(NPC_STATS.get(short, ''))
            if not stat:
                continue
            if op == '=':
                data['set'][stat] = int(amount)
                data['add'][stat] = 0
            else:
                data['add'][stat] += int(amount) if op == '+=' else -int(amount)
        for token, amount in STAT_CALL.findall(text):
            stat = attr_cfg['stats'].get(expand_define(token).strip('"'))
            if stat:
                data['add'][stat] += int(amount)
        for call, path, token in SKILL_CALL.findall(text):
            value = expand_define(token)
            if not NUMBER.match(value):
                continue
            level = int(float(value)) * attr_cfg['level_scale']
            data['skills'][path] = data['skills'].get(path, 0) + level if call == 'adjust_skillrank' else max(data['skills'].get(path, 0), level)
        data['traits'] += TRAIT_CALL.findall(text)
    return data


def npc_sheet_entries(data, attr_cfg):
    entries = []
    for stat in sorted(set(data['set']) | set(data['add'])):
        amount = (data['set'][stat] - NPC_STAT_BASE if stat in data['set'] else 0) + data['add'][stat]
        if amount:
            entries.append(f'\t\t{stat} = {amount},')
    for path, value in sorted(data['skills'].items()):
        if path in attr_cfg['meta'] and value:
            entries.append(f"\t\t{attr_cfg['skill_target'] + path[len(attr_cfg['skill_root']):]} = {min(value, 60)},")
    return entries


def npc_candidates(rw, rules, usage):
    return sorted(p for p in usage if boundary_match(p, NPC_ROOT) and p != NPC_ROOT and not replacement_for(p, rules))


def npc_outfit_items(rw, rules, npcs):
    """Every item the NPC outfits may hand out, so the port brings them over."""
    writer = NpcOutfits(rw, rules)
    for path in npcs:
        for outfit in npc_outfits(rw, path):
            for link in npc_outfit_chain(outfit):
                writer.statics(link)
                writer.pre_equip(link)
    return writer.items


def npc_trait_names(rw, npcs, attr_cfg):
    traits = set()
    for path in npcs:
        traits |= set(npc_traits(rw, path))
        for outfit in npc_outfits(rw, path):
            for link in npc_outfit_chain(outfit):
                traits |= set(npc_outfit_attributes(rw, link, attr_cfg)['traits'])
    return traits


HAIR_ROOT = '/datum/sprite_accessory/hair'
HAIR_TYPES = re.compile(r'/datum/sprite_accessory/hair/(?:head|facial)/\w+')
COLOR_HEX = re.compile(r'"#?([0-9A-Fa-f]{6})"')


def npc_creation_text(rw, path):
    return '\n'.join(line for owner in npc_chain(rw, path) for proc in NPC_PROCS for line in HUMAN_PROCS.get((owner, proc), []))


def npc_look(rw, path, hair_names):
    """How Ratwood's after_creation dresses the NPC's body: a random sex, skin, eye and hair colours, the hairstyles and
    beards it picks from, and the name lists (by the file's m/f ending) or the one name it gives (a goblin is "goblin")."""
    text = npc_creation_text(rw, path)
    look = {}
    if re.search(r'\bgender\s*=\s*pick\(\s*MALE\s*,\s*FEMALE\s*\)', text):
        look['random_sex'] = 'TRUE'
    for key, pattern in (('skin', r'\bskin_tone\s*=\s*'), ('eyes', r'\beye_color\s*=\s*'), ('hair_color', r'\bhair_color\s*=\s*')):
        found = re.search(pattern + COLOR_HEX.pattern, text)
        if found:
            look[key] = f'"#{found.group(1).upper()}"'
    for key, name in (('hair_m', 'hairm'), ('hair_f', 'hairf'), ('beards', 'beard')):
        found = re.search(rf'\bvar/{name}\s*=\s*pick\(\s*list\(([^)]*)\)', text)
        styles = [hair_names[p] for p in HAIR_TYPES.findall(found.group(1)) if p in hair_names] if found else []
        if styles:
            look[key] = 'list(' + ', '.join(json.dumps(s) for s in styles) + ')'
    for rel in dict.fromkeys(re.findall(r'\breal_name\s*=\s*pick\(\s*world\.file2list\(\s*"([^"]+)"', text)):
        key = 'names_f' if rel.endswith('f.txt') else 'names_m'
        look[key] = f'"{NPC_NAMES_DIR}/{os.path.basename(rel)}"'
    fixed = re.search(r'\breal_name\s*=\s*"([^"\[\]]+)"', text)
    if fixed and 'names_m' not in look and 'names_f' not in look:
        look['name'] = json.dumps(fixed.group(1))
    return look


NPC_NAMES_DIR = 'modular_redtard/rockhill/strings/names'


def npc_name_files(rw, npcs):
    files = set()
    for path in npcs:
        files |= set(re.findall(r'\breal_name\s*=\s*pick\(\s*world\.file2list\(\s*"([^"]+)"', npc_creation_text(rw, path)))
    return sorted(files)


def npc_hair_types(rw, npcs):
    return sorted({p for path in npcs for p in HAIR_TYPES.findall(npc_creation_text(rw, path)) if p in rw.types})


def ratwood_offsets(rw, species, keys):
    """Ratwood's offset_features of a species (where worn things, hair and held items sit on its body) in the module's
    offset keys, per sex: {"m": {key: (x, y)}, "f": {...}}."""
    out = {'m': {}, 'f': {}}
    for name, x, y in re.findall(r'\b(OFFSET_[A-Z_]+)\s*=\s*list\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)', rw.resolve(species, 'offset_features') or ''):
        sex = 'f' if name.endswith('_F') else 'm'
        for key in keys.get(name[:-2] if sex == 'f' else name, []):
            if int(x) or int(y):
                out[sex][key] = (int(x), int(y))
    return out


def over(base, top):
    """top drawn over base, one 32x32 RGBA cell each (a pixel of top wins where it is not transparent)."""
    out = bytearray(base)
    for i in range(0, len(top), 4):
        if top[i + 3]:
            out[i:i + 4] = top[i:i + 4]
    return bytes(out)


def generate_bodies(cfg, rw, valid, npcs, known_traits):
    """Ratwood bodies as TG body parts (rockhill/species.dm): the per-zone body sheets of the orc and the dark elf for both
    sexes (TG's dimorphic state <body>_<zone>_<m|f>, each leg with its "_above" part drawn over it), the goblins'
    whole-body sprites (rogue_goblin_<zone>: the body on the chest, the other parts empty; per kind <kind>_chest,
    <kind>_decap_chest and the severed head <kind>_severed) with their own armor and helmet looks (goblin_worn_<state>),
    ears and tusks (<feature>_ADJ/_FRONT) and the hairstyles Ratwood's NPCs pick
    (rogue_hair_<style>, rogue_facial_<style>), all in one sheet; and the data that goes with them: Ratwood's
    offset_features per species, the hairstyles as TG sprite accessories and the goblin look of goblin gear."""
    spec = cfg['port']['bodies']
    sources = {}

    def cells_of(rel):
        if rel not in sources:
            if not asset_allowed(rel):
                raise SystemExit(f'{rel}: the body sprites sit in a folder the port does not take ({excluded_folder(rel)})')
            sources[rel] = dmi.read(os.path.join(CHECKOUT, rel)).state_cells()
        return sources[rel]

    def first_frame(entry):
        dirs, _, cells = entry
        return dirs, cells[:dirs]

    empty = bytes(32 * 32 * 4)
    states = []
    for body, entry in spec['sheets'].items():
        for sex in ('m', 'f'):
            source = cells_of(entry[sex])
            for zone in spec['zones']:
                dirs, cells = first_frame(source[zone]) if zone in source else (1, [empty])
                above = spec['merge'].get(zone)
                if above in source:
                    above_dirs, above_cells = first_frame(source[above])
                    if above_dirs == dirs:
                        cells = [over(cell, top) for cell, top in zip(cells, above_cells)]
                states.append((f'{body}_{zone}_{sex}', dirs, cells))
    goblin = spec['goblin']
    source = cells_of(goblin['source'])
    for zone in spec['zones']:
        states.append((f"{goblin['limb_id']}_{zone}", *(first_frame(source[goblin['kinds'][0]]) if zone == 'chest' else (1, [empty]))))
    for kind in goblin['kinds']:
        states.append((f'{kind}_chest', *first_frame(source[kind])))
        states.append((f'{kind}_decap_chest', *first_frame(source[f'{kind}_decap'])))
        states.append((f'{kind}_severed', 1, source[f'{kind}_head'][2][:1]))
    for state in goblin['worn']:
        states.append((f'goblin_worn_{state}', *first_frame(source[state])))
    for name, (rel, state, layers) in spec['features'].items():
        source = cells_of(rel)
        for layer in layers:
            states.append((f'{name}_{layer}', *first_frame(source[f'{state}_{layer}'])))
    hair_names = {}
    hair_blocks = []
    tg_hair_names = set(re.findall(r'^\tname = "([^"]+)"', '\n'.join(open(f, encoding='utf-8', errors='ignore').read() for f in glob.glob('code/datums/sprite_accessories/*.dm')), re.M))
    for path in npc_hair_types(rw, npcs):
        facial = '/facial/' in path
        leaf = path.rsplit('/', 1)[1]
        icon = (rw.resolve(path, 'icon') or '').strip().strip("'")
        state = (string_value(rw.resolve(path, 'icon_state')) or '""').strip('"')
        name = (string_value(rw.resolve(path, 'name')) or f'"{leaf}"').strip('"')
        source = cells_of(icon) if icon else {}
        if state not in source:
            continue
        sheet_state = f"rogue_{'facial' if facial else 'hair'}_{leaf}"
        states.append((sheet_state, *first_frame(source[state])))
        shown = name if name not in tg_hair_names else f'{name} (Ratwood)'
        hair_names[path] = shown
        hair_blocks.append([f"/datum/sprite_accessory/{'facial_hair' if facial else 'hair'}/rogue_{leaf}", f'\tname = {json.dumps(shown)}', f"\ticon = '{spec['file']}'", f'\ticon_state = "{sheet_state}"', '\tlocked = TRUE', '\tnatural_spawn = FALSE'])
    dmi.write_states(spec['file'], 32, 32, states)

    blocks = []
    race_sheets = []
    attr_cfg = cfg['attributes']
    for species, target in spec['species_map'].items():
        block = [target]
        offsets = ratwood_offsets(rw, species, spec['offset_keys'])
        lines = []
        for sex in ('m', 'f'):
            entries = [f'{key} = list({x}, {y})' for key, (x, y) in sorted(offsets[sex].items())]
            if entries:
                lines.append(f'\t\t"{sex}" = list(' + ', '.join(entries) + '),')
        if lines:
            block += ['\trogue_offsets = list('] + lines + ['\t\t)']
        bonus = collections.Counter()
        for token, amount in re.findall(r'\b(STAT_[A-Z]+)\s*=\s*(-?\d+)', rw.resolve(species, 'race_bonus') or ''):
            stat = attr_cfg['stats'].get(expand_define(token).strip('"'))
            if stat:
                bonus[stat] += int(amount)
        if any(bonus.values()):
            sheet = spec['race_sheet_root'] + target[len('/datum/species'):]
            race_sheets.append([sheet, '\traw_attribute_list = list('] + [f'\t\t{stat} = {amount},' for stat, amount in sorted(bonus.items()) if amount] + ['\t\t)'])
            block.append(f'\trogue_race_sheet = {sheet}')
        traits = [t for t in dict.fromkeys(re.findall(r'TRAIT_[A-Z0-9_]+', rw.resolve(species, 'inherent_traits') or '')) if t in known_traits]
        if traits:
            block.append(f"\trogue_race_traits = list({', '.join(traits)})")
        for var, sex in (('use_f', 'f'), ('use_m', 'm')):
            if (rw.resolve(species, var) or '').strip() in ('1', 'TRUE'):
                block.append(f'\trogue_worn_sex = "{sex}"')
        tones = skin_tones(rw, species)
        if tones:
            block.append('\trogue_skin_tones = list(' + ', '.join(f'{name} = "#{colour}"' for name, colour in tones) + ')')
            wording = string_value(rw.resolve(species, 'skin_tone_wording'))
            if wording and wording != '""':
                block.append(f'\trogue_skin_wording = {wording}')
        clothes_id = string_value(rw.resolve(species, 'clothes_id'))
        if (rw.resolve(species, 'custom_clothes') or '').strip() in ('1', 'TRUE') and clothes_id and clothes_id != '""':
            block.append(f'\trogue_clothes_id = {clothes_id}')
        desc = string_value(rw.resolve(species, 'desc'))
        if desc:
            paragraphs = [re.sub(r'<[^>]+>', '', part).strip() for part in re.split(r'<br\s*/?>', desc[1:-1])]
            paragraphs = [p for p in paragraphs if p]
            if len(paragraphs) > 1:
                paragraphs = paragraphs[1:]
            block.append(f'\trogue_description = "{" ".join(paragraphs)}"')
            block += ['\trogue_lore = list('] + [f'\t\t"{p}",' for p in paragraphs] + ['\t\t)']
        if len(block) > 1:
            blocks.append(block)
    blocks += race_sheets
    for path in sorted(p for p in valid if p.startswith('/obj/item/') and p in rw.types):
        state = (string_value(rw.resolve(path, 'item_state')) or '""').strip('"')
        if state in goblin['worn']:
            blocks.append([path, f'\trogue_goblin_state = "goblin_worn_{state}"'])
    open(f"{OUT_DIR}/{spec['dm_file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks + hair_blocks) + '\n')
    files = npc_name_files(rw, npcs)
    fetch_sources(files)
    os.makedirs(NPC_NAMES_DIR, exist_ok=True)
    for rel in files:
        if os.path.exists(os.path.join(CHECKOUT, rel)):
            shutil.copyfile(os.path.join(CHECKOUT, rel), os.path.join(NPC_NAMES_DIR, os.path.basename(rel)))
    print(f"{spec['file']}: {len(states)} states; {spec['dm_file']}: {len(blocks)} offset and gear blocks, {len(hair_blocks)} hairstyles; {len(files)} name lists")
    return hair_names


def skin_tones(rw, species):
    """Ratwood's get_skin_list() of a race, its own or its parent's: the clans, origins or tones the player picks the skin
    from, as (quoted name, hex colour) pairs."""
    p = species
    while p and p not in SKIN_LISTS:
        p = rw.parent(p)
    tones = []
    for name, token in re.findall(r'("[^"]*")\s*=\s*([A-Za-z0-9_"#]+)', '\n'.join(SKIN_LISTS.get(p, []))):
        colour = expand_define(token).strip('"').lstrip('#')
        if re.fullmatch(r'[0-9A-Fa-f]{6}', colour):
            tones.append((name, colour.upper()))
    return tones


def proc_body(owner, name):
    """The body of a Ratwood proc the parser does not keep, read from its file: the indented lines after its header."""
    header = re.compile(rf'^{re.escape(owner)}/(?:proc/)?{re.escape(name)}\(')
    for path in included_files(CHECKOUT):
        if not os.path.exists(path):
            continue
        lines = strip_comments(open(path, encoding='utf-8', errors='ignore').read()).split('\n')
        for i, line in enumerate(lines):
            if header.match(line):
                body = []
                for rest in lines[i + 1:]:
                    if rest.strip() and not rest.startswith(('\t', ' ')):
                        break
                    body.append(rest.rstrip())
                return body
    return []


def voicepack_sounds(pack):
    """Ratwood's voicepack as {sound key: [sound files]}: the race's own sounds of its get_sound(), without the generic
    pack it falls back to (TG's humans keep TG's voices) and without the old, young and silenced variants."""
    sounds = {}
    key = None
    for line in proc_body(pack, 'get_sound'):
        found = re.match(r'^\s*if\s*\(\s*"([^"]+)"\s*\)', line)
        if found:
            key = found.group(1)
            continue
        files = SOUND_LITERAL.findall(line)
        if key and files:
            sounds.setdefault(key, []).extend(files)
    return sounds


def tg_emote_keys():
    keys = set()
    for path in glob.glob('code/**/*.dm', recursive=True):
        current = None
        for line in open(path, encoding='utf-8', errors='ignore'):
            if not line.startswith(('\t', ' ')):
                current = line.strip()
                continue
            found = re.match(r'^\tkey = "([^"]+)"', line)
            if found and current and current.startswith('/datum/emote'):
                keys.add(found.group(1))
    return keys


def ratwood_emote(rw, key):
    for path, values in rw.types.items():
        if path.startswith('/datum/emote/') and values.get('key', '').strip() == f'"{key}"':
            return path
    return None


def alpha_cutoff(raw):
    """Ratwood's lighting plane alpha (255 sees nothing in the dark, 0 everything) as TG's lighting cutoff in percent."""
    try:
        alpha = define_number(expand_define(raw), DEFINE_VALUES)
    except ValueError:
        return None
    return round((255 - alpha) * 100 / 255)


def generate_races(cfg, rw):
    """Ratwood's races as TG speaks, voices and sees them (ported/races.dm): their languages as TG languages and the
    species' language holders, their voicepacks as tongues with TG's emote_sounds by sex (the sound files copied, the
    emotes TG lacks ported as voice emotes), and their eyes as TG eyes with Ratwood's sight in the dark."""
    spec = cfg['port']['races']
    bodies = cfg['port']['bodies']
    blocks = []
    lang_icons = []

    def module_language(rw_type):
        target = spec['languages'].get(rw_type)
        return target if isinstance(target, str) else (target or {}).get('type')

    for rw_type, target in spec['languages'].items():
        if isinstance(target, str):
            continue
        old_key = (string_value(rw.resolve(rw_type, 'key')) or '""').strip('"')
        block = [target['type']]
        for var in ('name', 'desc'):
            value = string_value(rw.resolve(rw_type, var))
            if value:
                if var == 'desc' and old_key:
                    value = value.replace(f',{old_key})', f",{target['key']})")
                block.append(f'\t{var} = {value}')
        block.append(f'\tkey = "{target["key"]}"')
        for var in ('space_chance', 'default_priority'):
            value = number_value(rw.resolve(rw_type, var))
            if value is not None:
                block.append(f'\t{var} = {value}')
        syllables = re.findall(r'"((?:[^"\\]|\\.)*)"', rw.resolve(rw_type, 'syllables') or '')
        if syllables:
            block.append('\tsyllables = list(' + ', '.join(json.dumps(s, ensure_ascii=False) for s in syllables) + ')')
        state = (string_value(rw.resolve(rw_type, 'icon_state')) or '""').strip('"')
        if state:
            lang_icons.append((state, target['type']))
            block += [f"\ticon = '{spec['language_icon']}'", f'\ticon_state = "{state}"']
        blocks.append(block)
    if lang_icons:
        source = dmi.read(os.path.join(CHECKOUT, spec['language_icon_source']))
        cells = source.state_cells()
        dmi.write_states(spec['language_icon'], source.frame_width, source.frame_height, [(state, 1, cells[state][2][:1]) for state, _ in lang_icons if state in cells])

    tg_keys = tg_emote_keys()
    sound_files_used = set()
    vocal_keys = set()
    eyes_used = {}
    species_lines = collections.defaultdict(list)
    seen = {}
    def configured(table, species):
        # A setting for a Ratwood species holds for its subtypes too, as the species' own vars would.
        p = species
        while p:
            if p in table:
                return table[p]
            p = rw.parent(p)
        return None

    for species, target in bodies['species_map'].items():
        leaf = target[len('/datum/species/'):].replace('/', '_')
        languages = configured(spec['species_languages'], species) or re.findall(r'/datum/language/[A-Za-z0-9_/]+', rw.resolve(species, 'languages') or '')
        languages = [module_language(lang) for lang in languages if module_language(lang)]
        packs = configured(spec['species_voices'], species) or {sex: (rw.resolve(species, f'soundpack_{sex}') or '').strip() for sex in ('m', 'f')}
        voices = {}
        for sex, pack in packs.items():
            if not pack.startswith('/datum/voicepack') or pack in spec['generic_voicepacks']:
                continue
            for key, files in voicepack_sounds(pack).items():
                key = spec['emote_keys'].get(key, key)
                files = [f for f in dict.fromkeys(files) if asset_allowed(f)]
                if files:
                    voices.setdefault(key, {})['MALE' if sex == 'm' else 'FEMALE'] = files
        eyes = re.search(r'ORGAN_SLOT_EYES\s*=\s*(/obj/item/organ/eyes[A-Za-z0-9_/]*)', rw.resolve(species, 'organs') or '')
        eyes = spec['eyes'].get(eyes.group(1)) if eyes else None
        signature = json.dumps([languages, voices, eyes], sort_keys=True)
        parent = target.rsplit('/', 1)[0]
        seen[target] = signature
        if seen.get(parent) == signature:
            continue
        if languages:
            holder = f'/datum/language_holder/{leaf}'
            entries = ', '.join(f'{lang} = list(LANGUAGE_ATOM)' for lang in languages)
            blocks.append([holder, f'\tunderstood_languages = list({entries})', f'\tspoken_languages = list({entries})'])
            species_lines[target].append(f'\tspecies_language_holder = {holder}')
        if languages or voices:
            tongue = f"{spec['tongue_root']}/{leaf}"
            block = [tongue]
            extra = [lang for lang in languages if lang != '/datum/language/common']
            if extra:
                block.append(f"\trogue_languages = list({', '.join(extra)})")
            if voices:
                block.append('\temote_sounds = list(')
                for key in sorted(voices):
                    by_sex = ', '.join(f"{sex} = list({', '.join(repr_sound(f) for f in files)})" for sex, files in sorted(voices[key].items()))
                    block.append(f'\t\t"{key}" = list({by_sex}),')
                    sound_files_used |= {f for files in voices[key].values() for f in files}
                    if key not in tg_keys:
                        vocal_keys.add(key)
                block.append('\t)')
            blocks.append(block)
            species_lines[target].append(f'\tmutanttongue = {tongue}')
        if eyes:
            species_lines[target].append(f'\tmutanteyes = {eyes}')
            eyes_used[eyes] = next(rw_eyes for rw_eyes, ours in spec['eyes'].items() if ours == eyes)
    for target, lines in species_lines.items():
        blocks.append([target] + lines)

    # Ratwood's generic human voice (voicepacks/genmale.dm, genfemale.dm) for the bodies with a plain human tongue on
    # medieval maps (rockhill/races.dm gives it them): the voice of the pack's own folder (human_voice_files), without the
    # old, young and silenced variants, the beasts' calls the pack lends to Ratwood's beastfolk and its lewd sounds
    # (human_voice_skip). A sound file missing from the Ratwood cache (--offline does not fetch) is left out.
    voice_files = re.compile(spec.get('human_voice_files', '.'))
    human = {}
    for sex, pack in spec.get('human_voices', {}).items():
        for key, files in voicepack_sounds(pack).items():
            key = spec['emote_keys'].get(key, key)
            files = [f for f in dict.fromkeys(files) if voice_files.search(f) and asset_allowed(f)]
            if files and key not in spec.get('human_voice_skip', []):
                human.setdefault(key, {})['MALE' if sex == 'm' else 'FEMALE'] = files
    fetch_sources(sorted({f for by_sex in human.values() for files in by_sex.values() for f in files}))
    for key in list(human):
        for sex in list(human[key]):
            human[key][sex] = [f for f in human[key][sex] if os.path.exists(os.path.join(CHECKOUT, f))]
            if not human[key][sex]:
                del human[key][sex]
        if not human[key]:
            del human[key]
    lines = ['GLOBAL_LIST_INIT(rogue_human_voices, rogue_human_voices())', '', '/proc/rogue_human_voices()', '\treturn list(']
    for key in sorted(human):
        by_sex = ', '.join(f"{sex} = list({', '.join(repr_sound(f) for f in files)})" for sex, files in sorted(human[key].items()))
        lines.append(f'\t\t"{key}" = list({by_sex}),')
        sound_files_used |= {f for files in human[key].values() for f in files}
        if key not in tg_keys:
            vocal_keys.add(key)
    lines.append('\t\t)')
    blocks.append(lines)

    for ours, rw_eyes in sorted(eyes_used.items()):
        block = [ours]
        for var in ('name', 'desc'):
            value = string_value(rw.resolve(rw_eyes, var))
            if value and value != '""':
                block.append(f'\t{var} = {value}')
        if '/night_vision' in rw_eyes:
            steps = [alpha_cutoff(rw.resolve(rw_eyes, 'lighting_alpha'))] + [alpha_cutoff(define) for define in spec['night_vision_steps']]
            for var, cutoff in zip(('low_light_cutoff', 'medium_light_cutoff', 'high_light_cutoff'), steps):
                block.append(f'\t{var} = list({cutoff}, {cutoff}, {cutoff})')
        else:
            cutoff = alpha_cutoff(rw.resolve(rw_eyes, 'lighting_alpha'))
            if cutoff:
                block.append(f'\tlighting_cutoff = {cutoff}')
        blocks.append(block)

    for key in sorted(vocal_keys):
        block = [f"{spec['vocal_emote_root']}/{key}", f'\tkey = "{key}"']
        source = ratwood_emote(rw, key)
        message = string_value(rw.resolve(source, 'message')) if source else None
        if source and message and message != '""' and (rw.resolve(source, 'nomsg') or '').strip() not in ('1', 'TRUE'):
            block.append(f'\tmessage = {message}')
        blocks.append(block)

    fetch_sources(sorted(sound_files_used))
    for rel in sorted(sound_files_used):
        src = os.path.join(CHECKOUT, rel)
        if os.path.exists(src):
            dest = os.path.join(SOUND_DIR, rel[len('sound/'):])
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copyfile(src, dest)
    open(f"{OUT_DIR}/{spec['dm_file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['dm_file']}: {len(spec['languages'])} languages, {len(species_lines)} species, {len(human)} human voice sounds, {len(sound_files_used)} voice sound files, {len(vocal_keys)} voice emotes, {len(eyes_used)} eyes")


def repr_sound(rel):
    return f"'{SOUND_DIR}/{rel[len('sound/'):]}'"


MIGRANT_WAVE_ROOT = '/datum/migrant_wave'
MIGRANT_ROLE_ROOT = '/datum/migrant_role'
# Ratwood's names of the landmarks migrant waves arrive at (spawn_landmark), kept on the ported start landmarks.
MIGRANT_SPAWNS = set()
TIME_EXPRESSION = re.compile(r'^\d+(?:\.\d+)?(?:\s*(?:SECONDS|MINUTES|HOURS))?$')


def migrant_leaf(path, root):
    return path[len(root) + 1:].replace('/', '_')


def wave_role_counts(rw, wave, var):
    return [(role, int(count)) for role, count in re.findall(r'(/datum/migrant_role/[A-Za-z0-9_/]+)\s*=\s*(\d+)', rw.resolve(wave, var) or '')]


def select_migrants(cfg, rw):
    """Ratwood's migrant waves the port can bring and their roles: a role dresses someone (its own outfit, or the
    classes of its advclass_cat_rolls, as Ratwood rolls them) and, unless the config allows it, makes no antagonist (no
    antagonist is ported); a wave comes when all its required roles do, with the optional roles that do."""
    spec = cfg['port']['migrants']
    roles = {}

    def role_info(role):
        if role not in roles:
            roles[role] = None
            if role in rw.types:
                antag = (rw.resolve(role, 'antag_datum') or '').strip()
                source = (rw.resolve(role, 'outfit') or '').strip()
                outfit = outfit_slots(rw, source) if source.startswith('/datum/outfit') else None
                classes = job_subclasses(rw, role)
                dresses = bool(classes) or bool(outfit and outfit['slots'])
                if dresses and not (antag.startswith('/') and spec['skip_antagonists']):
                    roles[role] = {'classes': classes, 'outfit': outfit if outfit and outfit['slots'] else None}
        return roles[role]

    waves = []
    for wave in sorted(p for p in rw.types if p.startswith(MIGRANT_WAVE_ROOT + '/')):
        if (rw.resolve(wave, 'abstract_type') or '').strip() == wave:
            continue
        required = wave_role_counts(rw, wave, 'required_roles')
        optional = [(role, count) for role, count in wave_role_counts(rw, wave, 'optional_roles') if role_info(role)]
        if not required and not optional:
            continue
        if any(role_info(role) is None for role, _ in required):
            continue
        waves.append((wave, required, optional))
        MIGRANT_SPAWNS.add((string_value(rw.resolve(wave, 'spawn_landmark')) or '"Pilgrim"').strip('"'))
    used = {role for _, required, optional in waves for role, _ in required + optional}
    return {'waves': waves, 'roles': {role: roles[role] for role in sorted(used)}}


def generate_migrants(cfg, rw, migrants, valid):
    """Ratwood's migrant waves for migrants/migrants.dm (ported/migrants.dm): each wave's roles, track, timing, weight,
    limits and greeting; each role's name, greeting, sexes, torch, own outfit and the classes it picks from."""
    spec = cfg['port']['migrants']
    blocks = []
    waves = {wave for wave, _, _ in migrants['waves']}

    def flag(raw):
        value = (raw or '').strip()
        return 'TRUE' if value in ('1', 'TRUE') else 'FALSE' if value in ('0', 'FALSE') else None

    for wave, required, optional in migrants['waves']:
        block = [f"{spec['wave_root']}/{migrant_leaf(wave, MIGRANT_WAVE_ROOT)}"]
        for var in ('name', 'greet_text', 'spawn_landmark'):
            value = string_value(rw.resolve(wave, var))
            if value:
                block.append(f'\t{var} = {value}')
        track = expand_define(rw.resolve(wave, 'track'))
        if STRING_LITERAL.match(track or ''):
            block.append(f'\ttrack = {track}')
        for var, listed in (('required_roles', required), ('optional_roles', optional)):
            if listed:
                block += [f'\t{var} = list('] + [f"\t\t{spec['role_root']}/{migrant_leaf(role, MIGRANT_ROLE_ROOT)} = {count}," for role, count in listed] + ['\t\t)']
        for var in ('min_optional_fills', 'min_active', 'max_active', 'min_pop', 'max_pop', 'max_spawns', 'weight'):
            value = number_value(rw.resolve(wave, var))
            if value is not None:
                block.append(f'\t{var} = {value}')
        timing = (rw.resolve(wave, 'min_round_time') or '').strip()
        if timing and TIME_EXPRESSION.match(timing):
            block.append(f'\tmin_round_time = {timing}')
        for var in ('hidden', 'is_raid', 'can_roll', 'spawn_on_location'):
            value = flag(rw.resolve(wave, var))
            if value:
                block.append(f'\t{var} = {value}')
        shared = (rw.resolve(wave, 'shared_wave_type') or '').strip()
        if shared in waves:
            block.append(f"\tshared_wave_type = {spec['wave_root']}/{migrant_leaf(shared, MIGRANT_WAVE_ROOT)}")
        blocks.append(block)

    for role, info in migrants['roles'].items():
        target = f"{spec['role_root']}/{migrant_leaf(role, MIGRANT_ROLE_ROOT)}"
        block = [target]
        for var in ('name', 'greet_text'):
            value = string_value(rw.resolve(role, var))
            if value:
                block.append(f'\t{var} = {value}')
        sexes = rw.resolve(role, 'allowed_sexes') or ''
        if re.fullmatch(r'\s*list\(\s*(?:(?:MALE|FEMALE)\s*,?\s*)+\)\s*', sexes):
            block.append(f'\tallowed_sexes = {sexes.strip()}')
        if flag(rw.resolve(role, 'grant_lit_torch')) == 'TRUE':
            block.append('\tgrant_lit_torch = TRUE')
        if info['classes']:
            block += ['\trockhill_advclasses = list('] + [f'\t\t{ADVCLASS_TARGET}{advclass[len(ADVCLASS_ROOT):]},' for advclass in info['classes']] + ['\t\t)']
        dressed = info['outfit']
        if dressed:
            outfit = f"{spec['outfit_root']}/{migrant_leaf(role, MIGRANT_ROLE_ROOT)}"
            block.append(f'\toutfit = {outfit}')
            name = string_value(rw.resolve(role, 'name')) or '"Migrant"'
            worn = [outfit, f'\tname = {name}', f"\tjobtype = {spec['job']}"]
            for var in ('uniform', 'shirt', 'suit', 'cloak', 'head', 'mask', 'mouth', 'neck', 'gloves', 'wrists', 'ring', 'shoes', 'belt', 'back', 'backr', 'l_pocket', 'r_pocket', 'l_hand', 'r_hand'):
                item = dressed['slots'].get(var)
                if item and item in valid:
                    worn.append(f'\t{var} = {item}')
            contents = [(item, count) for item, count in (dressed['contents'] or []) if item in valid]
            if contents and dressed['slots'].get('back') in valid:
                worn += ['\tbackpack_contents = list('] + [f'\t\t{item} = {count},' for item, count in contents] + ['\t\t)']
            blocks.append(worn)
        blocks.append(block)
    open(f"{OUT_DIR}/{spec['dm_file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['dm_file']}: {len(migrants['waves'])} waves, {len(migrants['roles'])} roles")


def generate_npcs(cfg, rw, rules, npcs, valid, known_traits, taken_outfits, hair_names=None):
    """Ratwood's NPC people for ai/human_npc.dm: whether each has a mind (mode), hunts (aggressive) or flees in pain, how it
    defends, its faction, race and traits, and the outfits it is dressed in; the outfits themselves with their random
    loadouts, and the stats and skills their pre_equip sets as attribute sheets."""
    spec = cfg['port']['npcs']
    attr_cfg = cfg['attributes']
    writer = NpcOutfits(rw, rules, valid)
    mobs = []
    worn_by = collections.defaultdict(list)
    rows = []
    for path in npcs:
        block = [path]
        mind = (rw.resolve(path, 'mode') or 'NPC_AI_OFF').strip() != 'NPC_AI_OFF'
        if mind:
            block.append('\trogue_npc = TRUE')
        aggressive = (rw.resolve(path, 'aggressive') or '').strip() in ('1', 'TRUE')
        if aggressive:
            block.append('\trogue_aggressive = TRUE')
        if (rw.resolve(path, 'flee_in_pain') or '').strip() in ('1', 'TRUE'):
            block.append('\trogue_flee_in_pain = TRUE')
        if (rw.resolve(path, 'd_intent') or '').strip() == 'INTENT_DODGE':
            block.append('\trogue_def_intent = ROGUE_INTENT_DODGE')
        faction = npc_faction(rw, path)
        if faction and faction != ['"neutral"']:
            block.append(f"\tfaction = list({', '.join(faction)})")
        race = next((species for prefix, species in spec.get('race', {}).items() if boundary_match(path, prefix)), None)
        race = race or cfg['port']['bodies']['species_map'].get((rw.resolve(path, 'race') or '').strip())
        if race:
            block.append(f'\trace = {race}')
        if (string_value(rw.resolve(path, 'name')) or '"Unknown"') != '"Unknown"':
            block.append('\tuse_random_name = FALSE')
        look = npc_look(rw, path, hair_names or {})
        if look:
            block.append('\trogue_npc_look = list(' + ', '.join(f'"{key}" = {value}' for key, value in look.items()) + ')')
        worn = npc_outfits(rw, path)
        if worn:
            block.append(f"\trogue_npc_outfits = list({', '.join(worn)})")
            for outfit in worn:
                worn_by[outfit].append(path)
        traits = [t for t in dict.fromkeys(npc_traits(rw, path)) if t in known_traits]
        if traits:
            block.append(f"\trogue_npc_traits = list({', '.join(traits)})")
        if len(block) > 1:
            mobs.append(block)
        rows.append((path, 'hunts' if mind and aggressive else 'fights back' if mind else 'none', ', '.join(f.strip('"') for f in faction), ', '.join(f'`{o}`' for o in dict.fromkeys(worn))))

    outfits = []
    procs = []
    sheets = []
    done = set()
    sheet_of = {}
    with_pre_equip = set()
    for outfit in sorted(worn_by):
        for link in npc_outfit_chain(outfit):
            if link in done:
                continue
            done.add(link)
            parent = rw.parent(link)
            if link in taken_outfits:
                continue
            block = [link] + writer.statics(link)
            data = npc_outfit_attributes(rw, link, attr_cfg)
            entries = npc_sheet_entries(data, attr_cfg)
            if entries:
                sheet = spec['sheet_root'] + link[len(NPC_OUTFIT_ROOT):]
                sheets.append([sheet, '\traw_attribute_list = list('] + entries + ['\t\t)'])
                block.append(f'\trogue_sheet = {sheet}')
                sheet_of[link] = sheet
            elif sheet_of.get(parent) and link in PRE_EQUIP:
                block.append('\trogue_sheet = null')
            else:
                sheet_of[link] = sheet_of.get(parent)
            traits = [t for t in dict.fromkeys(data['traits']) if t in known_traits]
            if traits:
                block.append(f"\trogue_traits = list({', '.join(traits)})")
            if len(block) > 1 or link in worn_by:
                outfits.append(block)
            lines = writer.pre_equip(link)
            if lines is None:
                if parent in with_pre_equip:
                    with_pre_equip.add(link)
                continue
            calls_parent = any(line.strip() == '..()' for line in lines)
            if any(line.strip() != '..()' for line in lines) and useful_lines(lines):
                procs.append([f'{link}/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)'] + lines)
                with_pre_equip.add(link)
            elif not calls_parent and parent in with_pre_equip:
                procs.append([f'{link}/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)', '\treturn'])
            elif calls_parent and parent in with_pre_equip:
                with_pre_equip.add(link)
    for (owner, name), lines in sorted(writer.helpers.items()):
        if lines:
            procs.append([f'{owner}/proc/{name}(mob/living/carbon/human/H)'] + lines)
    blocks = mobs + outfits + procs + sheets
    open(f"{OUT_DIR}/{spec['file']}", 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    with open(REPORT, 'a', encoding='utf-8', newline='\n') as out:
        out.write(f'\n## NPC people ({len(npcs)} types, {sum(1 for r in rows if r[1] != "none")} with a mind, {len(worn_by)} outfits)\n\n| Type | Mind | Faction | Outfits |\n|---|---|---|---|\n')
        for path, mind, faction, worn in rows:
            out.write(f'| `{path}` | {mind} | {faction} | {worn} |\n')
    print(f"{spec['file']}: {len(npcs)} NPC types, {len(worn_by)} outfits, {len(procs)} procs, {len(sheets)} sheets")


def anvil_recipe_specs(cfg, rw, rules):
    # Ratwood anvil recipes (code/modules/roguetown/roguejobs/*/anvil_recipes): a recipe exists when it has a name and an i_type
    # (init_anvil_recipes()); trait-locked ones (req_trait) stay in Ratwood. A recipe that also starts from a cast blade
    # (req_blade: the plain iron and steel swords, knives, axes, maces, plates) keeps it: the module has the blades
    # (crafting/casting.dm, /obj/item/blade/*), so they are not ported with the items.
    spec = cfg['port'].get('anvil_recipes')
    if not spec:
        return []
    recipes = []
    for path in sorted(p for p in rw.types if p.startswith(spec['root'] + '/')):
        if (rw.types[path].get('abstract_type') or '').strip().rstrip('/') == path:
            continue
        name = string_value(rw.resolve(path, 'name'))
        category = string_value(rw.resolve(path, 'i_type'))
        if not name or name == '""' or not category or category == '""':
            continue
        if (rw.resolve(path, 'req_trait') or 'null').strip() != 'null':
            continue
        blade = (rw.resolve(path, 'req_blade') or 'null').strip().rstrip('/')
        blade = runtime_path(blade, rules) if blade.startswith('/') else None
        made = runtime_path((rw.resolve(path, 'created_item') or '').strip().rstrip('/'), rules)
        bar = runtime_path((rw.resolve(path, 'req_bar') or '').strip().rstrip('/'), rules)
        if not made or not made.startswith('/obj/') or not bar or not bar.startswith('/obj/'):
            continue
        extras = [runtime_path(p.rstrip('/'), rules) for p, _ in list_paths(rw.resolve(path, 'additional_items'))]
        if not all(extras):
            continue
        display = expand_define(rw.resolve(path, 'display_category') or '')
        recipes.append({
            'path': path,
            'name': name,
            'category': category,
            'display': display if STRING_LITERAL.match(display) else None,
            'made': made,
            'bar': bar,
            'extras': extras,
            'count': define_value_number(rw.resolve(path, 'createditem_num')) or 1,
            'craftdiff': define_value_number(rw.resolve(path, 'craftdiff')) or 0,
            'skill': skill_target(cfg, rw.resolve(path, 'appro_skill')) or spec['default_skill'],
            'blade': blade,
            'skip_quality': (rw.resolve(path, 'skip_quality') or 'FALSE').strip() in ('TRUE', '1'),
        })
    return recipes


def anvil_recipe_items(cfg, rw, rules):
    # Everything an anvil recipe takes or makes is ported with the map's items.
    items = set()
    for recipe in anvil_recipe_specs(cfg, rw, rules):
        items |= {recipe['made'], recipe['bar']} | set(recipe['extras'])
    return items


def generate_anvil_recipes(cfg, rw, rules, valid):
    spec = cfg['port'].get('anvil_recipes')
    if not spec:
        return
    blocks = []
    dropped = 0
    blades = 0
    for recipe in anvil_recipe_specs(cfg, rw, rules):
        if any(p not in valid for p in [recipe['made'], recipe['bar']] + recipe['extras'] + ([recipe['blade']] if recipe['blade'] else [])):
            dropped += 1
            continue
        block = [recipe['path'], f"\tname = {recipe['name']}", f"\tcategory = {recipe['category']}"]
        if recipe['display']:
            block.append(f"\tdisplay_category = {recipe['display']}")
        block += [f"\treq_bar = {recipe['bar']}", f"\tcreated_item = {recipe['made']}"]
        if recipe['blade']:
            block.append(f"\treq_blade = {recipe['blade']}")
            blades += 1
        if recipe['skip_quality']:
            block.append('\tskip_quality = TRUE')
        if recipe['count'] != 1:
            block.append(f"\tcreateditem_num = {recipe['count']}")
        if recipe['craftdiff']:
            block.append(f"\tcraftdiff = {recipe['craftdiff']}")
        if recipe['skill'] != spec['default_skill']:
            block.append(f"\tappro_skill = {recipe['skill']}")
        if recipe['extras']:
            block.append('\tadditional_items = list(' + ', '.join(recipe['extras']) + ')')
        blocks.append(block)
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['file']}: {len(blocks)} anvil recipes ({blades} also from a cast blade), {dropped} dropped for unported items")


def hand_declared_types(prefix):
    """Types under prefix the module declares by hand (outside the porter's ported/ folders), so a generator does not write
    them again."""
    found = set()
    for folder, dirs, files in os.walk('modular_redtard'):
        dirs[:] = [d for d in dirs if d != 'ported']
        for file in files:
            if file.endswith('.dm'):
                for line in open(os.path.join(folder, file), encoding='utf-8', errors='ignore'):
                    m = re.match(r'^(/[A-Za-z0-9_/]+?)/?\s*$', line)
                    if m and boundary_match(m.group(1), prefix):
                        found.add(m.group(1))
    return found


def full_recipe_paths(paths):
    """Paths written below another written path: DM would give them its values, so they state all of theirs."""
    written = set(paths)
    return {p for p in paths if any('/'.join(p.split('/')[:k]) in written for k in range(3, p.count('/') + 1))}


def artificer_recipe_specs(cfg, rw, rules):
    # Ratwood's artificer table recipes (roguejobs/artificer/artificer_recipes/artificer_recipes.dm): a recipe is a type with
    # a name, the item set on the table and what it makes (init_rogue_artificer_recipes() of crafting/artificer.dm).
    spec = cfg['port'].get('artificer_recipes')
    if not spec:
        return []
    recipes = []
    for path in sorted(p for p in rw.types if p.startswith(spec['root'] + '/')):
        if (rw.types[path].get('abstract_type') or '').strip().rstrip('/') == path:
            continue
        name = string_value(rw.resolve(path, 'name'))
        required = (rw.resolve(path, 'required_item') or 'null').strip().rstrip('/')
        made = list_paths(rw.resolve(path, 'created_item'))
        if not name or name == '""' or not required.startswith('/') or not made:
            continue
        extras = [(runtime_path(p.rstrip('/'), rules), w) for p, w in list_paths(rw.resolve(path, 'additional_items'))]
        recipes.append({
            'path': path,
            'name': name,
            'i_type': string_value(rw.resolve(path, 'i_type')),
            'required': runtime_path(required, rules),
            'made': [runtime_path(p.rstrip('/'), rules) for p, _ in made],
            'made_list': (rw.resolve(path, 'created_item') or '').strip().startswith('list('),
            'extras': extras,
            'hammers': define_value_number(rw.resolve(path, 'hammers_per_item')) or 0,
            'level': define_value_number(rw.resolve(path, 'skill_level')) or 0,
            'skill': skill_target(cfg, rw.resolve(path, 'appro_skill')) or spec['default_skill'],
        })
    return recipes


def artificer_recipe_items(cfg, rw, rules):
    # What the artificer table takes and makes is ported with the map's items.
    items = set()
    for recipe in artificer_recipe_specs(cfg, rw, rules):
        items |= {p for p in [recipe['required']] + recipe['made'] + [p for p, _ in recipe['extras']] if p}
    return {p for p in items if p in rw.types}


def generate_artificer_recipes(cfg, rw, rules, valid):
    # The recipes of the artificer table (crafting/artificer.dm) under Ratwood's paths, every value stated: a plain
    # created_item stays a type, a list stays a list (several of a thing), additional_items keep their repeats (a stage each).
    spec = cfg['port'].get('artificer_recipes')
    if not spec:
        return
    kept, dropped = [], 0
    for recipe in artificer_recipe_specs(cfg, rw, rules):
        needed = [recipe['required']] + recipe['made'] + [p for p, _ in recipe['extras']]
        if any(not p or p not in valid for p in needed):
            dropped += 1
            continue
        kept.append(recipe)
    full = full_recipe_paths([r['path'] for r in kept])
    blocks = []
    for recipe in kept:
        block = [recipe['path'], f"\tname = {recipe['name']}"]
        if recipe['i_type'] or recipe['path'] in full:
            block.append(f"\ti_type = {recipe['i_type'] or 'null'}")
        block.append(f"\trequired_item = {recipe['required']}")
        made = recipe['made']
        block.append('\tcreated_item = ' + ('list(' + ', '.join(made) + ')' if recipe['made_list'] else made[0]))
        if recipe['extras'] or recipe['path'] in full:
            block.append('\tadditional_items = list(' + ', '.join(f'{p} = {w}' if w else p for p, w in recipe['extras']) + ')')
        if recipe['hammers'] or recipe['path'] in full:
            block.append(f"\thammers_per_item = {recipe['hammers']}")
        if recipe['level'] or recipe['path'] in full:
            block.append(f"\tskill_level = {recipe['level']}")
        if recipe['skill'] != spec['default_skill'] or recipe['path'] in full:
            block.append(f"\tappro_skill = {recipe['skill']}")
        blocks.append(block)
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['file']}: {len(blocks)} artificer recipes, {dropped} dropped for unported items")


def pottery_recipe_specs(cfg, rw, rules):
    # Ratwood's potter's wheel recipes (roguejobs/ceramicist/potterWheel.dm) that the module does not write by hand
    # (crafting/pottery.dm has the brick, the canister and the bottle): every named, non-abstract recipe.
    spec = cfg['port'].get('pottery_recipes')
    if not spec:
        return []
    by_hand = hand_declared_types(spec['root'])
    recipes = []
    for path in sorted(p for p in rw.types if p.startswith(spec['root'] + '/')):
        if path in by_hand or (rw.types[path].get('abstract_type') or '').strip().rstrip('/') == path:
            continue
        name = string_value(rw.resolve(path, 'name'))
        result = (rw.resolve(path, 'result_type') or 'null').strip().rstrip('/')
        if not name or name in ('""', '"wheel recipe"') or not result.startswith('/'):
            continue
        recipes.append({
            'path': path,
            'name': name,
            'craftdiff': define_value_number(rw.resolve(path, 'craftdiff')),
            'base_time': food_number(rw.resolve(path, 'base_time')),
            'result': runtime_path(result, rules),
            'count': define_value_number(rw.resolve(path, 'result_count')),
            'clay': runtime_path((rw.resolve(path, 'required_clay_type') or '').strip().rstrip('/'), rules),
            'spins': define_value_number(rw.resolve(path, 'spins_required')),
        })
    return recipes


def pottery_recipe_items(cfg, rw, rules):
    # What the wheel shapes, the clay it takes and what a kiln fires the raw piece into (Ratwood cooked_type of the clay).
    items = set()
    for recipe in pottery_recipe_specs(cfg, rw, rules):
        todo = [p for p in (recipe['result'], recipe['clay']) if p]
        while todo:
            path = todo.pop()
            if path in items or path not in rw.types:
                continue
            items.add(path)
            fired = (rw.resolve(path, 'cooked_type') or '').strip().rstrip('/')
            if boundary_match(path, '/obj/item/natural/clay') and fired.startswith('/'):
                todo.append(runtime_path(fired, rules))
    return items


def generate_pottery_recipes(cfg, rw, rules, valid):
    # The wheel's recipes for crafting/pottery.dm under Ratwood's paths; a value is written where it differs from the
    # module's default of /datum/pottery_wheel_recipe (Ratwood's own defaults differ: novice, any clay, three spins).
    spec = cfg['port'].get('pottery_recipes')
    if not spec:
        return
    defaults = spec['defaults']
    kept, dropped = [], 0
    for recipe in pottery_recipe_specs(cfg, rw, rules):
        if any(not p or p not in valid for p in (recipe['result'], recipe['clay'])):
            dropped += 1
            continue
        kept.append(recipe)
    full = full_recipe_paths([r['path'] for r in kept])
    blocks = []
    for recipe in kept:
        block = [recipe['path'], f"\tname = {recipe['name']}"]
        values = (('craftdiff', recipe['craftdiff']), ('base_time', recipe['base_time']), ('result_type', recipe['result']),
                  ('result_count', recipe['count']), ('required_clay_type', recipe['clay']), ('spins_required', recipe['spins']))
        for name, value in values:
            if value is not None and (value != defaults[name] or recipe['path'] in full):
                block.append(f'\t{name} = {value}')
        blocks.append(block)
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['file']}: {len(blocks)} potter's wheel recipes, {dropped} dropped for unported items")


CRAFT_FLAGS = {
    'req_table': 'rogue_on_table', 'ontile': 'rogue_on_tile', 'wallcraft': 'rogue_on_wall', 'buildsame': 'rogue_build_same',
    'ignoredensity': 'rogue_ignore_density',
}
_CRAFT_SOURCES = []


def craft_recipe_sources(cfg, rw):
    """Ratwood, then the other codebases whose recipes fill what Ratwood lacks (Azure Peak), each parsed once.

    Parsing another codebase must not leave its defines and procs in the porter's tables, which describe Ratwood."""
    if _CRAFT_SOURCES:
        return _CRAFT_SOURCES
    import copy
    _CRAFT_SOURCES.append(('Ratwood', rw))
    spec = cfg['port'].get('craft_recipes') or {}
    for extra in spec.get('extra_sources', []):
        root = extra['root']
        if not os.path.isdir(root):
            print(f"craft recipes: {extra['name']} not found at {root}, its recipes are skipped")
            continue
        tables = {name: value for name, value in globals().items()
                  if name.isupper() and isinstance(value, (dict, set, list)) and not name.startswith('_')}
        saved = copy.deepcopy(tables)
        try:
            types, _ = parse_codebase(root)
        finally:
            for name, value in saved.items():
                tables[name].clear()
                if isinstance(value, list):
                    tables[name].extend(value)
                else:
                    tables[name].update(value)
        _CRAFT_SOURCES.append((extra['name'], Codebase(types)))
    return _CRAFT_SOURCES


def read_craft_recipe(cfg, base, path, rules):
    # One Ratwood-style crafting recipe (datums/components/crafting/recipes.dm) with everything it inherits, or None when it
    # does not appear in the crafting menu: abstract, unnamed, without a result or hidden. A recipe behind a tech node of
    # Pestra's heart beast keeps the node (rogue_tech_node): the module hides it until the node is unlocked.
    if (base.types[path].get('abstract_type') or '').strip().rstrip('/') == path:
        return None
    name = string_value(base.resolve(path, 'name'))
    if not name or name == '""':
        return None
    if (base.resolve(path, 'hides_from_crafting_menu') or 'FALSE').strip() in ('TRUE', '1'):
        return None
    tech_node = expand_define(base.resolve(path, 'required_tech_node') or 'null').strip()
    tech_node = tech_node if STRING_LITERAL.match(tech_node) and tech_node != '""' else None
    results = [runtime_path(p.rstrip('/'), rules) for p, _ in list_paths(base.resolve(path, 'result'))]
    if not results or not all(results) or not all(r.startswith(('/obj/', '/turf/', '/mob/')) for r in results):
        return None
    def paths(var):
        found = [(runtime_path(p.rstrip('/'), rules), float(w) if w else 1) for p, w in list_paths(base.resolve(path, var))]
        return None if any(p is None for p, _ in found) else found
    reqs, tools, parts = paths('reqs'), paths('tools'), paths('parts')
    if reqs is None or tools is None or parts is None or not reqs:
        return None
    skill_raw = (base.resolve(path, 'skillcraft') or 'null').strip()
    skill = None
    category = '"Other"'
    if skill_raw != 'null':
        skill = skill_target(cfg, skill_raw)
        if not skill:
            return None
        category = string_value(base.resolve(skill_raw, 'name')) or '"Other"'
    structure = (base.resolve(path, 'structurecraft') or 'null').strip().rstrip('/')
    if structure != 'null':
        structure = runtime_path(structure, rules)
        if not structure:
            return None
    else:
        structure = None
    recipe = {
        'path': path,
        'name': name,
        'results': results,
        'reqs': reqs,
        'tools': [p for p, _ in tools],
        'parts': parts,
        'skill': skill,
        'category': category,
        'difficulty': define_value_number(base.resolve(path, 'craftdiff')),
        'structure': structure,
        'flags': [var for raw, var in CRAFT_FLAGS.items() if (base.resolve(path, raw) or 'FALSE').strip() in ('TRUE', '1')],
        'subtypes': (base.resolve(path, 'subtype_reqs') or 'FALSE').strip() in ('TRUE', '1'),
        'learned': (base.resolve(path, 'always_availible') or 'FALSE').strip() not in ('TRUE', '1'),
        'verb': string_value(base.resolve(path, 'verbage')),
        'verb_simple': string_value(base.resolve(path, 'verbage_simple')),
        'sounds': sound_files(base.resolve(path, 'craftsound')),
        'xp': define_value_number(base.resolve(path, 'craft_xp_override')),
        'tech_node': tech_node,
        'diagonal': (base.resolve(path, 'diagonal') or 'FALSE').strip() in ('TRUE', '1'),
        'skip_quality': (base.resolve(path, 'skip_quality') or 'FALSE').strip() in ('TRUE', '1'),
    }
    if recipe['difficulty'] is None:
        recipe['difficulty'] = 1
    return recipe


def craft_recipe_specs(cfg, rw, rules):
    # Ratwood's crafting recipes (code/modules/roguetown/roguecrafting and the items that carry their own), then those of
    # Azure Peak that Ratwood has not: another path that makes something no Ratwood recipe makes from the same things.
    spec = cfg['port'].get('craft_recipes')
    if not spec:
        return []
    recipes = []
    made = set()
    for source, base in craft_recipe_sources(cfg, rw):
        for path in sorted(p for p in base.types if p.startswith(spec['root'] + '/')):
            if source != 'Ratwood' and path in rw.types:
                continue
            recipe = read_craft_recipe(cfg, base, path, rules)
            if not recipe:
                continue
            key = (recipe['results'][0], tuple(sorted(p for p, _ in recipe['reqs'])))
            if source != 'Ratwood' and key in made:
                continue
            made.add(key)
            recipe['source'] = source
            recipes.append(recipe)
    return recipes


def craft_recipe_items(cfg, rw, rules):
    # Everything a crafting recipe takes, needs or makes is ported with the map's items, when Ratwood has it.
    items = set()
    for recipe in craft_recipe_specs(cfg, rw, rules):
        for path in recipe['results'] + [p for p, _ in recipe['reqs'] + recipe['parts']] + recipe['tools'] + [recipe['structure']]:
            if path and path.startswith('/obj/') and path in rw.types:
                items.add(path)
    return items


def generate_craft_recipes(cfg, rw, rules, valid):
    spec = cfg['port'].get('craft_recipes')
    if not spec:
        return
    import bisect
    ordered = sorted(valid)
    def subtypes(path):
        out = []
        start = bisect.bisect_left(ordered, path + '/')
        while start < len(ordered) and ordered[start].startswith(path + '/'):
            out.append(ordered[start])
            start += 1
        return out
    dropped = collections.Counter()
    kept = []
    for recipe in craft_recipe_specs(cfg, rw, rules):
        needed = recipe['results'] + [p for p, _ in recipe['reqs'] + recipe['parts']] + recipe['tools'] + ([recipe['structure']] if recipe['structure'] else [])
        if any(p not in valid for p in needed):
            dropped[recipe['source']] += 1
            continue
        kept.append(recipe)
    written = {recipe['path'] for recipe in kept}
    blocks = []
    sounds_used = set()
    for recipe in kept:
        # A recipe below another written recipe would inherit its values in DM, so it states all of them.
        parts_of_path = recipe['path'].split('/')
        full = any('/'.join(parts_of_path[:k]) in written for k in range(3, len(parts_of_path)))
        def optional(var, value, default='null'):
            if value is not None:
                block.append(f'\t{var} = {value}')
            elif full:
                block.append(f'\t{var} = {default}')
        reqs = ', '.join(f"{p} = {int(n) if n == int(n) else n}" for p, n in recipe['reqs'])
        block = [recipe['path'], f"\tname = {recipe['name']}", f"\tresult = {recipe['results'][0]}", f'\treqs = list({reqs})']
        optional('rogue_results', 'list(' + ', '.join(recipe['results'][1:]) + ')' if len(recipe['results']) > 1 else None)
        optional('tool_paths', 'list(' + ', '.join(recipe['tools']) + ')' if recipe['tools'] else None)
        optional('parts', 'list(' + ', '.join(f"{p} = {int(n)}" for p, n in recipe['parts']) + ')' if recipe['parts'] else None)
        excluded = []
        if not recipe['subtypes']:
            # Ratwood takes the very type it asks for unless subtype_reqs; TG takes subtypes unless they are blacklisted.
            for path, _ in recipe['reqs']:
                if path.startswith('/obj/'):
                    below = subtypes(path)
                    if len(below) <= spec['max_blacklist']:
                        excluded += below
        optional('blacklist', 'list(' + ', '.join(sorted(set(excluded))) + ')' if excluded else None)
        block.append(f"\tcategory = {recipe['category']}")
        block.append(f"\trogue_skill = {recipe['skill'] or 'null'}")
        optional('rogue_difficulty', recipe['difficulty'] if recipe['difficulty'] != 1 else None, '1')
        optional('rogue_structure', recipe['structure'])
        for flag in CRAFT_FLAGS.values():
            optional(flag, 'TRUE' if flag in recipe['flags'] else None, 'FALSE')
        optional('rogue_verb', recipe['verb'] if recipe['verb'] and recipe['verb'] != '"crafts"' else None, '"crafts"')
        optional('rogue_verb_simple', recipe['verb_simple'] if recipe['verb_simple'] and recipe['verb_simple'] != '"craft"' else None, '"craft"')
        sound = next((s for s in recipe['sounds'] if recipe['source'] == 'Ratwood'), None)
        if sound:
            sounds_used.add(sound)
        optional('rogue_sound', repr_sound(sound) if sound else None)
        optional('rogue_xp', recipe['xp'] if recipe['xp'] is not None and recipe['xp'] >= 0 else None, '-1')
        optional('crafting_flags', 'CRAFT_MUST_BE_LEARNED' if recipe['learned'] else None, 'NONE')
        optional('rogue_tech_node', recipe['tech_node'])
        optional('rogue_diagonal', 'TRUE' if recipe['diagonal'] else None, 'FALSE')
        optional('rogue_skip_quality', 'TRUE' if recipe['skip_quality'] else None, 'FALSE')
        if recipe['source'] != 'Ratwood':
            block.insert(1, f"\t// {recipe['source']}")
        blocks.append(block)
    fetch_sources(sorted(sounds_used))
    for rel in sorted(sounds_used):
        src = os.path.join(CHECKOUT, rel)
        if os.path.exists(src):
            dest = os.path.join(SOUND_DIR, rel[len('sound/'):])
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            shutil.copyfile(src, dest)
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    by_source = collections.Counter(b[1].strip().lstrip('/ ') if b[1].strip().startswith('//') else 'Ratwood' for b in blocks)
    print(f"{spec['file']}: {len(blocks)} crafting recipes ({', '.join(f'{n} {s}' for s, n in by_source.items())}), "
          f"dropped for unported items: {', '.join(f'{n} {s}' for s, n in dropped.items()) or 'none'}")


def generate_trade(cfg, rw, rules, valid):
    # Ratwood's trade data for the economy module (modular_redtard/economy): the merchant's import packs
    # (/datum/supply_pack/rogue, sold by the GOLDFACE) and the Crown's stockpile (/datum/roguestock/stockpile, priced from
    # their /datum/trade_good). A pack or a stockpile entry comes along only when everything it hands out is ported or TG's.
    spec = cfg['port'].get('trade')
    if not spec:
        return
    packs = spec['supply_packs']
    groups = set(packs['groups'])
    blocks = []
    dropped = 0
    for path in [p for p in rw.types if p.startswith(packs['root'] + '/')]:
        contains = [runtime_path(p.rstrip('/'), rules) for p, _ in list_paths(rw.resolve(path, 'contains'))]
        group = string_value(rw.resolve(path, 'group'))
        if not contains or not group or group.strip('"') not in groups:
            continue
        if not all(p in valid for p in contains):
            dropped += 1
            continue
        name = string_value(rw.resolve(path, 'name')) or '"Crate"'
        block = [packs['rename'] + path[len(packs['root']):], f'\tname = {name}', f'\tgroup = {group}']
        block.append(f"\tcost = {define_value_number(rw.resolve(path, 'cost')) or 1}")
        for flag in ('not_in_public', 'no_name_quantity', 'static_cost'):
            if (rw.resolve(path, flag) or 'FALSE').strip() in ('TRUE', '1'):
                block.append(f'\t{flag} = TRUE')
        block.append('\tcontains = list(' + ', '.join(contains) + ')')
        blocks.append(block)
    os.makedirs(os.path.dirname(packs['file']), exist_ok=True)
    open(packs['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{packs['file']}: {len(blocks)} supply packs, {dropped} dropped for unported items")

    stock = spec['stockpile']
    prices = {}
    for path in [p for p in rw.types if p.startswith(stock['trade_goods'] + '/')]:
        good = expand_define(rw.resolve(path, 'id') or '')
        base = define_value_number(rw.resolve(path, 'base_price'))
        if STRING_LITERAL.match(good) and base:
            prices[good] = base * (define_value_number(rw.resolve(path, 'global_price_mod')) or 1)
    blocks = []
    dropped = 0
    for path in [p for p in rw.types if p.startswith(stock['root'] + '/')]:
        item = runtime_path((rw.resolve(path, 'item_type') or '').strip().rstrip('/'), rules)
        if not item or not item.startswith('/obj/'):
            continue
        if item not in valid:
            dropped += 1
            continue
        block = [path, f"\tname = {string_value(rw.resolve(path, 'name')) or chr(34) * 2}"]
        desc = string_value(rw.resolve(path, 'desc'))
        if desc:
            block.append(f'\tdesc = {desc}')
        block += [f'\titem_type = {item}', f"\tcategory = {string_value(rw.resolve(path, 'category')) or chr(34) + 'Raw Materials' + chr(34)}"]
        good = expand_define(rw.resolve(path, 'trade_good_id') or '')
        if good in prices:
            block.append(f'\tbase_price = {round(prices[good], 2)}')
        else:
            for name in ('payout_price', 'withdraw_price'):
                block.append(f'\t{name} = {define_value_number(rw.resolve(path, name)) or 1}')
        for name in ('stockpile_amount', 'stockpile_limit', 'importexport_amt', 'passive_generation', 'generation_price'):
            number = define_value_number(rw.resolve(path, name))
            if number is not None:
                block.append(f'\t{name} = {number}')
        for flag, default in (('accept_toggle_enabled', 'TRUE'), ('withdraw_disabled', 'FALSE'), ('import_only', 'FALSE'), ('export_only', 'FALSE')):
            value = (rw.resolve(path, flag) or default).strip()
            if value != default:
                block.append(f'\t{flag} = {value}')
        blocks.append(block)
    os.makedirs(os.path.dirname(stock['file']), exist_ok=True)
    open(stock['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{stock['file']}: {len(blocks)} stockpile entries, {dropped} dropped for unported items")

    # Roles that open a NERVELOCK account on arrival (give_bank_account: TRUE, or the mammons deposited) and draw an estate income.
    blocks = []
    for path in select_jobs(cfg, rw):
        raw = (rw.resolve(path, 'give_bank_account') or 'FALSE').strip()
        deposit = 0 if raw == 'TRUE' else define_value_number(raw)
        if deposit is None or (raw != 'TRUE' and deposit <= 0):
            continue
        block = [path, f'\trogue_bank_account = {deposit if deposit > 1 else 0}']
        income = define_value_number(rw.resolve(path, 'noble_income'))
        if income:
            block.append(f'\trogue_estate_income = {income}')
        blocks.append(block)
    jobs_file = spec['jobs']['file']
    open(jobs_file, 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f'{jobs_file}: {len(blocks)} roles with a NERVELOCK account')


FOOD_TIME_UNITS = {'SECONDS': 10, 'MINUTES': 600, 'DECISECONDS': 1}
FOOD_LINKS = ('cooked_type', 'fried_type', 'slice_path', 'become_rot_type')


def food_number(raw):
    # A Ratwood numeric expression of food data (defines, SECONDS/MINUTES, + - * /) as a number; None if it is not one.
    text = (raw or '').strip()
    if not text or text == 'null':
        return None
    for _ in range(10):
        expanded = re.sub(r'\b[A-Z_][A-Z0-9_]*\b', lambda m: f'({DEFINE_VALUES[m.group(0)].strip()})' if m.group(0) in DEFINE_VALUES and m.group(0) not in FOOD_TIME_UNITS else m.group(0), text)
        if expanded == text:
            break
        text = expanded
    text = re.sub(r'\b(SECONDS|MINUTES|DECISECONDS)\b', lambda m: f'*{FOOD_TIME_UNITS[m.group(1)]}', text)
    text = re.sub(r'\bTRUE\b', '1', re.sub(r'\bFALSE\b', '0', text))
    if not re.fullmatch(r'[\d\s.+\-*/()]+', text):
        return None
    try:
        value = eval(text, {'__builtins__': {}})
    except Exception:
        return None
    return int(value) if value == int(value) else round(value, 2)


def food_entries(raw):
    # Entries of a Ratwood list(...): (key, value) with value None for plain entries.
    text = (raw or '').strip()
    if not text.startswith('list(') or not text.endswith(')'):
        return []
    entries, depth, current, quoted = [], 0, '', False
    for ch in text[5:-1]:
        if ch == '"':
            quoted = not quoted
        if not quoted:
            depth += {'(': 1, ')': -1}.get(ch, 0)
            if ch == ',' and depth == 0:
                entries.append(current)
                current = ''
                continue
        current += ch
    entries.append(current)
    out = []
    for entry in (e.strip() for e in entries):
        if not entry:
            continue
        key, _, value = entry.partition('=')
        out.append((key.strip(), value.strip() or None))
    return out


def food_chain_items(cfg, rw, seeds):
    # Ratwood food the port needs for cooking (survival module): everything a ported food cooks, fries, slices or rots into,
    # and the results of the slapcraft recipes (/datum/food_recipe) whose base and item ingredients are all at hand.
    spec = cfg['port'].get('food')
    if not spec:
        return set()
    seeds = set(seeds)
    for spawner in [p for p in seeds if p.startswith('/obj/effect/spawner/')]:
        seeds |= {item for item, _ in loot_entries(rw.resolve(spawner, 'loot'))}
    reach = {p for p in seeds if boundary_match(p, spec['root']) and p in rw.types} | set(spec.get('always', []))
    recipes = []
    for path in sorted(p for p in rw.types if p.startswith(spec['recipe_root'] + '/')):
        base = (rw.resolve(path, 'base_item') or '').strip().rstrip('/')
        result = (rw.resolve(path, 'result_type') or '').strip().rstrip('/')
        items = [key.rstrip('/') for key, _ in food_entries(rw.resolve(path, 'ingredients')) if key.startswith('/obj/')]
        if base in rw.types and result in rw.types:
            recipes.append((base, result, items))
    changed = True
    while changed:
        changed = False
        for path in list(reach):
            for name in FOOD_LINKS:
                target = (rw.resolve(path, name) or '').strip().rstrip('/')
                if target in rw.types and target not in reach:
                    reach.add(target)
                    changed = True
        for base, result, items in recipes:
            if base in reach and result not in reach and all(any(boundary_match(have, need) for have in reach | seeds) for need in items):
                reach.add(result)
                changed = True
    return reach


def generate_food(cfg, rw, generated, tg_declared, tg_names, declared=frozenset()):
    # Ratwood food data for the survival module (modular_redtard/survival): reagents, food types, tastes, bites, the eat effect,
    # what it cooks (oven), fries (pan, fire) or slices into, its cooking and burning time, shelf life and rotten form, and the
    # slapcraft recipes. Everything referenced is ported or TG's, otherwise left out.
    spec = cfg['port'].get('food')
    if not spec:
        return
    valid = set(generated) | set(tg_declared)
    # Reagents TG has and those the module ports by hand (survival/*.dm: Ratwood's soups, stews, teas under its paths).
    reagent_paths = {p for p in set(tg_declared) | set(declared) if p.startswith('/datum/reagent/')}
    foods = sorted(p for p in generated if boundary_match(p, spec['root']))
    defaults = spec['defaults']

    def path_of(raw):
        target = (raw or '').strip().rstrip('/')
        return target if target in valid else None

    def reagents_of(raw):
        pairs = []
        for key, value in food_entries(raw):
            number = food_number(value)
            key = key.rstrip('/')
            if key in reagent_paths and number:
                pairs.append(f'{key} = {number}')
        return pairs

    def scent_of(raw):
        # Ratwood's cooked_smell is a pollutant type; the module keeps its scent.
        pollutant = (raw or '').strip().rstrip('/')
        scent = string_value(rw.resolve(pollutant, 'scent')) if pollutant in rw.types else None
        return scent if scent and scent != '""' else 'null'

    def values_of(path):
        # The food's Ratwood data as DM values. A null, an unported path or an effect without a module twin is a null: Ratwood's
        # explicit "cooked_type = null" of cooked food has to reach the port, or the type inherits its raw parent's form.
        # A food that would cook into its own type (Ratwood's cooked sausage inherits the raw one's cooked_type) does not cook.
        cooked = path_of(rw.resolve(path, 'cooked_type'))
        cooked = None if cooked == path else cooked
        fried = path_of(rw.resolve(path, 'fried_type'))
        fried = None if fried == path else fried
        cooktime = food_number(rw.resolve(path, 'cooktime')) or 0
        rotprocess = food_number(rw.resolve(path, 'rotprocess')) or 0
        rotten = path_of(rw.resolve(path, 'become_rot_type'))
        slice_path = path_of(rw.resolve(path, 'slice_path'))
        slices = food_number(rw.resolve(path, 'slices_num')) or 0
        if not slice_path or slices <= 0:
            slice_path, slices = None, 0
        bclass = (rw.resolve(path, 'slice_bclass') or '').strip()
        values = OrderedDict((
            ('eat_effect', spec['eat_effects'].get((rw.resolve(path, 'eat_effect') or '').strip(), 'null')),
            ('cooked_type', cooked or 'null'),
            ('fried_type', fried or 'null'),
            ('cooktime', cooktime),
            ('burntime', food_number(rw.resolve(path, 'burntime'))),
            ('bitesize', food_number(rw.resolve(path, 'bitesize'))),
            ('rotprocess', rotprocess),
            ('warming', food_number(rw.resolve(path, 'warming'))),
            ('become_rot_type', rotten if rotten and rotprocess else 'null'),
            ('slice_path', slice_path or 'null'),
            ('slices_num', slices),
            ('slice_bclass', bclass if slice_path and re.fullmatch(r'BCLASS_[A-Z]+', bclass) else None),
            ('slice_batch', ('FALSE' if (rw.resolve(path, 'slice_batch') or 'TRUE').strip() == 'FALSE' else 'TRUE') if slice_path else None),
            ('rogue_faretype', spec['fare'].get(expand_define(rw.resolve(path, 'faretype') or '').strip())),
            ('rogue_portable', {'TRUE': 'TRUE', '1': 'TRUE', 'FALSE': 'FALSE', '0': 'FALSE'}.get((rw.resolve(path, 'portable') or '').strip())),
            ('rogue_cooked_smell', scent_of(rw.resolve(path, 'cooked_smell'))),
            ('rogue_fat_yield', food_number(rw.resolve(path, 'fat_yield')) or 0),
            ('rogue_deep_fried_type', path_of(rw.resolve(path, 'deep_fried_type')) or 'null'),
        ))
        return values

    # A var is written where the food's value differs from what DM gives it in the port: the nearest ported food above it on
    # its path, else the module default (survival/food.dm, appetite.dm, stews.dm; the root's are written below).
    food_set = set(foods)
    effective = {}

    def inherited(path):
        parent = path.rsplit('/', 1)[0]
        while parent.count('/') >= 2:
            if parent in food_set:
                return effective[parent]
            parent = parent.rsplit('/', 1)[0]
        return spec['module_defaults']

    blocks = [[spec['root_block']] + [f'\t{name} = {value}' for name, value in spec['root_values'].items()]]
    own_type_forms = []
    for path in sorted(foods, key=lambda p: (p.count('/'), p)):
        block = [path]
        reagents = reagents_of(rw.resolve(path, 'list_reagents'))
        if reagents:
            block.append('\tfood_reagents = list(' + ', '.join(reagents) + ')')
        bonus = reagents_of(rw.resolve(path, 'bonus_reagents'))
        if bonus:
            block.append('\tbonus_reagents = list(' + ', '.join(bonus) + ')')
        flags = [token for token in re.findall(r'[A-Z_][A-Z0-9_]*', rw.resolve(path, 'foodtype') or '') if token in tg_names and token != 'NONE']
        if flags:
            block.append('\tfoodtypes = ' + ' | '.join(flags))
        tastes = [f'{key} = {food_number(value) or 1}' for key, value in food_entries(rw.resolve(path, 'tastes')) if STRING_LITERAL.match(key)]
        if tastes:
            block.append('\ttastes = list(' + ', '.join(tastes) + ')')
        base = inherited(path)
        values = dict(base)
        for name, value in values_of(path).items():
            if value is None:
                continue
            values[name] = value
            if value != base.get(name):
                block.append(f'\t{name} = {value}')
        effective[path] = values
        if path in (values['cooked_type'], values['fried_type']):
            own_type_forms.append(path)
        if len(block) > 1:
            blocks.append(block)
    if own_type_forms:
        raise SystemExit('foods that would cook into their own type: ' + ', '.join(own_type_forms))
    recipes = 0
    dropped = 0
    implicit = {'/'.join(p.split('/')[:k]) for p in generated for k in range(3, p.count('/') + 2)}
    for path in sorted(p for p in rw.types if p.startswith(spec['recipe_root'] + '/')):
        base = path_of(rw.resolve(path, 'base_item'))
        result = path_of(rw.resolve(path, 'result_type'))
        entries = food_entries(rw.resolve(path, 'ingredients'))
        if not base or not result or not entries:
            dropped += bool(rw.resolve(path, 'base_item'))
            continue
        ingredients = []
        for key, value in entries:
            key = key.rstrip('/')
            if key in reagent_paths and food_number(value):
                ingredients.append(f'{key} = {food_number(value)}')
            elif key.startswith('/obj/') and value is None and (key in implicit or key in tg_declared):
                ingredients.append(key)
            else:
                ingredients = None
                break
        if not ingredients:
            dropped += 1
            continue
        block = [spec['recipe_target'] + path[len(spec['recipe_root']):]]
        name = string_value(rw.resolve(path, 'name'))
        if name:
            block.append(f'\tname = {name}')
        block += [f'\tbase_item = {base}', '\tingredients = list(' + ', '.join(ingredients) + ')', f'\tresult_type = {result}']
        if (rw.resolve(path, 'needs_cooking') or '').strip() == 'TRUE':
            block.append('\tneeds_cooking = TRUE')
        step = food_number(rw.resolve(path, 'time_per_step'))
        if step and step != defaults['time_per_step']:
            block.append(f'\ttime_per_step = {step}')
        blocks.append(block)
        recipes += 1
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['file']}: {len(foods)} foods, {recipes} recipes, {dropped} recipes dropped for unported items or reagents")


# Ratwood husbandry vars of a beast (simple_animal.dm, rogue/farm/*.dm, game/saiga.dm): Ratwood name, module var, kind, module default.
HUSBANDRY_VARS = (
    ('gender', 'gender', 'gender', None),
    ('tame_chance', 'rogue_tame_chance', 'number', 0),
    ('bonus_tame_chance', 'rogue_tame_bonus', 'number', 0),
    ('tame', 'rogue_start_tame', 'flag', 'FALSE'),
    ('childtype', 'rogue_childtype', 'weights', None),
    ('animal_species', 'rogue_partner_type', 'path', None),
    ('adult_growth', 'rogue_adult_type', 'path', None),
    ('breedcd', 'rogue_breed_cooldown', 'number', 3000),
    ('egg_type', 'rogue_egg_type', 'path', None),
    ('eggsFertile', 'rogue_eggs_fertile', 'flag', 'TRUE'),
)
# Vars that name other beasts the port needs: the young, the partner, what the young grow into.
HUSBANDRY_LINKS = ('childtype', 'animal_species', 'adult_growth')


def husbandry_entries(raw):
    # A Ratwood beast reference as (path, weight) pairs: a weighted list(...) or a single path; nothing for null.
    text = (raw or '').strip()
    if text.startswith('list('):
        return [(key.rstrip('/'), food_number(value) or 1) for key, value in food_entries(text) if key.startswith('/')]
    if text.startswith('/'):
        return [(text.rstrip('/'), 1)]
    return []


def husbandry_types(cfg, rw, seeds):
    # Ratwood livestock for the husbandry module (modular_redtard/husbandry): the young a ported beast gives birth to (childtype),
    # its partner (animal_species) and what the young grow into (adult_growth), round until nothing new comes, plus the types
    # Ratwood names only in code (the chick a fertile egg hatches into).
    spec = cfg['port'].get('husbandry')
    if not spec:
        return set()
    reach = {p for p in spec.get('extra_types', []) if p in rw.types}
    todo = [p for p in seeds if p.startswith('/mob/living/') and p in rw.types] + sorted(reach)
    seen = set(todo)
    while todo:
        path = todo.pop()
        for name in HUSBANDRY_LINKS:
            for target, _ in husbandry_entries(rw.resolve(path, name)):
                if target in rw.types and target not in seen:
                    seen.add(target)
                    reach.add(target)
                    todo.append(target)
    return reach


def generate_husbandry(cfg, rw, generated, tg_declared):
    # Ratwood husbandry data of the ported beasts for the husbandry module: sex, taming chances, born tame, the young and how
    # likely each is, the partner, what the young grow into, the breeding cooldown, the egg. A var is written where its
    # Ratwood value differs from what the type inherits in the port (the nearest ported parent path, else the module default).
    spec = cfg['port'].get('husbandry')
    if not spec:
        return
    valid = set(generated) | set(tg_declared)

    def value_of(raw, kind):
        text = (raw or '').strip()
        if kind == 'gender':
            return text if text in ('MALE', 'FEMALE') else None
        if kind == 'number':
            return food_number(text)
        if kind == 'flag':
            number = food_number(text)
            return None if number is None else ('TRUE' if number else 'FALSE')
        if kind == 'path':
            target = text.rstrip('/')
            return target if target in valid else None
        pairs = [f'{path} = {weight}' for path, weight in husbandry_entries(text) if path in valid]
        return 'list(' + ', '.join(pairs) + ')' if pairs else None

    defaults = {target: default for _, target, _, default in HUSBANDRY_VARS}
    mobs = sorted((p for p in generated if p.startswith('/mob/living/') and not boundary_match(p, NPC_ROOT)), key=lambda p: (p.count('/'), p))
    effective = {}
    blocks = []
    for path in mobs:
        parent = next((path.rsplit('/', k)[0] for k in range(1, path.count('/')) if path.rsplit('/', k)[0] in effective), None)
        inherited = effective.get(parent, defaults)
        values = dict(inherited)
        block = [path]
        for source, target, kind, default in HUSBANDRY_VARS:
            value = value_of(rw.resolve(path, source), kind)
            if value is None:
                value = default
            values[target] = value
            if value != inherited[target]:
                shown = value if value is not None else ('PLURAL' if kind == 'gender' else 'null')
                block.append(f'\t{target} = {shown}')
        effective[path] = values
        if len(block) > 1:
            blocks.append(block)
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['file']}: husbandry data for {len(blocks)} of {len(mobs)} beasts")


ALCHEMY_LEANINGS = ('major_pot', 'med_pot', 'minor_pot')


def alchemy_recipe_paths(rw, root):
    """Ratwood's recipes of one kind of alchemy, the abstract root left out."""
    return sorted(p for p in rw.types if boundary_match(p, root) and (rw.types[p].get('abstract_type') or '').strip().rstrip('/') != p)


def alchemy_entries(raw):
    """(path, number) of a Ratwood list(/path = n, ...); a plain path counts once."""
    pairs = []
    for key, value in food_entries(raw):
        key = key.strip().rstrip('/')
        if not key.startswith('/'):
            continue
        number = food_number(value) if value is not None else 1
        pairs.append((key, number if number is not None else 1))
    return pairs


def alchemy_types(cfg, rw):
    # Ratwood's alchemy for the alchemy module (modular_redtard/alchemy/brewing.dm): every ingredient (/obj/item/alch), what the
    # mortar's recipes take and give and the items the cauldron's recipes leave, so the port has all of them.
    spec = cfg['port'].get('alchemy')
    if not spec:
        return set()
    found = {p for p in rw.types if boundary_match(p, spec['ingredient_root'])}
    for path in alchemy_recipe_paths(rw, spec['grind_root']):
        found.add((rw.resolve(path, 'valid_input') or '').strip().rstrip('/'))
        for name in ('valid_outputs', 'bonus_chance_outputs'):
            found |= {p for p, _ in alchemy_entries(rw.resolve(path, name))}
    for path in alchemy_recipe_paths(rw, spec['cauldron_root']):
        found |= {p for p, _ in alchemy_entries(rw.resolve(path, 'output_items'))}
    found |= set(spec.get('extra_types', []))
    return {p for p in found if p in rw.types}


def generate_alchemy(cfg, rw, valid, generated):
    # Ratwood's alchemy data for the alchemy module under Ratwood's paths: the cauldron's recipes (what they make, their smell,
    # the skill they need), the mortar's (what it takes and gives) and what each ported ingredient leans toward in the cauldron.
    # A recipe whose input or every output the port lacks is dropped, and the leanings toward a dropped recipe with it. A var
    # of an ingredient is written where it differs from what the type inherits in the port.
    spec = cfg['port'].get('alchemy')
    if not spec:
        return
    default_skill = define_value_number(spec['default_skill'])

    def listed(pairs):
        return 'list(' + ', '.join(f'{p} = {n:g}' for p, n in pairs) + ')'

    blocks = []
    cauldron, cauldron_dropped = set(), 0
    for path in alchemy_recipe_paths(rw, spec['cauldron_root']):
        reagents = [(p, n) for p, n in alchemy_entries(rw.resolve(path, 'output_reagents')) if p in valid]
        items = [(p, n) for p, n in alchemy_entries(rw.resolve(path, 'output_items')) if p in valid]
        if not reagents and not items:
            cauldron_dropped += 1
            continue
        cauldron.add(path)
        block = [path, f"\tname = {string_value(rw.resolve(path, 'name')) or '\"\"'}"]
        smell = string_value(rw.resolve(path, 'smells_like'))
        if smell:
            block.append(f'\tsmells_like = {smell}')
        skill = define_value_number(rw.resolve(path, 'skill_required') or spec['default_skill'])
        if skill is not None and skill != default_skill:
            block.append(f'\tskill_required = {skill:g}')
        if reagents:
            block.append(f'\toutput_reagents = {listed(reagents)}')
        if items:
            block.append(f'\toutput_items = {listed(items)}')
        blocks.append(block)
    grind, grind_dropped = 0, 0
    for path in alchemy_recipe_paths(rw, spec['grind_root']):
        source = (rw.resolve(path, 'valid_input') or '').strip().rstrip('/')
        outputs = [(p, n) for p, n in alchemy_entries(rw.resolve(path, 'valid_outputs')) if p in valid]
        bonus = [(p, n) for p, n in alchemy_entries(rw.resolve(path, 'bonus_chance_outputs')) if p in valid]
        if source not in valid or not (outputs or bonus):
            grind_dropped += 1
            continue
        grind += 1
        block = [path]
        name = string_value(rw.resolve(path, 'name'))
        if name and name != '"generic grind recipe"':
            block.append(f'\tname = {name}')
        block.append(f'\tvalid_input = {source}')
        if (rw.resolve(path, 'picky') or 'TRUE').strip() in ('FALSE', '0'):
            block.append('\tpicky = FALSE')
        if outputs:
            block.append(f'\tvalid_outputs = {listed(outputs)}')
        if bonus:
            block.append(f'\tbonus_chance_outputs = {listed(bonus)}')
        blocks.append(block)
    ingredients = sorted((p for p in generated if boundary_match(p, spec['ingredient_root'])), key=lambda p: (p.count('/'), p))
    effective = {}
    leaning = 0
    for path in ingredients:
        parent = next((path.rsplit('/', k)[0] for k in range(1, path.count('/')) if path.rsplit('/', k)[0] in effective), None)
        inherited = effective.get(parent, dict.fromkeys(ALCHEMY_LEANINGS))
        values = {}
        block = [path]
        for name in ALCHEMY_LEANINGS:
            target = (rw.resolve(path, name) or '').strip().rstrip('/')
            values[name] = target if target in cauldron else None
            if values[name] != inherited[name]:
                block.append(f'\t{name} = {values[name] or "null"}')
        effective[path] = values
        if len(block) > 1:
            blocks.append(block)
            leaning += 1
    os.makedirs(os.path.dirname(spec['file']), exist_ok=True)
    open(spec['file'], 'w', encoding='utf-8', newline='\n').write('\n\n'.join('\n'.join(b) for b in blocks) + '\n')
    print(f"{spec['file']}: {len(cauldron)} cauldron recipes ({cauldron_dropped} dropped), {grind} grind recipes ({grind_dropped} dropped), leanings of {leaning} of {len(ingredients)} ingredients")


if __name__ == '__main__':
    main()
