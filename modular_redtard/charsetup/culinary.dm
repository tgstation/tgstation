/// Ratwood's food preferences (modules/client/preferences_culinary.dm, _globalvars/food_preferences.dm): the favourite and
/// hated food and drink of a medieval character, picked in the character menu and given to the human at spawn as
/// rogue_culinary (survival/appetite.dm), where a bite or a sip of them sweetens or sours the mood. The lists are
/// Ratwood's, built the same way: every food of this world but the bases, raw parts, slices and Ratwood's blacklist, one
/// per name, by fare; and every drink Ratwood lists that this world has, by quality. Ratwood's paths are kept as text, so
/// a food or drink the world lacks is skipped, and one ported later joins the list by itself.

/// The hated drink's "nothing" (Ratwood get_default_hated_drink() returns none).
#define ROGUE_CULINARY_NONE "none"
/// Ratwood's quality of a drink, from TG's DRINK_* (TG's scale starts at 1 for revolting, Ratwood's at 1 for nice).
#define ROGUE_DRINK_RANK(quality) max((quality) - 1, 0)

/// What Ratwood leaves out of the food list besides the bases, fish, organs and slices (init_food_with_faretypes()).
GLOBAL_LIST_INIT(rogue_culinary_food_blacklist, list(
	"/obj/item/reagent_containers/food/snacks",
	"/obj/item/reagent_containers/food/snacks/grown",
	"/obj/item/reagent_containers/food/snacks/grown/wheat",
	"/obj/item/reagent_containers/food/snacks/grown/oat",
	"/obj/item/reagent_containers/food/snacks/grown/rice",
	"/obj/item/reagent_containers/food/snacks/grown/vegetable",
	"/obj/item/reagent_containers/food/snacks/grown/fruit",
	"/obj/item/reagent_containers/food/snacks/rogue",
	"/obj/item/reagent_containers/food/snacks/rogue/eggplantmeat",
	"/obj/item/reagent_containers/food/snacks/rogue/pie",
	"/obj/item/reagent_containers/food/snacks/rogue/meat",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/mince",
	"/obj/item/reagent_containers/food/snacks/rogue/dough_base",
	"/obj/item/reagent_containers/food/snacks/rogue/ccakeuncooked",
	"/obj/item/reagent_containers/food/snacks/rogue/hcakeuncooked",
	"/obj/item/reagent_containers/food/snacks/rogue/cookie",
	"/obj/item/reagent_containers/food/snacks/rogue/rbread_half",
	"/obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw",
	"/obj/item/reagent_containers/food/snacks/rogue/foodbase/crossbun_raw",
	"/obj/item/reagent_containers/food/snacks/rogue/foodbase/psycrossbun_raw",
	"/obj/item/reagent_containers/food/snacks/rogue/foodbase/cheesebun_raw",
	"/obj/item/reagent_containers/food/snacks/rogue/rbreaduncooked",
	"/obj/item/reagent_containers/food/snacks/rogue/stuffedegg",
	"/obj/item/reagent_containers/food/snacks/rogue/strudel",
	"/obj/item/reagent_containers/food/snacks/rogue/strudel/sugar",
	"/obj/item/reagent_containers/food/snacks/rogue/stuffedegg/cooked",
	"/obj/item/reagent_containers/food/snacks/rogue/foodbase/handpieraw",
	"/obj/item/reagent_containers/food/snacks/rogue/foodbase/crabcakeraw",
	"/obj/item/reagent_containers/food/snacks/rogue/eggplantstuffedraw",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/steak",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/fatty",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/bacon",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/rabbit",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/steak/wolf",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/sausage",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/poultry",
	"/obj/item/reagent_containers/food/snacks/rogue/piedough",
	"/obj/item/reagent_containers/food/snacks/rogue/ricewet",
	"/obj/item/reagent_containers/food/snacks/rogue/meat/spider",
	"/obj/item/reagent_containers/food/snacks/rogue/dough",
	"/obj/item/reagent_containers/food/snacks/rogue/cake_base",
	"/obj/item/reagent_containers/food/snacks/rogue/frostedcakeuncooked",
	"/obj/item/reagent_containers/food/snacks/rogue/preserved",
	"/obj/item/reagent_containers/food/snacks/rogue/fruit",
	"/obj/item/reagent_containers/food/snacks/rogue/veg",
	"/obj/item/reagent_containers/food/snacks/rogue/sandwich",
	"/obj/item/reagent_containers/food/snacks/store",
	"/obj/item/reagent_containers/food/snacks/clothing",
	"/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison",
	"/obj/item/reagent_containers/food/snacks/eoran_aril",
	"/obj/item/reagent_containers/food/snacks/organ",
	"/obj/item/reagent_containers/food/snacks/grown/sugarcane",
	"/obj/item/reagent_containers/food/snacks/grown/sunflower",
	"/obj/item/reagent_containers/food/snacks/grown/rogue",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/swampweed",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/fyritius",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/fyritius/bloodied",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/poppy",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/tealeaves_dry",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/tealeaves_ground",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals",
	"/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals_dried",
	"/obj/item/reagent_containers/food/snacks/grown/manabloom",
	"/obj/item/reagent_containers/food/snacks/smallrat",
	"/obj/item/reagent_containers/food/snacks/grown/tea",
	"/obj/item/reagent_containers/food/snacks/crow",
	"/obj/item/reagent_containers/food/snacks/tallow",
	"/obj/item/reagent_containers/food/snacks/tallow/red",
	"/obj/item/reagent_containers/food/snacks/veg",
	"/obj/item/reagent_containers/food/snacks/butter",
	"/obj/item/reagent_containers/food/snacks/deadmouse",
	"/obj/item/reagent_containers/food/snacks/sugar",
	"/obj/item/reagent_containers/food/snacks/grown/berries",
	"/obj/item/reagent_containers/food/snacks/grown/onion",
	"/obj/item/reagent_containers/food/snacks/grown/cabbage",
	"/obj/item/reagent_containers/food/snacks/grown/potato",
	"/obj/item/reagent_containers/food/snacks/grown/garlick",
	"/obj/item/reagent_containers/food/snacks/fat",
))

/// Ratwood's drinks (init_drinks_with_qualities(): every consumable reagent but soups and its blacklist): its brews
/// (alchemy/alcohol.dm), TG's ale, beer, gin, mead, rum and wine, and the module's coffee, tea and chocolate. A path this
/// world lacks is skipped.
GLOBAL_LIST_INIT(rogue_culinary_drink_paths, list(
	"/datum/reagent/consumable/Acoffee",
	"/datum/reagent/consumable/acorn_powder",
	"/datum/reagent/consumable/allspice",
	"/datum/reagent/consumable/caffeine/coffee",
	"/datum/reagent/consumable/caffeine/coffee_spiced",
	"/datum/reagent/consumable/caffeine/tea",
	"/datum/reagent/consumable/caffeine/tea_spiced",
	"/datum/reagent/consumable/chocolate",
	"/datum/reagent/consumable/ethanol/ale",
	"/datum/reagent/consumable/ethanol/apfelweinheim",
	"/datum/reagent/consumable/ethanol/aqua_vitae",
	"/datum/reagent/consumable/ethanol/aurorian",
	"/datum/reagent/consumable/ethanol/avarmead",
	"/datum/reagent/consumable/ethanol/avarrice",
	"/datum/reagent/consumable/ethanol/baijiu",
	"/datum/reagent/consumable/ethanol/beer",
	"/datum/reagent/consumable/ethanol/beer/emberwine",
	"/datum/reagent/consumable/ethanol/blackberry",
	"/datum/reagent/consumable/ethanol/blackberry/aged",
	"/datum/reagent/consumable/ethanol/blackberry/delectable",
	"/datum/reagent/consumable/ethanol/blackgoat",
	"/datum/reagent/consumable/ethanol/brandy",
	"/datum/reagent/consumable/ethanol/brandy/pear",
	"/datum/reagent/consumable/ethanol/brandy/plum",
	"/datum/reagent/consumable/ethanol/brandy/strawberry",
	"/datum/reagent/consumable/ethanol/brandy/tangerine",
	"/datum/reagent/consumable/ethanol/butterhairs",
	"/datum/reagent/consumable/ethanol/cider",
	"/datum/reagent/consumable/ethanol/cider/pear",
	"/datum/reagent/consumable/ethanol/cider/strawberry",
	"/datum/reagent/consumable/ethanol/elfblue",
	"/datum/reagent/consumable/ethanol/elfred",
	"/datum/reagent/consumable/ethanol/gin",
	"/datum/reagent/consumable/ethanol/green",
	"/datum/reagent/consumable/ethanol/gronnmead",
	"/datum/reagent/consumable/ethanol/hagwoodbitter",
	"/datum/reagent/consumable/ethanol/huangjiu",
	"/datum/reagent/consumable/ethanol/jackberrywine",
	"/datum/reagent/consumable/ethanol/jackberrywine/aged",
	"/datum/reagent/consumable/ethanol/jackberrywine/delectable",
	"/datum/reagent/consumable/ethanol/kgunlager",
	"/datum/reagent/consumable/ethanol/kgunplum",
	"/datum/reagent/consumable/ethanol/kgunsake",
	"/datum/reagent/consumable/ethanol/kgunshochu",
	"/datum/reagent/consumable/ethanol/light",
	"/datum/reagent/consumable/ethanol/limoncello",
	"/datum/reagent/consumable/ethanol/mead",
	"/datum/reagent/consumable/ethanol/mead/spider",
	"/datum/reagent/consumable/ethanol/nred",
	"/datum/reagent/consumable/ethanol/onion",
	"/datum/reagent/consumable/ethanol/plum_wine",
	"/datum/reagent/consumable/ethanol/plum_wine/aged",
	"/datum/reagent/consumable/ethanol/plum_wine/delectable",
	"/datum/reagent/consumable/ethanol/raspberry",
	"/datum/reagent/consumable/ethanol/raspberry/aged",
	"/datum/reagent/consumable/ethanol/raspberry/delectable",
	"/datum/reagent/consumable/ethanol/redwine",
	"/datum/reagent/consumable/ethanol/ricespirit",
	"/datum/reagent/consumable/ethanol/ricewine",
	"/datum/reagent/consumable/ethanol/rtoper",
	"/datum/reagent/consumable/ethanol/rum",
	"/datum/reagent/consumable/ethanol/shejiu",
	"/datum/reagent/consumable/ethanol/spottedhen",
	"/datum/reagent/consumable/ethanol/stonebeards",
	"/datum/reagent/consumable/ethanol/tangerine",
	"/datum/reagent/consumable/ethanol/tangerine/aged",
	"/datum/reagent/consumable/ethanol/tangerine/delectable",
	"/datum/reagent/consumable/ethanol/whitewine",
	"/datum/reagent/consumable/ethanol/wine",
	"/datum/reagent/consumable/ethanol/yaojiu",
	"/datum/reagent/consumable/ethanol/zagul",
	"/datum/reagent/consumable/golden_calendula_tea",
	"/datum/reagent/consumable/poppy_milk",
	"/datum/reagent/consumable/pumpkinspice",
	"/datum/reagent/consumable/shhig",
	"/datum/reagent/consumable/soothing_valerian_tea",
	"/datum/reagent/consumable/spiced_chocolate",
))

/// Ratwood get_cached_drink_flat_icon(): the vessel a drink of each quality is drawn in, worst first.
GLOBAL_LIST_INIT(rogue_culinary_vessels, list(
	"/obj/item/reagent_containers/glass/cup/wooden",
	"/obj/item/reagent_containers/glass/cup",
	"/obj/item/reagent_containers/glass/bottle",
	"/obj/item/reagent_containers/glass/cup/silver",
	"/obj/item/reagent_containers/glass/cup/golden",
))

/// Every food one may love or hate: list("type", "name", "rank" = fare), by fare and name, built once.
/proc/rogue_culinary_foods()
	var/static/list/foods
	if(foods)
		return foods
	var/list/excluded = list()
	for(var/path_text in GLOB.rogue_culinary_food_blacklist)
		var/path = text2path(path_text)
		if(path)
			excluded[path] = TRUE
	var/static/list/excluded_trees = list(
		"/obj/item/reagent_containers/food/snacks/rogue/foodbase",
		"/obj/item/reagent_containers/food/snacks/fish",
		"/obj/item/reagent_containers/food/snacks/eoran_aril",
		"/obj/item/reagent_containers/food/snacks/organ",
		"/obj/item/reagent_containers/food/snacks/crow/dead",
		"/obj/item/reagent_containers/food/snacks/smallrat",
	)
	for(var/path_text in excluded_trees)
		var/path = text2path(path_text)
		if(path)
			for(var/subtype in typesof(path))
				excluded[subtype] = TRUE
	var/spider_honey = text2path("/obj/item/reagent_containers/food/snacks/rogue/honey/spider")
	if(spider_honey)
		for(var/subtype in subtypesof(spider_honey))
			excluded[subtype] = TRUE
	var/list/all_foods = subtypesof(/obj/item/reagent_containers/food/snacks)
	for(var/obj/item/reagent_containers/food/snacks/food_type as anything in all_foods)
		var/slice = initial(food_type.slice_path)
		if(slice)
			excluded[slice] = TRUE
	var/list/names_by_type = list()
	for(var/obj/item/reagent_containers/food/snacks/food_type as anything in all_foods)
		if(!excluded[food_type])
			names_by_type[food_type] = initial(food_type.name)
	foods = list()
	for(var/obj/item/reagent_containers/food/snacks/food_type as anything in rogue_culinary_one_per_name(names_by_type))
		foods += list(list("type" = food_type, "name" = initial(food_type.name), "rank" = initial(food_type.rogue_faretype)))
	sortTim(foods, GLOBAL_PROC_REF(cmp_rogue_culinary))
	return foods

/// Every drink one may love or hate: list("type", "name", "rank" = Ratwood's quality), by quality and name, built once.
/proc/rogue_culinary_drinks()
	var/static/list/drinks
	if(drinks)
		return drinks
	var/list/names_by_type = list()
	for(var/path_text in GLOB.rogue_culinary_drink_paths)
		var/datum/reagent/consumable/drink_type = text2path(path_text)
		if(ispath(drink_type, /datum/reagent/consumable))
			names_by_type[drink_type] = initial(drink_type.name)
	drinks = list()
	for(var/datum/reagent/consumable/drink_type as anything in rogue_culinary_one_per_name(names_by_type))
		drinks += list(list("type" = drink_type, "name" = initial(drink_type.name), "rank" = ROGUE_DRINK_RANK(initial(drink_type.quality))))
	sortTim(drinks, GLOBAL_PROC_REF(cmp_rogue_culinary))
	return drinks

/// Ratwood's one entry per name (type -> name in, types out): the first type of a name stays, unless a later one is its
/// parent.
/proc/rogue_culinary_one_per_name(list/names_by_type)
	var/list/by_name = list()
	. = list()
	for(var/thing_type in names_by_type)
		var/thing_name = names_by_type[thing_type]
		if(!thing_name)
			continue
		var/existing = by_name[thing_name]
		if(!existing)
			by_name[thing_name] = thing_type
			. += thing_type
		else if(ispath(existing, thing_type))
			by_name[thing_name] = thing_type
			. -= existing
			. += thing_type

/// By rank (fare or quality), then by name.
/proc/cmp_rogue_culinary(list/a, list/b)
	if(a["rank"] != b["rank"])
		return a["rank"] - b["rank"]
	return sorttext(b["name"], a["name"])

/// The vessel a drink of this Ratwood quality is drawn in.
/proc/rogue_culinary_vessel(rank)
	var/list/vessels = GLOB.rogue_culinary_vessels
	return text2path(vessels[clamp(rank + 1, 1, length(vessels))])

/// The icon and state of an item type when its icon has that state, else null.
/proc/rogue_culinary_icon(obj/item/item_type)
	if(!ispath(item_type, /obj/item))
		return null
	var/icon_file = initial(item_type.icon)
	var/icon_state = initial(item_type.icon_state)
	if(!icon_file || !icon_exists(icon_file, icon_state))
		return null
	return list(icon_file, icon_state)

/// The thumbnails of the menu's culinary picker (Ratwood drew each food, and each drink as its vessel): a class per food
/// type (its sanitized path) and per drink quality, 32x32.
/datum/asset/spritesheet_batched/rogue_culinary
	name = "rogue_culinary"

/datum/asset/spritesheet_batched/rogue_culinary/create_spritesheets()
	for(var/list/food as anything in rogue_culinary_foods())
		insert_item(sanitize_css_class_name("[food["type"]]"), food["type"])
	for(var/rank in 0 to length(GLOB.rogue_culinary_vessels) - 1)
		insert_item("rogue_drink_[rank]", rogue_culinary_vessel(rank))

/datum/asset/spritesheet_batched/rogue_culinary/proc/insert_item(sprite_name, obj/item/item_type)
	var/list/found = rogue_culinary_icon(item_type)
	if(!found)
		return
	var/item_color = initial(item_type.color)
	var/datum/universal_icon/sprite = uni_icon(found[1], found[2], SOUTH, null, null, istext(item_color) ? item_color : null)
	var/list/size = get_icon_dimensions(found[1])
	if(size["width"] != ICON_SIZE_X || size["height"] != ICON_SIZE_Y)
		sprite.scale(ICON_SIZE_X, ICON_SIZE_Y)
	insert_icon(sprite_name, sprite)

/// The foods and drinks as the menu shows them, in the reader's language where the name dictionary has them: id (the
/// preference value), name, rank, the class of the thumbnail when there is one. Built once per language.
/proc/rogue_charsetup_culinary_catalog(lang)
	var/static/list/catalogs = list()
	if(catalogs[lang])
		return catalogs[lang]
	var/ru = (lang == ROGUE_LANG_RU)
	var/list/foods = list()
	for(var/list/food as anything in rogue_culinary_foods())
		var/food_type = food["type"]
		foods += list(list(
			"id" = "[food_type]",
			"name" = rogue_culinary_name(ru, food["name"]),
			"rank" = food["rank"],
			"icon" = rogue_culinary_icon(food_type) ? sanitize_css_class_name("[food_type]") : null,
		))
	var/list/drinks = list()
	for(var/list/drink as anything in rogue_culinary_drinks())
		var/rank = drink["rank"]
		drinks += list(list(
			"id" = "[drink["type"]]",
			"name" = rogue_culinary_name(ru, drink["name"]),
			"rank" = rank,
			"icon" = rogue_culinary_icon(rogue_culinary_vessel(rank)) ? "rogue_drink_[rank]" : null,
		))
	catalogs[lang] = list("foods" = foods, "drinks" = drinks, "none" = ROGUE_CULINARY_NONE)
	return catalogs[lang]

/// A food's or drink's name for the menu: Russian from the name dictionary when it has it.
/proc/rogue_culinary_name(ru, english)
	english = rogue_plain_name(english)
	return (ru && rogue_translate_name(english)) || english

/// Ratwood's culinary_preferences, one preference per slot: a food or drink type as text.
/datum/preference/choiced/rogue_culinary
	abstract_type = /datum/preference/choiced/rogue_culinary
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	should_update_preview = FALSE
	can_randomize = FALSE
	/// The ROGUE_CULINARY_* key of rogue_culinary the value goes under.
	var/culinary_key
	/// Ratwood get_default_*(): the value before the player picks one.
	var/default_value
	/// The favourite of the same kind, for a hated preference: they may not be the same (Ratwood confirm_food).
	var/opposite_type

/datum/preference/choiced/rogue_culinary/is_accessible(datum/preferences/preferences)
	return ..() && rogue_lobby_enabled()

/// The foods or drinks this slot picks from.
/datum/preference/choiced/rogue_culinary/proc/entries()
	return rogue_culinary_foods()

/datum/preference/choiced/rogue_culinary/init_possible_values()
	. = list()
	for(var/list/entry as anything in entries())
		. += "[entry["type"]]"

/datum/preference/choiced/rogue_culinary/create_default_value()
	var/list/choices = get_choices()
	return (default_value in choices) ? default_value : choices[1]

/// The names for TG's dropdown (its own menu shows these as plain lists).
/datum/preference/choiced/rogue_culinary/compile_constant_data()
	. = ..()
	var/list/names = list()
	for(var/list/entry as anything in entries())
		names["[entry["type"]]"] = capitalize(rogue_plain_name(entry["name"]))
	if(ROGUE_CULINARY_NONE in get_choices())
		names[ROGUE_CULINARY_NONE] = "None"
	.[CHOICED_PREFERENCE_DISPLAY_NAMES] = names

/// Ratwood validate_culinary_preferences(): a hated one that is also the favourite falls back to the default.
/datum/preference/choiced/rogue_culinary/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	if(!rogue_lobby_enabled())
		return
	if(opposite_type && preferences?.read_preference(opposite_type) == value)
		value = create_default_value()
	target.rogue_set_culinary_preference(culinary_key, value == ROGUE_CULINARY_NONE ? null : text2path(value))

/datum/preference/choiced/rogue_culinary/favourite_food
	savefile_key = "rogue_favourite_food"
	culinary_key = ROGUE_CULINARY_FAVOURITE_FOOD
	default_value = "/obj/item/reagent_containers/food/snacks/rogue/bread"

/datum/preference/choiced/rogue_culinary/hated_food
	savefile_key = "rogue_hated_food"
	culinary_key = ROGUE_CULINARY_HATED_FOOD
	default_value = "/obj/item/reagent_containers/food/snacks/badrecipe"
	opposite_type = /datum/preference/choiced/rogue_culinary/favourite_food

/datum/preference/choiced/rogue_culinary/favourite_drink
	savefile_key = "rogue_favourite_drink"
	culinary_key = ROGUE_CULINARY_FAVOURITE_DRINK
	default_value = "/datum/reagent/consumable/ethanol/beer"

/datum/preference/choiced/rogue_culinary/favourite_drink/entries()
	return rogue_culinary_drinks()

/datum/preference/choiced/rogue_culinary/hated_drink
	savefile_key = "rogue_hated_drink"
	culinary_key = ROGUE_CULINARY_HATED_DRINK
	default_value = ROGUE_CULINARY_NONE
	opposite_type = /datum/preference/choiced/rogue_culinary/favourite_drink

/datum/preference/choiced/rogue_culinary/hated_drink/entries()
	return rogue_culinary_drinks()

/// Ratwood hates no drink until one is picked.
/datum/preference/choiced/rogue_culinary/hated_drink/init_possible_values()
	return list(ROGUE_CULINARY_NONE) + ..()

#undef ROGUE_CULINARY_NONE
#undef ROGUE_DRINK_RANK
