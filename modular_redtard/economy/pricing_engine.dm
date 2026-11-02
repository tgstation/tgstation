/**
 * Ratwood's pricing engine (code/modules/roguetown/roguestock/pricing_engine.dm): the worth of what is made is derived from what
 * it is made of. The raw goods of the realm are priced by their trade price (and a few alloys and wood by theirs); every anvil
 * and crafting recipe of the port prices its result at the cost of its materials, resolved through the recipes that make them,
 * times the markup of its market category, per unit made. A thing the porter left without a price takes its derived price
 * (get_real_price()); trade goods sold as finished items take theirs as their trade price.
 * Ratwood caches the result in a file between rounds; here it is worked out once at the start of a medieval round.
 */

/// Item type -> mammons derived from its recipe, or a raw good's trade price (Ratwood GLOB.derived_sellprices).
GLOBAL_LIST_EMPTY(rogue_derived_prices)
/// Item type -> its market category (Ratwood GLOB.derived_categories), for the market machines.
GLOBAL_LIST_EMPTY(rogue_derived_categories)

/// The markup a market category lays on the cost of materials (Ratwood item_cat_markups, PRICING_ENGINE_DEFAULT_MARKUP).
/proc/rogue_category_markup(category)
	switch(category)
		if("Armor (Light & Cloth)")
			return rogue_value("trade_markup_light_armor")
		if("Garments (Common)", "Garments (Misc)", "Garments (Masks)")
			return rogue_value("trade_markup_garment")
		if("Garments (Fine)")
			return rogue_value("trade_markup_fine_garment")
		if("Foodstuffs (Fresh)")
			return rogue_value("trade_markup_fresh_food")
		if("Foodstuffs (Preserved)")
			return rogue_value("trade_markup_preserved_food")
		if("Potions")
			return rogue_value("trade_markup_potion")
		if("Books & Writs", "Instruments")
			return rogue_value("trade_markup_book")
		if("Trophies")
			return rogue_value("trade_markup_trophy")
		if("Raw Materials (Mineral)", "Raw Materials (Organic)", "Reagents (Alchemical)", "Reagents (Arcane)", "Arcyne Gears & Implements", "Salvage & Byproducts", "Livestock", "Miscellaneous")
			return rogue_value("trade_markup_raw")
		if("Armor (Helmets)", "Armor (Chestpieces)", "Armor (Legs)", "Armor (Neck)", "Armor (Boots)", "Armor (Gloves)", "Armor (Masks)", "Armor (Bracers)", "Armor (Belts)", "Armor (Barding)")
			return rogue_value("trade_markup_crafted")
		if("Weapons (Swords)", "Weapons (Daggers & Knives)", "Weapons (Axes)", "Weapons (Spears & Polearms)", "Weapons (Maces & Hammers)", "Weapons (Flails & Whips)", "Weapons (Shields)", "Weapons (Ammunition)")
			return rogue_value("trade_markup_crafted")
		if("Tools (Cookware)", "Tools (Field & Mining)", "Tools (Smithing & Workshop)", "Tools (Lights & Sundries)", "Tools (Rogue & Lockpicks)", "Valuables (Rings)", "Valuables (Holy & Amulets)")
			return rogue_value("trade_markup_crafted")
		if("Decoration", "Pottery & Ceramics", "Components", "Smithing (Misc)", "Engineering (Machinery)", "Engineering (Construction)", "Engineering (Combat)", "Engineering (Triggers & Control)", "Engineering (Misc)")
			return rogue_value("trade_markup_crafted")
	return rogue_value("trade_markup_default")

/// The parent of a type path, by its text (Ratwood type2parent()); null for a root.
/proc/rogue_parent_type(path)
	var/text = "[path]"
	var/cut = findlasttext(text, "/")
	return cut > 1 ? text2path(copytext(text, 1, cut)) : null

/// The derived price of a type, or of its nearest parent that has one (Ratwood lookup_derived_subtype_price()).
/proc/rogue_derived_price(path)
	var/list/prices = GLOB.rogue_derived_prices
	if(!length(prices))
		return 0
	while(path)
		if(prices[path])
			return prices[path]
		path = rogue_parent_type(path)
	return 0

/// The market category of a type, or of its nearest parent that has one (Ratwood get_derived_category()).
/proc/rogue_derived_category(path)
	var/list/categories = GLOB.rogue_derived_categories
	while(path && length(categories))
		if(categories[path])
			return categories[path]
		path = rogue_parent_type(path)
	return null

/// A thing the porter left without a price is worth its derived price, drifting like any other (Ratwood get_real_price()).
/obj/item/get_real_price()
	if(!sellprice && !initial(sellprice))
		var/derived = rogue_derived_price(type)
		if(derived)
			sellprice = derived
			randomize_price()
	return ..()

/**
 * One run of the engine (Ratwood init_material_baseline_prices(), init_derived_sellprices(), derived_pass() and
 * resolve_component_unit_cost()): material baselines, then every recipe's result priced from its materials.
 */
/datum/rogue_pricing_engine
	/// Item type -> mammons of a raw material.
	var/list/baselines = list()
	/// Item type -> the anvil recipe that makes it, and -> the crafting recipe that makes it.
	var/list/by_anvil = list()
	var/list/by_craft = list()
	/// Item type -> its resolved unit cost; and the types being resolved now, against recipe cycles.
	var/list/cost_cache = list()
	var/list/visiting = list()
	/// Results priced by their own trade price, which no recipe overrides.
	var/list/fixed = list()
	var/list/prices = list()
	var/list/categories = list()

/// Ratwood init_material_baseline_prices(): raw goods by their trade price, alloys, wood and gears from them.
/datum/rogue_pricing_engine/proc/set_baselines(list/goods)
	for(var/id in goods)
		var/datum/rogue_trade_good/good = goods[id]
		if(!good.item_type || good.base_price <= 0 || good.finished())
			continue
		baselines[good.item_type] = good.base_price
		fixed[good.item_type] = good
		prices[good.item_type] = good.base_price
	var/iron = baselines[/obj/item/ingot/iron] || 0
	var/copper = baselines[/obj/item/ingot/copper] || 0
	var/tin = baselines[/obj/item/ingot/tin] || 0
	var/steel = baselines[/obj/item/ingot/steel] || 0
	var/silver = baselines[/obj/item/ingot/silver] || 0
	var/wood = baselines[/obj/item/grown/log/tree/small] || 0
	var/list/derived_baselines = list(
		"/obj/item/ingot/bronze" = copper * rogue_value("trade_alloy_bronze_copper") + tin * rogue_value("trade_alloy_bronze_tin"),
		"/obj/item/ingot/silverblessed" = silver * rogue_value("trade_alloy_blessed_silver"),
		"/obj/item/ingot/silverblessed/bullion" = silver * rogue_value("trade_alloy_blessed_silver"),
		"/obj/item/ingot/steelholy" = steel * rogue_value("trade_alloy_holy_steel"),
		"/obj/item/ingot/blacksteel" = steel * rogue_value("trade_alloy_blacksteel_steel") + silver * rogue_value("trade_alloy_blacksteel_silver"),
		"/obj/item/ingot/gilbranze" = steel * rogue_value("trade_alloy_gilbranze"),
		"/obj/item/ingot/aaslag" = iron * rogue_value("trade_alloy_aaslag"),
		"/obj/item/grown/log/tree/stick" = rogue_value("trade_price_stick"),
		"/obj/item/natural/wood/plank" = wood * rogue_value("trade_plank_wood"),
		"/obj/item/natural/glass" = baselines[/obj/item/natural/clay/glassbatch] || 0,
		"/obj/item/roguegear" = steel * rogue_value("trade_gear_steel"),
		"/obj/item/carvedgem/chitin/rawchitin" = rogue_value("trade_price_chitin"),
	)
	for(var/path_text in derived_baselines)
		var/path = text2path(path_text)
		var/price = round(derived_baselines[path_text])
		if(path && price > 0)
			baselines[path] = price

/// The first result of a crafting recipe and how many of it the recipe makes (Ratwood pick_recipe_result(), recipe_result_yield()).
/datum/rogue_pricing_engine/proc/craft_yield(datum/crafting_recipe/roguetown/recipe)
	var/made = 1
	for(var/extra in recipe.rogue_results)
		if(extra == recipe.result)
			made++
	return made

/// Ratwood resolve_component_unit_cost(): what one unit of a material costs: its baseline, or the cost of the recipe that makes it.
/datum/rogue_pricing_engine/proc/unit_cost(path, depth = 0)
	if(!path)
		return 0
	if(!isnull(cost_cache[path]))
		return cost_cache[path]
	var/cost = baselines[path]
	if(!cost)
		for(var/known in baselines)
			if(ispath(path, known))
				cost = baselines[known]
				break
	if(cost)
		cost_cache[path] = cost
		return cost
	if(depth >= rogue_value("trade_price_recursion_max") || visiting[path])
		return 0
	visiting[path] = TRUE
	var/resolved = 0
	var/datum/anvil_recipe/anvil = by_anvil[path] || subtype_match(by_anvil, path)
	var/datum/crafting_recipe/roguetown/craft = anvil ? null : (by_craft[path] || subtype_match(by_craft, path))
	if(anvil)
		var/sub_cost = unit_cost(anvil.req_bar, depth + 1)
		for(var/extra in anvil.additional_items)
			sub_cost += unit_cost(extra, depth + 1)
		resolved = round(sub_cost / max(1, anvil.createditem_num))
	else if(craft)
		var/sub_cost = 0
		for(var/req in craft.reqs)
			var/amount = craft.reqs[req]
			sub_cost += unit_cost(req, depth + 1) * (isnum(amount) ? amount : 1)
		resolved = round(sub_cost / craft_yield(craft))
	visiting -= path
	cost_cache[path] = resolved
	return resolved

/// The recipe of the nearest parent type a recipe makes, when none makes the type itself (Ratwood's ispath() fallback).
/datum/rogue_pricing_engine/proc/subtype_match(list/recipes, path)
	for(var/known in recipes)
		if(ispath(path, known))
			return recipes[known]
	return null

/// Ratwood derive_price_from_cost(): materials times the category's markup, per unit made.
/datum/rogue_pricing_engine/proc/derive(material_cost, category, made)
	if(material_cost <= 0)
		return 0
	return max(1, round(material_cost * rogue_category_markup(category) / max(1, made)))

/// Ratwood register_derived_price(): the cheapest recipe of a thing sets its price.
/datum/rogue_pricing_engine/proc/register(path, price, category)
	if(!path || price <= 0 || fixed[path])
		return
	if(prices[path] && prices[path] <= price)
		return
	prices[path] = price
	categories[path] = category

/// Ratwood derived_pass(): every anvil and crafting recipe prices its result.
/datum/rogue_pricing_engine/proc/derive_all()
	for(var/datum/anvil_recipe/anvil as anything in GLOB.rogue_anvil_recipes)
		if(anvil.created_item && anvil.req_bar && !by_anvil[anvil.created_item])
			by_anvil[anvil.created_item] = anvil
	var/list/crafts = list()
	for(var/datum/crafting_recipe/roguetown/craft in GLOB.crafting_recipes + GLOB.cooking_recipes)
		crafts += craft
		if(craft.result && !by_craft[craft.result])
			by_craft[craft.result] = craft
	for(var/datum/anvil_recipe/anvil as anything in GLOB.rogue_anvil_recipes)
		if(!anvil.created_item || !anvil.req_bar || fixed[anvil.created_item])
			continue
		var/category = anvil.display_category || "Smithing (Misc)"
		var/cost = unit_cost(anvil.req_bar)
		for(var/extra in anvil.additional_items)
			cost += unit_cost(extra)
		register(anvil.created_item, derive(cost, category, anvil.createditem_num), category)
		CHECK_TICK
	for(var/datum/crafting_recipe/roguetown/craft as anything in crafts)
		if(!craft.result || fixed[craft.result])
			continue
		var/category = GLOB.rogue_recipe_categories["[craft.type]"] || "Miscellaneous"
		var/cost = 0
		for(var/req in craft.reqs)
			var/amount = craft.reqs[req]
			cost += unit_cost(req) * (isnum(amount) ? amount : 1)
		register(craft.result, derive(cost, category, craft_yield(craft)), category)
		CHECK_TICK

/**
 * Runs the pricing engine over the realm's goods (Ratwood init_pricing_engine()): fills the derived prices, then every trade
 * good sold as a finished item takes the derived price of its item as its trade price. Returns how many prices were derived.
 */
/proc/rogue_run_pricing_engine(list/goods)
	var/datum/rogue_pricing_engine/engine = new
	engine.set_baselines(goods)
	engine.derive_all()
	GLOB.rogue_derived_prices = engine.prices
	GLOB.rogue_derived_categories = engine.categories
	for(var/id in goods)
		var/datum/rogue_trade_good/good = goods[id]
		if(good.derive_price && good.item_type)
			var/derived = rogue_derived_price(good.item_type)
			if(derived > 0)
				good.base_price = derived
	. = length(engine.prices)
	qdel(engine)
