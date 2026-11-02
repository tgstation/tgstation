// The ships' trade beyond bulk cargo (Ratwood merchant_trade_kinship.dm, merchant/trade/trade_ship.dm roll_victualling_lines()
// and roll_cultural_stock(), fulfillment_crate.dm):
// - kinship: the merchant's homeland sends a ship every day; its captains sell cheaper to the merchant's company and pay more
//   for what they buy; an agent of the company is kin to the ships of their own homeland when buying;
// - provisions: ships buy dishes of their realm's taste and drinks by the keg (spirits by the sealed bottle) at set prices;
// - cultural stock: ships sell packs of their realm's goods at a discount;
// - the trading company's seal: whatever the company sold (GOLDFACE, catalogs, ships' cargo) is sealed, and no captain buys
//   Company stock back.
// Ratwood claims kinship nowhere (dead code there); Azure Peak claims it when the merchant arrives, as here.

/// A character's homeland -> the foreign realm whose ships are their kin (Ratwood origin_name_to_realm_id(), by the homelands of
/// homelands/homelands.dm).
GLOBAL_LIST_INIT(rogue_homeland_realms, list(
	"Avar" = "aavnr",
	"Zybantine" = "zybantium",
	"Grenzelhoft" = "grenzelhoft",
	"Otava" = "otava",
	"Kazengun" = "kazengun",
	"Hammerhold" = "hammerhold",
	"Etrusca" = "etrusca",
	"Gronn" = "gronn",
	"The Underdark" = "underdark",
	"Naledi" = "naledi",
))

/obj/item
	/// Sold by the trading company: foreign captains will not buy it back (Ratwood atc_sealed).
	var/rogue_company_seal = FALSE

/obj/item/examine(mob/user)
	. = ..()
	if(rogue_company_seal && rogue_economy_enabled())
		. += span_info("It bears the seal of the Ferentian Trading Company.")

/// The foreign realm of a character's homeland, if its ships trade here.
/proc/rogue_homeland_realm(mob/living/person)
	var/mob/living/carbon/human/human_person = person
	if(!istype(human_person) || !human_person.rogue_homeland)
		return null
	return GLOB.rogue_homeland_realms[human_person.rogue_homeland.name]

/datum/controller/subsystem/rogue_trade
	/// The merchant's homeland among the foreign realms (Ratwood current_kinship_realm) and its name.
	var/kinship_realm
	var/kinship_homeland

/// A merchant arrives: their homeland becomes the company's kin (Azure Peak merchant.dm after_spawn()).
/datum/controller/subsystem/rogue_trade/proc/on_job_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(job?.title == JOB_ROCKHILL_MERCHANT)
		claim_kinship(spawned)

/**
 * Ratwood try_claim_kinship_for(): the merchant's homeland becomes the company's kin, or none if it is no foreign realm that
 * trades here; a kin ship is made to wait offshore at once.
 */
/datum/controller/subsystem/rogue_trade/proc/claim_kinship(mob/living/merchant)
	var/realm_id = rogue_homeland_realm(merchant)
	if(!realms[realm_id])
		realm_id = null
	if(realm_id == kinship_realm)
		return
	kinship_realm = realm_id
	var/mob/living/carbon/human/human_merchant = merchant
	kinship_homeland = realm_id ? human_merchant.rogue_homeland.name : null
	if(realm_id)
		ensure_kin_ship()

/// Ratwood ensure_kin_ship_available(): a ship of the kin waits offshore, taking the place of another if need be.
/datum/controller/subsystem/rogue_trade/proc/ensure_kin_ship()
	var/list/others = list()
	for(var/datum/rogue_trade_ship/ship as anything in offshore_ships())
		if(ship.kin())
			return
		others += ship
	if(length(others))
		var/datum/rogue_trade_ship/swap_out = pick(others)
		ships -= swap_out
		qdel(swap_out)
	ships += new /datum/rogue_trade_ship(realms[kinship_realm], ++next_ship_id)

/// Ratwood get_kinship_sell_mult(): a kin ship pays more for what it buys.
/datum/controller/subsystem/rogue_trade/proc/kin_sell_mult(datum/rogue_trade_ship/ship)
	return ship?.kin() ? rogue_value("trade_kinship_sell_mult") : 1

/**
 * Ratwood get_effective_buy_mult(): a kin ship sells cheaper to the company, and any ship to an agent of the company (the
 * shophand or a chartered agent) who hails from its realm.
 */
/datum/controller/subsystem/rogue_trade/proc/kin_buy_mult(datum/rogue_trade_ship/ship, mob/living/buyer)
	if(!ship)
		return 1
	if(ship.kin())
		return rogue_value("trade_kinship_buy_mult")
	if(isliving(buyer) && (buyer.mind?.assigned_role?.title == JOB_ROCKHILL_SHOPHAND || HAS_TRAIT(buyer, TRAIT_AGENT_MERCHANT)) && rogue_homeland_realm(buyer) == ship.realm.id)
		return rogue_value("trade_kinship_buy_mult")
	return 1

/// The first docked ship still buying this dish or bottle, and its provision line (Ratwood find_dish_match()).
/datum/controller/subsystem/rogue_trade/proc/find_provision(item_type)
	for(var/datum/rogue_trade_ship/ship as anything in docked_ships())
		for(var/list/line as anything in ship.provisions)
			if(line[ROGUE_LINE_TYPE] == item_type && line[ROGUE_LINE_DONE] < line[ROGUE_LINE_TARGET])
				return list(ship, line)
	return null

/// Ratwood brew_recipe_for_reagent(): the brew that makes a reagent.
/proc/rogue_brew_recipe_for(reagent)
	var/static/list/by_reagent
	if(!by_reagent)
		by_reagent = list()
		for(var/datum/brewing_recipe/recipe as anything in subtypesof(/datum/brewing_recipe))
			var/made = initial(recipe.reagent_to_brew)
			if(made && !by_reagent[made])
				by_reagent[made] = recipe
	return by_reagent[reagent]

/// Ratwood brew_recipe_needs_distiller(): a spirit is distilled somewhere along its chain of brews.
/proc/rogue_brew_needs_distiller(datum/brewing_recipe/recipe)
	for(var/i in 1 to 10)
		if(!recipe)
			return FALSE
		if(initial(recipe.heat_required))
			return TRUE
		var/prereq = initial(recipe.pre_reqs)
		if(!prereq)
			return FALSE
		recipe = rogue_brew_recipe_for(prereq)
	return FALSE

/// Ratwood roll_victualling_lines(): fresh dishes, preserved ones and drinks of the realm's taste.
/datum/rogue_trade_ship/proc/roll_provisions()
	var/list/pools = GLOB.rogue_realm_provisions[realm.id]
	if(!pools)
		return
	add_provisions(pools["fresh"], rand(rogue_value("trade_provisions_fresh_min"), rogue_value("trade_provisions_fresh_max")), ROGUE_PROVISION_FRESH)
	add_provisions(pools["preserved"], rand(rogue_value("trade_provisions_preserved_min"), rogue_value("trade_provisions_preserved_max")), ROGUE_PROVISION_PRESERVED)
	add_drinks(pools["drinks"], rand(rogue_value("trade_provisions_drinks_min"), rogue_value("trade_provisions_drinks_max")))

/// Ratwood build_victualling_lines(): dishes picked from the realm's pool, a few each by the ship's size, at their set price.
/datum/rogue_trade_ship/proc/add_provisions(list/pool, lines, tag)
	var/list/picks = islist(pool) ? pool.Copy() : list()
	for(var/i in 1 to lines)
		if(!length(picks))
			break
		var/list/entry = pick_n_take(picks)
		var/obj/item/dish = text2path(entry["path"])
		if(!ispath(dish, /obj/item))
			continue
		provisions += list(list(
			ROGUE_LINE_TYPE = dish,
			ROGUE_LINE_NAME = initial(dish.name),
			ROGUE_LINE_TAG = tag,
			ROGUE_LINE_TARGET = max(1, round(rand(entry["min"], entry["max"]) * scale())),
			ROGUE_LINE_DONE = 0,
			ROGUE_LINE_PRICE = max(1, entry["price"]),
		))

/**
 * Ratwood build_drinks_lines(): drinks of the realm's taste, by the keg at the brew's worth with a markup, or for spirits that
 * need a distiller by the sealed bottle.
 */
/datum/rogue_trade_ship/proc/add_drinks(list/pool, lines)
	var/list/picks = islist(pool) ? pool.Copy() : list()
	for(var/i in 1 to lines)
		if(!length(picks))
			break
		var/list/entry = pick_n_take(picks)
		var/datum/brewing_recipe/recipe = text2path(entry["recipe"])
		if(!ispath(recipe, /datum/brewing_recipe))
			continue
		var/bottle = initial(recipe.output_bottle_type)
		if(!bottle)
			continue
		var/price_mod = entry["price_mod"] || 1
		var/volume = entry["keg_mult"] || 1
		var/sell_value = initial(recipe.sell_value)
		var/by_bottle = rogue_brew_needs_distiller(recipe)
		var/units
		var/price
		if(by_bottle)
			units = rand(rogue_value("trade_provisions_bottles_min"), rogue_value("trade_provisions_bottles_max"))
			price = sell_value / max(1, initial(recipe.brewed_amount)) * rogue_value("trade_spirits_markup") * price_mod
		else
			units = rand(rogue_value("trade_provisions_kegs_min"), rogue_value("trade_provisions_kegs_max"))
			price = sell_value * rogue_value("trade_drinks_markup") * price_mod
		provisions += list(list(
			ROGUE_LINE_TYPE = bottle,
			ROGUE_LINE_NAME = "[by_bottle ? "bottle" : "keg"] of [initial(recipe.bottle_name)]",
			ROGUE_LINE_TAG = ROGUE_PROVISION_DRINKS,
			ROGUE_LINE_TARGET = max(1, round(units * volume * scale())),
			ROGUE_LINE_DONE = 0,
			ROGUE_LINE_PRICE = max(1, round(price)),
			ROGUE_LINE_BY_BOTTLE = by_bottle,
		))

/datum/rogue_trade_ship/proc/ui_provisions()
	. = list()
	for(var/list/line as anything in provisions)
		. += list(list(
			"name" = line[ROGUE_LINE_NAME],
			"tag" = line[ROGUE_LINE_TAG],
			"target" = line[ROGUE_LINE_TARGET],
			"done" = line[ROGUE_LINE_DONE],
			"price" = line[ROGUE_LINE_PRICE],
			"by_bottle" = !!line[ROGUE_LINE_BY_BOTTLE],
		))

/**
 * Ratwood roll_cultural_stock(): packs of its realm's culture the ship carries, a few of each, some only by chance. Packs the
 * porter has not brought are skipped.
 */
/datum/rogue_trade_ship/proc/roll_cultural_stock()
	var/list/pool = GLOB.rogue_realm_cultural_stock[realm.id]
	if(!pool)
		return
	for(var/list/entry as anything in pool)
		var/pack_type = text2path(entry["pack"])
		var/datum/rogue_supply_pack/pack = GLOB.rogue_supply_packs[pack_type]
		if(!pack || !prob(entry["chance"]))
			continue
		var/qty = rand(entry["min"], entry["max"])
		if(qty <= 0)
			continue
		cultural_stock += list(list(
			"pack" = pack_type,
			"name" = pack.name,
			"qty" = qty,
			"cost" = round(pack.cost * (100 - rogue_value("trade_cultural_discount")) / 100),
		))

/datum/rogue_trade_ship/proc/ui_cultural_stock()
	. = list()
	for(var/list/entry as anything in cultural_stock)
		. += list(list("pack" = "[entry["pack"]]", "name" = entry["name"], "qty" = entry["qty"], "cost" = entry["cost"]))

/// The ship's line of cultural stock of a pack, while it has some left.
/datum/rogue_trade_ship/proc/cultural_line(pack_type)
	for(var/list/entry as anything in cultural_stock)
		if(entry["pack"] == pack_type && entry["qty"] > 0)
			return entry
	return null
