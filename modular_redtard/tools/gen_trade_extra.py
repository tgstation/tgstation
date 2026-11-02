"""Ratwood's market data beyond the trade goods of trade_data.dm (modular_redtard/economy/trade_extra_data.dm).

Reads the Ratwood cache (.cache/ratwood) and writes, for the economy module's market code (economy/market_*.dm,
economy/ship_trade.dm, economy/merchant_favor.dm, economy/petitions.dm, economy/pricing_engine.dm):
- the trade goods sold as finished items or potions (Ratwood equipment, trophy and potion goods), which trade_data.dm
  leaves out because Ratwood prices them by recipe or by reagent;
- the economic events (shortages and gluts) and the conditions of the foreign realms;
- the provisions and the cultural stock each realm's ships deal in;
- the merchant's catalogs;
- the standing order templates each region posts, all of Ratwood's;
- the market category of every crafting recipe of the port, for the pricing engine's markups.
Only data moves: names, numbers, paths as text (resolved in the game, so things not ported yet are skipped there).

Usage: py -3 -I modular_redtard/tools/gen_trade_extra.py [ratwood_root] [azure_root]
"""
import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_trade_data import Values, dm_list_block, dm_string, dm_value, read_blocks, read_defines, resolved  # noqa: E402

MODULE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
REPO = os.path.normpath(os.path.join(MODULE, '..'))
OUTPUT = os.path.join(MODULE, 'economy', 'trade_extra_data.dm')
TRADE_DATA = os.path.join(MODULE, 'economy', 'trade_data.dm')
PORTED_RECIPES = os.path.join(MODULE, 'crafting', 'ported', 'craft_recipes.dm')

GOODS_DIR = 'code/modules/roguetown/roguestock/trade_goods'
EVENTS_FILE = 'code/modules/roguetown/roguestock/economic_events.dm'
CONDITIONS_FILE = 'code/modules/roguetown/roguemachine/merchant/trade/realm_conditions_generic.dm'
REALMS_DIR = 'code/modules/roguetown/roguemachine/merchant/trade/realms'
CATALOG_FILE = 'code/modules/roguetown/roguemachine/merchant/trade/merchant_catalog.dm'
PACKS_DIR = 'code/modules/cargo/packsrogue/merchant/foreign'
ECONOMY_FILE = 'code/controllers/subsystem/rogue/economy/economy.dm'
FINISHED = ('equipment', 'potion')
PACK_ROOT = '/datum/supply_pack/rogue/'
PORTED_PACK_ROOT = '/datum/rogue_supply_pack/'
FONT_TAG = re.compile(r'</?font[^>]*>')


def ported_pack(path):
    """The module's path of a Ratwood import pack (the porter's rename of /datum/supply_pack/rogue)."""
    return PORTED_PACK_ROOT + path[len(PACK_ROOT):] if path.startswith(PACK_ROOT) else path


def dm_files(root, pattern='**/*.dm'):
    return sorted(glob.glob(os.path.join(root, pattern), recursive=True))


def recipe_files(root):
    """Every file of a Ratwood-family tree that defines crafting recipes."""
    found = []
    for path in dm_files(root, 'code/**/*.dm') + dm_files(root, 'modular*/**/*.dm'):
        with open(path, encoding='utf-8', errors='replace') as handle:
            if re.search(r'^/datum/crafting_recipe', handle.read(), re.MULTILINE):
                found.append(path)
    return found


def finished_goods(root, values, known_ids):
    blocks = read_blocks(dm_files(root, GOODS_DIR + '/*.dm'))
    goods = []
    for path in sorted(blocks):
        raw_id = resolved(blocks, path, 'id')
        if not raw_id:
            continue
        try:
            good_id = values.scalar(raw_id)
            behavior = values.scalar(resolved(blocks, path, 'behavior') or 'null')
        except ValueError:
            continue
        if behavior not in FINISHED or good_id in known_ids:
            continue
        item = resolved(blocks, path, 'item_type')
        reagent = resolved(blocks, path, 'reagent_type')
        good = {
            'id': good_id,
            'name': values.scalar(resolved(blocks, path, 'name') or '""'),
            'behavior': behavior,
            'item': values.scalar(item) if item else None,
            'reagent': values.scalar(reagent) if reagent else None,
            'volume': values.scalar(resolved(blocks, path, 'required_volume') or '0'),
            'purchase': None,
            'derive': values.scalar(resolved(blocks, path, 'derive_price') or 'FALSE'),
            'subtypes': values.scalar(resolved(blocks, path, 'accept_subtypes') or 'FALSE'),
            'alt': values.parse(resolved(blocks, path, 'alt_item_types') or 'list()') or [],
        }
        purchase = resolved(blocks, path, 'purchase_item_type')
        if purchase:
            good['purchase'] = values.scalar(purchase)
        try:
            good['base'] = values.scalar(resolved(blocks, path, 'base_price') or '0') or 0
        except ValueError:
            good['base'] = 0
        if not good['item'] and not good['reagent']:
            continue
        goods.append(good)
    return goods


def economic_events(root, values):
    blocks = read_blocks([os.path.join(root, EVENTS_FILE)])
    events = []
    for path, body in blocks.items():
        if 'name' not in body or 'price_mod' not in body:
            continue
        tier = body['price_mod'].strip()
        if not tier.startswith('ECON_'):
            continue
        events.append({
            'key': path.rsplit('/', 1)[1],
            'name': values.scalar(body['name']),
            'description': values.scalar(body.get('description', '""')),
            'announcement': FONT_TAG.sub('', values.scalar(body.get('announcement', '""'))),
            'goods': values.parse(body.get('affected_goods', 'list()')) or [],
            'tier': tier[len('ECON_'):].lower(),
            'type': values.scalar(body['event_type']),
        })
    return events


def modifier_list(raw_list):
    out = []
    for mod in raw_list or []:
        entry = {'op': mod['op'], 'good': mod.get('good')}
        for key in ('price_mod', 'qty_mod', 'qty_min', 'qty_max', 'always'):
            if key in mod:
                entry[key] = mod[key]
        if entry['good']:
            out.append(entry)
    return out


def realm_conditions(root, values):
    blocks = read_blocks([os.path.join(root, CONDITIONS_FILE)])
    conditions = []
    for path, body in blocks.items():
        if 'id' not in body:
            continue
        condition = {
            'key': path.rsplit('/', 1)[1],
            'id': values.scalar(body['id']),
            'name': values.scalar(body.get('name', '""')),
            'description': values.scalar(body.get('description', '""')),
            'weight': values.scalar(body.get('weight', '10')),
            'realms': values.parse(body.get('affected_realms', 'list()')) or [],
            'cross': values.scalar(body.get('cross_realm', 'FALSE')),
            'supply': modifier_list(values.parse(body.get('supply_modifiers', 'list()'))),
            'demand': modifier_list(values.parse(body.get('demand_modifiers', 'list()'))),
            'per_realm': {},
        }
        per_realm = values.parse(body.get('per_realm_modifiers', 'list()')) or {}
        if isinstance(per_realm, dict):
            for realm_id, realm_block in per_realm.items():
                condition['per_realm'][realm_id] = {
                    'supply': modifier_list(realm_block.get('supply')),
                    'demand': modifier_list(realm_block.get('demand')),
                }
        conditions.append(condition)
    return conditions


def realm_extras(root, values):
    """Provisions and cultural stock of each realm (Ratwood victualling pools and cultural_stock_pool)."""
    blocks = read_blocks(dm_files(root, REALMS_DIR + '/*.dm'))
    pack_blocks = read_blocks(dm_files(root, PACKS_DIR + '/*.dm'))
    provisions, cultural = {}, {}
    for path, body in sorted(blocks.items()):
        if 'id' not in body:
            continue
        realm_id = values.scalar(body['id'])
        pools = {}
        for var, key in (('victualling_fresh_pool', 'fresh'), ('victualling_preserved_pool', 'preserved')):
            lines = []
            for entry in values.parse(body.get(var, 'list()')) or []:
                if not entry.get('typepath'):
                    continue
                lines.append({'path': entry['typepath'], 'min': entry.get('qty_min', 3), 'max': entry.get('qty_max', 6), 'price': entry.get('price', 10)})
            pools[key] = lines
        drinks = []
        for entry in values.parse(body.get('victualling_drinks_pool', 'list()')) or []:
            if not entry.get('recipe'):
                continue
            drink = {'recipe': entry['recipe']}
            if entry.get('price_mod') not in (None, 1):
                drink['price_mod'] = entry['price_mod']
            if entry.get('keg_mult') not in (None, 1):
                drink['keg_mult'] = entry['keg_mult']
            drinks.append(drink)
        pools['drinks'] = drinks
        provisions[realm_id] = pools
        stock = []
        for pack in values.parse(body.get('cultural_stock_pool', 'list()')) or []:
            if not isinstance(pack, str) or not pack.startswith(PACK_ROOT):
                continue
            qty_min = values.scalar(resolved(pack_blocks, pack, 'ship_qty_min') or '0')
            qty_max = values.scalar(resolved(pack_blocks, pack, 'ship_qty_max') or '0')
            chance = values.scalar(resolved(pack_blocks, pack, 'ship_chance') or '100')
            # A pack without a ship quantity never comes aboard (Ratwood roll_cultural_stock() skips a roll of 0).
            if qty_max <= 0:
                continue
            stock.append({'pack': ported_pack(pack), 'min': qty_min, 'max': qty_max, 'chance': chance})
        cultural[realm_id] = stock
    return provisions, cultural


def catalogs(root, values):
    blocks = read_blocks([os.path.join(root, CATALOG_FILE)])
    out = []
    for path, body in blocks.items():
        if 'id' not in body or path == '/datum/merchant_catalog':
            continue
        stock = values.parse(body.get('stock', 'list()')) or {}
        out.append({
            'key': path.rsplit('/', 1)[1],
            'id': values.scalar(body['id']),
            'name': values.scalar(body.get('name', '""')),
            'desc': values.scalar(body.get('desc', '""')),
            'stock': {ported_pack(pack): count for pack, count in stock.items()},
        })
    return out


def region_templates(root):
    text = open(os.path.join(root, ECONOMY_FILE), encoding='utf-8', errors='replace').read()
    mapping = {}
    for match in re.finditer(r'\t\t(TRADE_REGION_\w+) = list\(\n((?:\t\t\t/datum/standing_order/\w+,\n)+)\t\t\)', text):
        mapping[match.group(1)] = re.findall(r'/datum/standing_order/(\w+)', match.group(2))
    return mapping


def recipe_categories(roots, values, ported_paths):
    """Recipe type -> market category, resolved through the recipe's parents in the tree that defines it."""
    categories = {}
    for root in roots:
        if not root or not os.path.isdir(root):
            continue
        tree_values = Values(read_defines(root))
        blocks = read_blocks(recipe_files(root))
        for path in ported_paths:
            if path in categories or path not in blocks:
                continue
            raw = resolved(blocks, path, 'display_category')
            if not raw:
                continue
            try:
                categories[path] = tree_values.scalar(raw)
            except ValueError:
                continue
    return categories


def main():
    root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, '.cache', 'ratwood'))
    azure = os.path.abspath(sys.argv[2]) if len(sys.argv) > 2 else os.path.normpath(os.path.join(REPO, '..', 'Azure-Peak-Fork'))
    values = Values(read_defines(root))
    known_ids = set(re.findall(r'^\tid = "([A-Z0-9_]+)"', open(TRADE_DATA, encoding='utf-8').read(), re.MULTILINE))
    ported_paths = re.findall(r'^(/datum/crafting_recipe/[\w/]+)\s*$', open(PORTED_RECIPES, encoding='utf-8').read(), re.MULTILINE)

    goods = finished_goods(root, values, known_ids)
    events = economic_events(root, values)
    conditions = realm_conditions(root, values)
    provisions, cultural = realm_extras(root, values)
    catalog_list = catalogs(root, values)
    templates = region_templates(root)
    categories = recipe_categories([root, azure], values, ported_paths)

    out = [
        '// Generated by modular_redtard/tools/gen_trade_extra.py from Ratwood\'s market data; do not edit by hand.',
        '// Paths are text: goods, provisions and packs whose things are not ported are skipped in the game.',
        '',
    ]
    for good in goods:
        out += [
            f'/datum/rogue_trade_good/{good["id"].lower()}',
            f'\tid = {dm_string(good["id"])}',
            f'\tname = {dm_string(good["name"])}',
            f'\tbase_price = {good["base"]}',
            f'\tbehavior = {dm_string(good["behavior"])}',
        ]
        if good['item']:
            out.append(f'\titem_path = {dm_string(good["item"])}')
        if good['derive']:
            out.append('\tderive_price = TRUE')
        if good['subtypes']:
            out.append('\taccept_subtypes = TRUE')
        if good['alt']:
            out += dm_list_block('alt_item_paths', good['alt'])
        if good['reagent']:
            out.append(f'\treagent_path = {dm_string(good["reagent"])}')
            out.append(f'\trequired_volume = {good["volume"]}')
        if good['purchase']:
            out.append(f'\tpurchase_path = {dm_string(good["purchase"])}')
        out.append('')

    for event in sorted(events, key=lambda e: e['key']):
        out += [
            f'/datum/rogue_economic_event/{event["key"]}',
            f'\tname = {dm_string(event["name"])}',
            f'\tdescription = {dm_string(event["description"])}',
            f'\tannouncement = {dm_string(event["announcement"])}',
        ]
        out += dm_list_block('affected_goods', event['goods'], 6)
        out += [f'\tprice_tier = {dm_string(event["tier"])}', f'\tevent_type = {dm_string(event["type"])}', '']

    for condition in sorted(conditions, key=lambda c: c['key']):
        out += [
            f'/datum/rogue_realm_condition/{condition["key"]}',
            f'\tid = {dm_string(condition["id"])}',
            f'\tname = {dm_string(condition["name"])}',
            f'\tdescription = {dm_string(condition["description"])}',
            f'\tweight = {condition["weight"]}',
        ]
        out += dm_list_block('affected_realms', condition['realms'], 6)
        if condition['cross']:
            out.append('\tcross_realm = TRUE')
        if condition['supply']:
            out += dm_list_block('supply_modifiers', condition['supply'])
        if condition['demand']:
            out += dm_list_block('demand_modifiers', condition['demand'])
        if condition['per_realm']:
            out.append('\tper_realm_modifiers = list(')
            for realm_id, realm_block in condition['per_realm'].items():
                out.append(f'\t\t{dm_string(realm_id)} = {dm_value(realm_block)},')
            out.append('\t)')
        out.append('')

    out.append('/// Realm id -> the provisions its ships buy: fresh and preserved dishes, drinks by the keg (Ratwood victualling pools).')
    out.append('GLOBAL_LIST_INIT(rogue_realm_provisions, list(')
    for realm_id in sorted(provisions):
        out.append(f'\t{dm_string(realm_id)} = {dm_value(provisions[realm_id])},')
    out += ['))', '']

    out.append('/// Realm id -> the cultural packs its ships sell, with the units a ship carries and the chance it carries any (Ratwood')
    out.append('/// cultural_stock_pool and the packs\' ship_qty_min, ship_qty_max, ship_chance). Packs are module paths: the porter brings them.')
    out.append('GLOBAL_LIST_INIT(rogue_realm_cultural_stock, list(')
    for realm_id in sorted(cultural):
        out.append(f'\t{dm_string(realm_id)} = {dm_value(cultural[realm_id])},')
    out += ['))', '']

    for catalog in sorted(catalog_list, key=lambda c: c['key']):
        out += [
            f'/datum/rogue_merchant_catalog/{catalog["key"]}',
            f'\tid = {dm_string(catalog["id"])}',
            f'\tname = {dm_string(catalog["name"])}',
            f'\tdesc = {dm_string(catalog["desc"])}',
        ]
        out.append('\tstock = list(')
        for pack, count in catalog['stock'].items():
            out.append(f'\t\t{dm_string(pack)} = {count},')
        out += ['\t)', '']

    out.append('/// Region id -> every standing order template Ratwood lets it post (populate_standing_order_templates()); templates the')
    out.append('/// module does not have are skipped in the game.')
    out.append('GLOBAL_LIST_INIT(rogue_region_order_templates, list(')
    for region_define in sorted(templates):
        region_id = values.scalar(region_define)
        out.append(f'\t{dm_string(region_id)} = {dm_value(templates[region_define])},')
    out += ['))', '']

    out.append('/// Crafting recipe -> the market category of what it makes (Ratwood display_category), for the pricing engine\'s markups.')
    out.append('GLOBAL_LIST_INIT(rogue_recipe_categories, list(')
    for path in sorted(categories):
        out.append(f'\t{dm_string(path)} = {dm_string(categories[path])},')
    out += ['))']

    open(OUTPUT, 'w', encoding='utf-8', newline='\n').write('\n'.join(out).rstrip('\n') + '\n')
    print(f'{os.path.relpath(OUTPUT, REPO)}: {len(goods)} finished goods, {len(events)} events, {len(conditions)} conditions, '
          f'{len(provisions)} realms, {len(catalog_list)} catalogs, {len(templates)} regions, {len(categories)} recipe categories')


if __name__ == '__main__':
    main()
