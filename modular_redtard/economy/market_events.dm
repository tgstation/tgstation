// Swings of the market (Ratwood code/modules/roguetown/roguestock/economic_events.dm and blockade.dm, the economic events and
// blockades of code/controllers/subsystem/rogue/economy/, merchant/trade/realm_condition.dm):
// - economic events: shortages and gluts move the price of their goods for some dawns; a shortage posts an urgent order and
//   ends early once the realm ships its regions enough of the goods;
// - blockades: raiders cut the road to a region; its imports cost double, its exports fetch half, its orders wait, and the
//   Crown loses caravans on the held road every dawn;
// - conditions of the foreign realms: wars, harvests and fairs change what their ships buy and sell this round.
// Event data is Ratwood's, generated into economy/trade_extra_data.dm.
//
// Not as in Ratwood: the defense contract that breaks a blockade is not ported (Б34), so a blockade lifts by itself after
// trade_blockade_days dawns; clear_blockade() is the hook for that contract. Ratwood's banditry losses follow the danger of
// threat regions, which are not ported either: here every held road counts as a dangerous region.

/// An economic event that raises the price of its goods (Ratwood ECON_EVENT_SHORTAGE); a glut is "oversupply" in the data.
#define ROGUE_EVENT_SHORTAGE "shortage"
/// What a condition of a foreign realm does to a cargo line of its ships (Ratwood CONDITION_OP_*), as the data names it.
#define ROGUE_CONDITION_MODIFY "modify"
#define ROGUE_CONDITION_REMOVE "remove"
#define ROGUE_CONDITION_ADD "add"
/// Urgent order sizes by the trade price of a good (Ratwood spawn_urgent_for_event()): dear goods come in few units.
#define URGENT_DEAR_PRICE 40
#define URGENT_MIDDLING_PRICE 15
/// A condition that adds a cargo line names no quantity or price: Ratwood's small bulk line at a fair price.
#define CONDITION_DEFAULT_QTY_MIN 7
#define CONDITION_DEFAULT_QTY_MAX 13
#define CONDITION_DEFAULT_PRICE_MOD 0.85

/// Road to each region of the realm, as Rockhill's map knows them (Ratwood map_adjustment_rockhill.dm blockade_route_map).
GLOBAL_LIST_INIT(rogue_blockade_routes, list(
	"kingsfield" = "Murderwood South",
	"rosawood" = "Murderwood North",
	"blackholt" = "Murderwood South",
	"heartfelt" = "Murderwood North",
	"rockhill" = "Northern Terrorbog",
	"saltwick" = "Western Terrorbog",
	"bleakcoast" = "Southern Terrorbog",
	"northfort" = "Terrorbog Sunken Mire",
	"hagenwald" = "Terrorbog Sunken Mire",
	"daftsmarch" = "Terrorbog Sunken Mire",
))

/// Regions a blockade never falls on again in the middle of the round (Ratwood blockade_replenish_eligible: Kingsfield).
GLOBAL_LIST_INIT(rogue_blockade_no_replenish, list("kingsfield"))

/// Road -> the raiders able to hold it, by weight (Ratwood faction_weights of Rockhill's threat regions, only the factions
/// that can_blockade).
GLOBAL_LIST_INIT(rogue_blockade_raiders, list(
	"Murderwood North" = list("highwayman" = 30, "stray_deadite" = 20),
	"Murderwood South" = list("highwayman" = 25, "stray_deadite" = 20),
	"Northern Terrorbog" = list("bogman" = 40, "bog_deadite" = 20),
	"Western Terrorbog" = list("bogman" = 30, "bog_deadite" = 10),
	"Southern Terrorbog" = list("bogman" = 40, "bog_deadite" = 30, "lich_deadite" = 10),
	"Terrorbog Sunken Mire" = list("drow" = 30, "lich_deadite" = 15),
))

/// Raiders -> list(their band, their name) (Ratwood quest factions' group_word and name_plural).
GLOBAL_LIST_INIT(rogue_raider_names, list(
	"highwayman" = list("gang", "highwaymen"),
	"stray_deadite" = list("horde", "stray deadites"),
	"bogman" = list("warband", "bogmen"),
	"bog_deadite" = list("horde", "bog deadites"),
	"lich_deadite" = list("horde", "lich-bound deadites"),
	"drow" = list("patrol", "drow raiders"),
))

/// Price factor of an event's tier (Ratwood ECON_SHORTAGE_*, ECON_OVERSUPPLY_*).
/proc/rogue_event_price_mod(tier)
	switch(tier)
		if("shortage_minor")
			return rogue_value("trade_event_shortage_minor")
		if("shortage_normal")
			return rogue_value("trade_event_shortage_normal")
		if("shortage_major")
			return rogue_value("trade_event_shortage_major")
		if("shortage_severe")
			return rogue_value("trade_event_shortage_severe")
		if("shortage_crisis")
			return rogue_value("trade_event_shortage_crisis")
		if("oversupply_minor")
			return rogue_value("trade_event_glut_minor")
		if("oversupply_normal")
			return rogue_value("trade_event_glut_normal")
		if("oversupply_major")
			return rogue_value("trade_event_glut_major")
		if("oversupply_severe")
			return rogue_value("trade_event_glut_severe")
		if("oversupply_glut")
			return rogue_value("trade_event_glut_extreme")
	return 1

/**
 * A shortage or a glut (Ratwood /datum/economic_event): for some dawns the price of its goods is multiplied, at the regions,
 * the stockpile and in the Crown's orders. Data in economy/trade_extra_data.dm.
 */
/datum/rogue_economic_event
	var/name = ""
	var/description = ""
	var/announcement = ""
	/// Ids of the trade goods whose price it moves.
	var/list/affected_goods = list()
	/// How hard it moves them, a tier of rogue_event_price_mod().
	var/price_tier
	var/event_type = ROGUE_EVENT_SHORTAGE
	/// The factor it laid on its goods' prices.
	var/price_mod = 1
	var/dawn_started = 0
	var/dawn_expires = 0
	/// Units of its goods the realm must ship to the regions to end a shortage early (Ratwood saturation_target).
	var/saturation_target = 0
	var/saturation_progress = 0
	/// Id of the urgent order the shortage posted.
	var/urgent_order_id

/// Some of its goods are traded by the realm; an event of goods nobody here deals in would change nothing.
/datum/rogue_economic_event/proc/affects_ported_goods()
	for(var/id in affected_goods)
		if(SSrogue_trade.goods[id])
			return TRUE
	return FALSE

/// It raises its goods' prices; otherwise it is a glut.
/datum/rogue_economic_event/proc/is_shortage()
	return event_type == ROGUE_EVENT_SHORTAGE

/// Ratwood on_apply(): the event moves its goods' prices.
/datum/rogue_economic_event/proc/apply()
	price_mod = rogue_event_price_mod(price_tier)
	dawn_started = GLOB.rockhill_dawns
	dawn_expires = GLOB.rockhill_dawns + rogue_value("trade_event_days")
	for(var/id in affected_goods)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		if(good)
			good.global_price_mod *= price_mod
	SSrogue_trade.refresh_stock_prices(affected_goods)
	if(is_shortage())
		saturation_target = shortage_target()

/// Ratwood on_expire(): the prices go back.
/datum/rogue_economic_event/proc/lift()
	for(var/id in affected_goods)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		if(good && price_mod)
			good.global_price_mod /= price_mod
	SSrogue_trade.refresh_stock_prices(affected_goods)

/**
 * Ratwood on_apply() for a shortage: it ends early once the realm ships its regions a share of what they would want of its goods
 * while it lasts, averaged over its goods.
 */
/datum/rogue_economic_event/proc/shortage_target()
	var/pop_mult = SSrogue_trade.region_pop_mult()
	var/demand_sum = 0
	var/demand_count = 0
	for(var/id in affected_goods)
		var/total = 0
		for(var/region_id in SSrogue_trade.regions)
			var/datum/rogue_trade_region/region = SSrogue_trade.regions[region_id]
			total += region.demands[id] || 0
		if(total <= 0)
			continue
		demand_sum += total * pop_mult * rogue_value("trade_event_days")
		demand_count++
	if(!demand_count)
		return 1
	return clamp(round(demand_sum * rogue_value("trade_event_relief_share") / demand_count), rogue_value("trade_event_relief_min"), rogue_value("trade_event_relief_max"))

/datum/rogue_economic_event/proc/ui_entry()
	var/list/good_names = list()
	for(var/id in affected_goods)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		if(good)
			good_names += good.name
	return list(
		"name" = name,
		"description" = description,
		"shortage" = is_shortage(),
		"goods" = good_names,
		"percent" = round(price_mod * 100),
		"days_left" = max(0, dawn_expires - GLOB.rockhill_dawns),
		"progress" = saturation_progress,
		"target" = saturation_target,
	)

/// Raiders holding the road to a region (Ratwood /datum/blockade).
/datum/rogue_blockade
	var/datum/rogue_trade_region/region
	/// The road they hold, a wilderness of the realm's map.
	var/route
	/// Who they are: "a gang of highwaymen".
	var/raiders
	var/dawn_started = 0

/datum/rogue_blockade/Destroy()
	region = null
	return ..()

/datum/rogue_blockade/proc/ui_entry()
	return list(
		"region" = region?.name,
		"route" = route,
		"raiders" = raiders,
		"days" = max(0, GLOB.rockhill_dawns - dawn_started),
	)

/**
 * A condition of a foreign realm this round (Ratwood /datum/realm_condition): a war, a harvest, a fair. It changes what the
 * realm's ships buy and sell: lines dropped, lines added, prices and quantities scaled. Data in economy/trade_extra_data.dm.
 */
/datum/rogue_realm_condition
	var/id
	var/name = ""
	var/description = ""
	var/weight = 10
	/// Ids of the realms it can befall.
	var/list/affected_realms = list()
	/// Befalls every realm it names at once, on its own roll (Ratwood cross_realm).
	var/cross_realm = FALSE
	/// list("op" =, "good" =, "price_mod" =, "qty_mod" =, "qty_min" =, "qty_max" =) entries for what the ships sell and buy.
	var/list/supply_modifiers = list()
	var/list/demand_modifiers = list()
	/// Realm id -> list("supply" =, "demand" =) of modifiers for that realm alone.
	var/list/per_realm_modifiers = list()
	/// Realms it befell this round.
	var/befallen = 0

/datum/rogue_realm_condition/proc/apply_to(datum/rogue_foreign_realm/realm)
	if(!realm)
		return
	realm.supply_modifiers += supply_modifiers
	realm.demand_modifiers += demand_modifiers
	var/list/block = per_realm_modifiers[realm.id]
	if(islist(block))
		if(islist(block["supply"]))
			realm.supply_modifiers += block["supply"]
		if(islist(block["demand"]))
			realm.demand_modifiers += block["demand"]
	realm.conditions += src
	befallen++

/datum/rogue_foreign_realm
	/// Conditions befalling it this round, and what they do to its ships' cargo (Ratwood bulk_supply_modifiers,
	/// bulk_demand_modifiers).
	var/list/datum/rogue_realm_condition/conditions = list()
	var/list/supply_modifiers = list()
	var/list/demand_modifiers = list()

/**
 * The cargo its ships buy or sell this round (Ratwood build_effective_pool()): the realm's own lines less the ones a condition
 * removes, scaled by the ones that modify them, with the lines conditions add.
 */
/datum/rogue_foreign_realm/proc/effective_pool(supply)
	var/list/base = supply ? supply_pool : demand_pool
	var/list/modifiers = supply ? supply_modifiers : demand_modifiers
	if(!length(modifiers))
		return base
	var/list/removed = list()
	for(var/list/mod as anything in modifiers)
		if(mod["op"] == ROGUE_CONDITION_REMOVE)
			removed[mod["good"]] = TRUE
	var/list/pool = list()
	for(var/list/entry as anything in base)
		if(removed[entry["good"]])
			continue
		var/list/working = entry.Copy()
		for(var/list/mod as anything in modifiers)
			if(mod["op"] != ROGUE_CONDITION_MODIFY || mod["good"] != entry["good"])
				continue
			if(mod["price_mod"])
				working["price_mod"] = (working["price_mod"] || 1) * mod["price_mod"]
			if(mod["qty_mod"])
				working["qty_min"] = max(1, round((working["qty_min"] || CONDITION_DEFAULT_QTY_MIN) * mod["qty_mod"]))
				working["qty_max"] = max(working["qty_min"], round((working["qty_max"] || CONDITION_DEFAULT_QTY_MAX) * mod["qty_mod"]))
		pool += list(working)
	for(var/list/mod as anything in modifiers)
		if(mod["op"] != ROGUE_CONDITION_ADD)
			continue
		pool += list(list(
			"good" = mod["good"],
			"qty_min" = mod["qty_min"] || CONDITION_DEFAULT_QTY_MIN,
			"qty_max" = mod["qty_max"] || CONDITION_DEFAULT_QTY_MAX,
			"price_mod" = mod["price_mod"] || CONDITION_DEFAULT_PRICE_MOD,
			"always" = mod["always"] || FALSE,
		))
	return pool

/datum/rogue_foreign_realm/proc/condition_entries()
	. = list()
	for(var/datum/rogue_realm_condition/condition as anything in conditions)
		. += list(list("name" = condition.name, "description" = condition.description))

/datum/rogue_trade_region
	/// Raiders hold the road to it (Ratwood is_region_blockaded).
	var/blockaded = FALSE
	/// The dawn its last blockade was broken; -1 if never (Ratwood day_last_cleared).
	var/dawn_last_cleared = -1

/datum/roguestock
	/// The stockpile's prices follow its good's market price; a price the Steward sets by hand stays until restored (Ratwood
	/// automatic_price).
	var/automatic_price = TRUE

/// Ratwood compute_auto_prices(): the stockpile prices its good at the good's market price.
/datum/roguestock/proc/reprice()
	if(!automatic_price || !trade_good)
		return
	set_prices(trade_good.unit_price() * trade_good.global_price_mod)

/datum/controller/subsystem/rogue_trade
	/// Economic events in force (Ratwood GLOB.active_economic_events).
	var/list/datum/rogue_economic_event/events = list()
	/// Event type -> the dawn it may break out again (Ratwood event_path_cooldowns).
	var/list/event_cooldowns = list()
	/// Roads held by raiders (Ratwood GLOB.active_blockades).
	var/list/datum/rogue_blockade/blockades = list()
	/// Blockades that fell after round start (Ratwood blockade_replenish_spent).
	var/blockade_replenish_spent = 0
	/// The dawn's news for the SCOM: shortages and gluts that broke out and urgent orders posted.
	var/list/dawn_shortages = list()
	var/list/dawn_gluts = list()
	var/dawn_urgent = 0
	var/total_banditry = 0

/// Reprices the stockpile entries of goods whose price moved (Ratwood refresh_affected_stockpile_caches()).
/datum/controller/subsystem/rogue_trade/proc/refresh_stock_prices(list/good_ids)
	for(var/id in good_ids)
		var/datum/rogue_trade_good/good = goods[id]
		good?.stock?.reprice()

/// Ratwood roundstart_events(): the round begins with a few events in force.
/datum/controller/subsystem/rogue_trade/proc/roundstart_events()
	for(var/i in 1 to rogue_value("trade_events_roundstart"))
		if(!roll_event())
			break

/// Ratwood roll_economic_events(): at dawn the market gets back to its number of events in force.
/datum/controller/subsystem/rogue_trade/proc/roll_events()
	while(length(events) < rogue_value("trade_events_in_force"))
		if(!roll_event())
			break

/// Ratwood roll_single_event(): an event of a kind not resting, touching only goods no event in force touches. Returns it.
/datum/controller/subsystem/rogue_trade/proc/roll_event()
	var/list/busy = list()
	for(var/datum/rogue_economic_event/active as anything in events)
		busy |= active.affected_goods
	var/list/eligible = list()
	for(var/datum/rogue_economic_event/event_type as anything in subtypesof(/datum/rogue_economic_event))
		if(event_cooldowns[event_type] > GLOB.rockhill_dawns)
			continue
		var/datum/rogue_economic_event/probe = new event_type
		if(probe.affects_ported_goods() && !length(probe.affected_goods & busy))
			eligible += event_type
		qdel(probe)
	if(!length(eligible))
		return null
	var/event_path = pick(eligible)
	var/datum/rogue_economic_event/event = new event_path
	events += event
	event.apply()
	if(event.is_shortage())
		dawn_shortages += event.name
		spawn_urgent_order(event)
	else
		dawn_gluts += event.name
	log_game("ECONOMY: [event.name] ([event.event_type]) broke out for [rogue_value("trade_event_days")] dawns")
	return event

/// Ratwood expire_economic_events(): events whose time is up end at dawn.
/datum/controller/subsystem/rogue_trade/proc/expire_events()
	for(var/datum/rogue_economic_event/event as anything in events.Copy())
		if(event.dawn_expires <= GLOB.rockhill_dawns)
			end_event(event)

/// An event ends: prices go back and its kind rests; a shortage that ran out withdraws its urgent order (Ratwood on_expire(),
/// end_with_relief()).
/datum/controller/subsystem/rogue_trade/proc/end_event(datum/rogue_economic_event/event, relieved = FALSE)
	events -= event
	event.lift()
	event_cooldowns[event.type] = GLOB.rockhill_dawns + rogue_value("trade_event_cooldown")
	if(!relieved)
		var/datum/rogue_standing_order/urgent = find_order(event.urgent_order_id)
		if(urgent)
			orders -= urgent
			qdel(urgent)
	log_game("ECONOMY: [event.name] ended[relieved ? " by relief" : ""]")
	qdel(event)

/// Ratwood credit_economic_event_saturation(): units of a good shipped to the regions count towards ending its shortages.
/datum/controller/subsystem/rogue_trade/proc/credit_event_saturation(good_id, units)
	if(!good_id || units <= 0)
		return
	for(var/datum/rogue_economic_event/event as anything in events.Copy())
		if(!event.is_shortage() || !(good_id in event.affected_goods))
			continue
		event.saturation_progress += units
		if(event.saturation_progress < event.saturation_target)
			continue
		var/event_name = event.name
		end_event(event, relieved = TRUE)
		rogue_scom_announce("RELIEF: [event_name] eased by relief efforts. Prices return to normal.")

/// The event in force over a good, if any (Ratwood get_event_label()).
/datum/controller/subsystem/rogue_trade/proc/event_for_good(good_id)
	for(var/datum/rogue_economic_event/event as anything in events)
		if(good_id in event.affected_goods)
			return event
	return null

/**
 * Ratwood spawn_urgent_for_event(): a shortage posts an urgent order from an open region that wants its goods (or else makes
 * them), paying their shortage price; few units of dear goods, many of cheap ones. Only goods the stockpile keeps are asked.
 */
/datum/controller/subsystem/rogue_trade/proc/spawn_urgent_order(datum/rogue_economic_event/event)
	var/urgent_count = 0
	for(var/datum/rogue_standing_order/order as anything in orders)
		if(order.urgent)
			urgent_count++
	if(urgent_count >= rogue_value("trade_urgent_orders_max"))
		return null
	var/list/candidates = list()
	for(var/wanted in list(TRUE, FALSE))
		for(var/id in regions)
			var/datum/rogue_trade_region/region = regions[id]
			if(region.blockaded)
				continue
			var/list/trade = wanted ? region.demands : region.produces
			for(var/good_id in event.affected_goods)
				if(trade[good_id])
					candidates += region
					break
		if(length(candidates))
			break
	if(!length(candidates))
		return null
	var/list/required = list()
	for(var/good_id in event.affected_goods)
		var/datum/rogue_trade_good/good = goods[good_id]
		if(!good?.stock)
			continue
		var/units
		if(good.base_price >= URGENT_DEAR_PRICE)
			units = rand(3, 5)
		else if(good.base_price >= URGENT_MIDDLING_PRICE)
			units = rand(6, 12)
		else
			units = rand(12, 25)
		required[good] = units
	if(!length(required))
		return null
	var/datum/rogue_trade_region/region = pick(candidates)
	var/datum/rogue_standing_order/order = new
	order.id = ++next_order_id
	order.region = region
	order.urgent = TRUE
	order.title = "[uppertext(region.name)] - URGENT REQUISITION"
	order.description = "[region.name] is suffering from [event.name]. [pick("Local notables", "A merchants' consortium", "The guild elders", "A desperate burgher", "Local magnates")] are paying a premium to resolve the crisis."
	order.required = required
	order.dawn_issued = GLOB.rockhill_dawns
	order.dawn_expires = GLOB.rockhill_dawns + rogue_value("trade_urgent_order_days")
	order.compute_payout()
	orders += order
	event.urgent_order_id = order.id
	dawn_urgent++
	return order

// Blockades.

/datum/controller/subsystem/rogue_trade/proc/blockade_of(datum/rogue_trade_region/region)
	for(var/datum/rogue_blockade/blockade as anything in blockades)
		if(blockade.region == region)
			return blockade
	return null

/datum/controller/subsystem/rogue_trade/proc/route_held(route)
	for(var/datum/rogue_blockade/blockade as anything in blockades)
		if(blockade.route == route)
			return TRUE
	return FALSE

/// Ratwood roundstart_blockades(): the round begins with a few roads held.
/datum/controller/subsystem/rogue_trade/proc/roundstart_blockades()
	for(var/i in 1 to rand(rogue_value("trade_blockades_roundstart_min"), rogue_value("trade_blockades_roundstart_max")))
		if(!roll_blockade())
			break

/**
 * Ratwood roll_blockade(): raiders cut the road to a region that is open, was not freed too lately and whose road no other band
 * holds; one that falls after round start never falls on Kingsfield. Returns the blockade.
 */
/datum/controller/subsystem/rogue_trade/proc/roll_blockade(replenish = FALSE)
	var/list/candidates = list()
	for(var/id in regions)
		var/datum/rogue_trade_region/region = regions[id]
		var/route = GLOB.rogue_blockade_routes[id]
		if(!route || region.blockaded || route_held(route) || !length(GLOB.rogue_blockade_raiders[route]))
			continue
		if(replenish && (id in GLOB.rogue_blockade_no_replenish))
			continue
		if(region.dawn_last_cleared >= 0 && GLOB.rockhill_dawns - region.dawn_last_cleared < rogue_value("trade_blockade_reclear_days"))
			continue
		candidates += region
	if(!length(candidates))
		return null
	var/datum/rogue_trade_region/region = pick(candidates)
	return place_blockade(region, pick_weight(GLOB.rogue_blockade_raiders[GLOB.rogue_blockade_routes[region.id]]))

/// Ratwood place_blockade() and announce_blockade_start().
/datum/controller/subsystem/rogue_trade/proc/place_blockade(datum/rogue_trade_region/region, raider_id)
	if(!region || region.blockaded)
		return null
	var/list/names = GLOB.rogue_raider_names[raider_id]
	var/datum/rogue_blockade/blockade = new
	blockade.region = region
	blockade.route = GLOB.rogue_blockade_routes[region.id]
	blockade.raiders = length(names) ? "a [names[1]] of [names[2]]" : "a band of raiders"
	blockade.dawn_started = GLOB.rockhill_dawns
	blockades += blockade
	region.blockaded = TRUE
	rogue_scom_announce("BLOCKADE: The trade road to [region.name] is cut - [blockade.raiders] has fallen upon it. The Crown awaits a defense commission.")
	log_game("ECONOMY: [blockade.raiders] cut the road to [region.name] ([blockade.route])")
	return blockade

/**
 * The road to the region opens again (Ratwood clear_blockade(), announce_blockade_cleared()). The defense contract of the
 * Steward (Б34) breaks a blockade with the reason "cleared"; a blockade that runs out is "dispersed".
 */
/datum/controller/subsystem/rogue_trade/proc/clear_blockade(datum/rogue_blockade/blockade, reason = "cleared")
	if(!blockade)
		return
	var/datum/rogue_trade_region/region = blockade.region
	blockades -= blockade
	if(region)
		region.blockaded = FALSE
		region.dawn_last_cleared = GLOB.rockhill_dawns
		if(reason == "cleared")
			rogue_scom_announce("The road to [region.name] is open once more - the blockade has been broken.")
		else
			rogue_scom_announce("The raiders on the road to [region.name] have moved on. Its trade flows again.")
		log_game("ECONOMY: the road to [region.name] opened ([reason])")
	qdel(blockade)

/**
 * At dawn: blockades that have held long enough disperse; between the second and the fifth dawn a new one may fall while fewer
 * than a few roads are held, within a budget that grows with the population (Ratwood tick_blockade_replenish()).
 */
/datum/controller/subsystem/rogue_trade/proc/tick_blockades()
	for(var/datum/rogue_blockade/blockade as anything in blockades.Copy())
		if(GLOB.rockhill_dawns - blockade.dawn_started >= rogue_value("trade_blockade_days"))
			clear_blockade(blockade, "dispersed")
	if(GLOB.rockhill_dawns < rogue_value("trade_blockade_replenish_first") || GLOB.rockhill_dawns > rogue_value("trade_blockade_replenish_last"))
		return
	if(length(blockades) >= rogue_value("trade_blockade_replenish_floor"))
		return
	var/budget_base = rogue_value("trade_blockade_replenish_budget")
	var/budget = clamp(budget_base + round(player_count() * rogue_value("trade_blockade_replenish_per_player")), budget_base, rogue_value("trade_blockade_replenish_budget_max"))
	if(blockade_replenish_spent >= budget || !prob(rogue_value("trade_blockade_replenish_chance")))
		return
	if(roll_blockade(replenish = TRUE))
		blockade_replenish_spent++

/// Mammons the Crown loses on the held roads at a dawn: every held road counts as a dangerous region of Ratwood's banditry drain.
/datum/controller/subsystem/rogue_trade/proc/banditry_losses()
	return length(blockades) * round(rogue_value("trade_banditry_flat") + player_count() * rogue_value("trade_banditry_per_player"))

/**
 * Ratwood tick_banditry_drain(): the caravans lost on the held roads are paid from the Crown's Purse down to a floor; what it
 * cannot pay becomes a banditry debt, repaid first from the Purse's income.
 */
/datum/controller/subsystem/rogue_trade/proc/tick_banditry()
	var/losses = banditry_losses()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	if(losses <= 0 || !treasury.crown_purse)
		return
	var/burned = min(losses, max(0, round(treasury.crown_purse.account_balance - rogue_value("trade_banditry_floor"))))
	if(burned > 0 && !treasury.burn(treasury.crown_purse, burned, "Banditry losses (held roads)"))
		burned = 0
	if(losses > burned)
		treasury.banditry_debt += losses - burned
	total_banditry += losses

// Conditions of the foreign realms.

/**
 * Ratwood roll_active_conditions(), once a round: every condition that befalls several realms comes to pass on its own chance,
 * and every realm has a chance to suffer one of its own conditions, picked by weight.
 */
/datum/controller/subsystem/rogue_trade/proc/roll_realm_conditions()
	var/list/singles = list()
	var/list/all = list()
	for(var/condition_type in subtypesof(/datum/rogue_realm_condition))
		var/datum/rogue_realm_condition/condition = new condition_type
		all += condition
		if(!condition.id || !length(condition.affected_realms))
			continue
		if(!condition.cross_realm)
			singles += condition
			continue
		if(!prob(rogue_value("trade_condition_shared_chance")))
			continue
		for(var/realm_id in condition.affected_realms)
			condition.apply_to(realms[realm_id])
	for(var/realm_id in realms)
		if(!prob(rogue_value("trade_condition_realm_chance")))
			continue
		var/list/weighted = list()
		for(var/datum/rogue_realm_condition/condition as anything in singles)
			if(realm_id in condition.affected_realms)
				weighted[condition] = max(1, condition.weight)
		if(length(weighted))
			var/datum/rogue_realm_condition/picked = pick_weight(weighted)
			picked.apply_to(realms[realm_id])
	for(var/datum/rogue_realm_condition/condition as anything in all)
		if(!condition.befallen)
			qdel(condition)

/datum/controller/subsystem/rogue_treasury
	/// Caravans the Crown lost to raiders and could not pay for yet (Ratwood banditry_debt).
	var/banditry_debt = 0

/// Ratwood skim_for_banditry_debt(): the Purse's income first pays what the raiders cost. Returns what is left of the income.
/datum/controller/subsystem/rogue_treasury/proc/skim_for_banditry_debt(amount)
	if(banditry_debt <= 0 || amount <= 0)
		return amount
	var/skim = round(min(amount, banditry_debt))
	if(skim <= 0 || !crown_purse.adjust_money(-skim, "Banditry debt repayment"))
		return amount
	banditry_debt -= skim
	return amount - skim

#undef ROGUE_EVENT_SHORTAGE
#undef ROGUE_CONDITION_MODIFY
#undef ROGUE_CONDITION_REMOVE
#undef ROGUE_CONDITION_ADD
#undef URGENT_DEAR_PRICE
#undef URGENT_MIDDLING_PRICE
#undef CONDITION_DEFAULT_QTY_MIN
#undef CONDITION_DEFAULT_QTY_MAX
#undef CONDITION_DEFAULT_PRICE_MOD
