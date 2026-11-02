// The Steward's petitions and the warehouse docks (Ratwood code/modules/roguetown/roguestock/steward_petition.dm and the
// warehouse scans of code/controllers/subsystem/rogue/economy/economy.dm):
// - petitions: the Steward spends the Burgher Pledge to have a region post an order of a chosen kind, a few a day, for a smaller
//   payout; a region behind a held road, or just freed, hears none;
// - the warehouse docks: finished items and potions for the Crown's orders are left within a step of a steward's export machine,
//   where filling the order takes them.

/// Kinds of orders the Steward may petition for (Ratwood GLOB.petition_categories): what each is, and the templates it rolls from.
GLOBAL_LIST_INIT(rogue_petition_categories, list(
	"provisions" = list(
		"label" = "Provisions",
		"description" = "Bulk staples - rations, fish, orchard fruit, salt, victuals.",
		"templates" = list("demand_rations", "demand_fishery", "demand_orchard", "demand_salt", "demand_victualling_fleet", "demand_victualling_garrison", "demand_victualling_mines"),
	),
	"materials" = list(
		"label" = "Materials",
		"description" = "Raw materials - smithing stock, construction, textile, joinery, artificery.",
		"templates" = list("demand_smithing", "demand_construction_bulk", "demand_textile", "demand_artificery", "demand_fine_joinery"),
	),
	"arms" = list(
		"label" = "Arms & Harness",
		"description" = "Finished weapons and armor - garrison kit, frontier muster, harness orders.",
		"templates" = list("demand_armaments", "demand_equipment_armaments", "demand_equipment_armor_heavy", "demand_equipment_armor_light", "demand_frontier_gear"),
	),
	"luxuries" = list(
		"label" = "Luxuries",
		"description" = "Court finery, jewelry, name-day tributes, and great feasts.",
		"templates" = list("demand_court_finery", "demand_jewelry", "demand_curio_collection", "demand_birthday_gift", "demand_great_feast_proteins"),
	),
	"alchemy" = list(
		"label" = "Alchemy & Care",
		"description" = "Finished potions, prosthetics, exotic reagents.",
		"templates" = list("demand_alchemical", "demand_alchemical_warband", "demand_prosthetic_run", "demand_exotic"),
	),
	"masterwork" = list(
		"label" = "Masterwork",
		"description" = "Showpiece commissions - artificed panoply, tournament provision, hunt trophies.",
		"templates" = list("demand_artificed_panoply", "demand_tournament_arms", "demand_trophy_heads"),
	),
))

/// Pledge a petition of a kind costs (Ratwood PETITION_COST_*).
/proc/rogue_petition_cost(category_id)
	switch(category_id)
		if("provisions")
			return rogue_value("trade_petition_cost_provisions")
		if("materials")
			return rogue_value("trade_petition_cost_materials")
		if("arms")
			return rogue_value("trade_petition_cost_arms")
		if("luxuries")
			return rogue_value("trade_petition_cost_luxuries")
		if("alchemy")
			return rogue_value("trade_petition_cost_alchemy")
		if("masterwork")
			return rogue_value("trade_petition_cost_masterwork")
	return 0

/datum/controller/subsystem/rogue_trade
	/// Petitions heard on the dawn they were (Ratwood petitions_today, last_petition_day).
	var/petitions_today = 0
	var/petition_dawn = -1

/// Ratwood petitions_remaining_today().
/datum/controller/subsystem/rogue_trade/proc/petitions_left()
	if(petition_dawn != GLOB.rockhill_dawns)
		return rogue_value("trade_petitions_per_day")
	return max(0, rogue_value("trade_petitions_per_day") - petitions_today)

/// Ratwood petition_blocker(): why the region's trade hall will not hear a petition of the kind now, or null.
/datum/controller/subsystem/rogue_trade/proc/petition_blocker(datum/rogue_trade_region/region, category_id)
	if(petitions_left() <= 0)
		return "the trade hall has already heard its petitions today"
	var/list/category = GLOB.rogue_petition_categories[category_id]
	if(!category)
		return "unknown petition category"
	if(!region)
		return "unknown region"
	if(region.blockaded)
		return "[region.name] is blockaded - the road is closed to envoys"
	if(region.dawn_last_cleared >= 0)
		var/since = GLOB.rockhill_dawns - region.dawn_last_cleared
		if(since < rogue_value("trade_petition_recovery_days"))
			return "[region.name]'s contacts are still scattered - wait [rogue_value("trade_petition_recovery_days") - since]d more"
	if(length(orders) >= rogue_value("trade_orders_cap"))
		return "the warehouse manifest is full - fulfill orders first"
	var/open = open_orders_of(region)
	if(open >= rogue_value("trade_orders_per_region"))
		return "[region.name] already has [open] active orders"
	if(!length(region_templates(region, category["templates"])))
		return "[region.name]'s trade hall does not deal in [category["label"]]"
	var/datum/bank_account/rogue/pledge = SSrogue_treasury.burgher_pledge
	if(!pledge)
		return "the Burgher Pledge is not yet established"
	var/cost = rogue_petition_cost(category_id)
	if(!pledge.has_money(cost))
		return "the Burgher Pledge cannot cover [cost]m"
	return null

/// Ratwood petition_for_order(): the pledge pays and the region posts an order of the kind, picked by weight, for less.
/datum/controller/subsystem/rogue_trade/proc/petition(mob/user, datum/rogue_trade_region/region, category_id)
	var/blocker = petition_blocker(region, category_id)
	if(blocker)
		to_chat(user, span_warning("Petition refused: [blocker]."))
		return FALSE
	var/list/category = GLOB.rogue_petition_categories[category_id]
	var/cost = rogue_petition_cost(category_id)
	if(!SSrogue_treasury.draw_pledge(cost, "Steward petition - [category["label"]] in [region.name]"))
		to_chat(user, span_warning("Petition refused: pledge could not be drawn."))
		return FALSE
	if(petition_dawn != GLOB.rockhill_dawns)
		petitions_today = 0
		petition_dawn = GLOB.rockhill_dawns
	petitions_today++
	var/datum/rogue_standing_order/order = post_order(pick_weight(region_templates(region, category["templates"])), region, TRUE)
	if(!order)
		SSrogue_treasury.refund_pledge(cost, "Steward petition refund - empty roll")
		petitions_today--
		to_chat(user, span_warning("Petition rolled empty - the trade hall returns your pledge."))
		return FALSE
	log_game("PETITION: [key_name(user)] petitioned [category["label"]] in [region.name]: [order.title] (+[order.payout]m, -[cost] pledge)")
	to_chat(user, span_notice("Petition accepted: [order.title] posted at the warehouse for [order.payout]m."))
	return TRUE

/// The petitions, for the nerve master's window.
/datum/controller/subsystem/rogue_trade/proc/petition_ui_data()
	var/list/categories = list()
	for(var/category_id in GLOB.rogue_petition_categories)
		var/list/category = GLOB.rogue_petition_categories[category_id]
		var/list/blockers = list()
		for(var/region_id in regions)
			blockers[region_id] = petition_blocker(regions[region_id], category_id) || ""
		categories += list(list(
			"id" = category_id,
			"label" = category["label"],
			"description" = category["description"],
			"cost" = rogue_petition_cost(category_id),
			"blockers" = blockers,
		))
	return list(
		"categories" = categories,
		"left" = petitions_left(),
		"payout_percent" = round(rogue_value("trade_petition_payout") * 100),
	)

// The warehouse docks.

/// The steward's export machines, which mark the warehouse docks (Ratwood GLOB.steward_export_machines).
GLOBAL_LIST_EMPTY(rogue_export_docks)

/obj/structure/roguemachine/steward_export/Initialize(mapload)
	. = ..()
	GLOB.rogue_export_docks += src

/obj/structure/roguemachine/steward_export/Destroy()
	GLOB.rogue_export_docks -= src
	return ..()

/**
 * Finished items and potions of the order left at the warehouse docks, within a step of a steward's export machine, up to what
 * the order wants (Ratwood scan_equipment_availability(), scan_potion_availability()): an item counts once, a container of a
 * potion by how many units of the potion it holds. Returns good -> list("units" =, "items" =) for the order's finished goods.
 */
/datum/rogue_standing_order/proc/finished_at_docks()
	var/list/found = list()
	var/list/wanted = list()
	for(var/datum/rogue_trade_good/good as anything in required)
		if(good.finished())
			wanted += good
			found[good] = list("units" = 0, "items" = list())
	if(!length(wanted))
		return found
	var/list/claimed = list()
	for(var/obj/structure/roguemachine/steward_export/dock as anything in GLOB.rogue_export_docks)
		for(var/obj/item/thing in view(1, dock))
			if(claimed[thing])
				continue
			for(var/datum/rogue_trade_good/good as anything in wanted)
				var/list/entry = found[good]
				if(entry["units"] >= required[good])
					continue
				var/units = good.dock_units(thing)
				if(units <= 0)
					continue
				entry["units"] += units
				var/list/items = entry["items"]
				items += thing
				claimed[thing] = TRUE
				break
	for(var/datum/rogue_trade_good/good as anything in wanted)
		var/list/entry = found[good]
		entry["units"] = min(required[good], round(entry["units"]))
	return found

/// Takes the finished goods an order was filled with from the docks (Ratwood consume_equipment_payload(), consume_potion_payload()).
/datum/rogue_standing_order/proc/consume_at_docks(list/found, units)
	if(!found || units <= 0)
		return
	for(var/obj/item/thing as anything in found["items"])
		if(!QDELETED(thing))
			qdel(thing)
