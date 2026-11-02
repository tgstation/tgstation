/**
 * Trade of the realm on medieval maps (Ratwood Economy 3: code/controllers/subsystem/rogue/economy/, merchant_trade.dm and
 * roguemachine/merchant/trade/):
 * - trade goods: what the regions, ships and standing orders deal in, each tied to its item (or reagent) and to its
 *   stockpile entry; finished items and potions are delivered at the warehouse docks instead;
 * - regions of the realm: what each produces and demands daily; the stockpile imports from the cheapest open producer and
 *   ships its surplus to the best open buyer, the Steward trades with each region by hand, and each region posts standing
 *   orders (economy/standing_orders.dm, economy/petitions.dm);
 * - foreign realms and their ships: offshore every day, hailed into port by the merchant, buying and selling cargo,
 *   provisions and cultural stock at the harbor (economy/harbor.dm, economy/ship_trade.dm).
 * Economic events, blockades and the realms' conditions live in economy/market_events.dm, the merchant's favor and catalogs in
 * economy/merchant_favor.dm. Data is Ratwood's, generated into economy/trade_data.dm and economy/trade_extra_data.dm.
 */

/// Goods the realm trades as finished items or as potions, delivered at the warehouse docks instead of the stockpile (Ratwood
/// TRADE_BEHAVIOR_EQUIPMENT, TRADE_BEHAVIOR_POTION, as the data names them); other goods have no behavior.
#define ROGUE_GOOD_EQUIPMENT "equipment"
#define ROGUE_GOOD_POTION "potion"

SUBSYSTEM_DEF(rogue_trade)
	name = "Trade"
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME
	dependencies = list(
		/datum/controller/subsystem/rogue_treasury,
	)
	/// Trade good id -> good, for goods whose item (or reagent) is ported.
	var/list/goods = list()
	/// Region id -> region of the realm.
	var/list/regions = list()
	/// Template key -> standing order template.
	var/list/order_templates = list()
	/// Realm id -> foreign realm.
	var/list/realms = list()
	/// Every ship offshore or at the pier.
	var/list/datum/rogue_trade_ship/ships = list()
	/// Hails the merchant has left today (Ratwood hails_remaining).
	var/hails_left = 0
	/// Standing orders open now.
	var/list/datum/rogue_standing_order/orders = list()
	/// Share of a ship sale the merchant takes as middleman, percent (Ratwood merchant_levy_percent).
	var/middleman_cut = 0
	/// Last time the merchant worked the harbor; a long silence brings a ship in unbidden (Ratwood last_merchant_activity).
	var/last_merchant_activity = 0
	/// The dawn a ship last came in unbidden; once a day (Ratwood auto_hail_used_day).
	var/auto_hail_dawn = -1
	var/next_ship_id = 0
	var/next_order_id = 0
	/// Mammons of cargo sold to ships, bought off ships, paid for standing orders.
	var/total_ship_sales = 0
	var/total_ship_purchases = 0
	var/total_order_payouts = 0
	var/total_export_duty = 0
	/// Standing orders posted at the last dawn, for its news.
	var/dawn_orders = 0

/datum/controller/subsystem/rogue_trade/Initialize()
	if(!rogue_economy_enabled())
		can_fire = FALSE
		return SS_INIT_NO_NEED
	for(var/good_type in subtypesof(/datum/rogue_trade_good))
		var/datum/rogue_trade_good/good = new good_type
		if(good.id && (good.item_type || good.reagent_type))
			goods[good.id] = good
	link_stockpile()
	rogue_run_pricing_engine(goods)
	for(var/datum/roguestock/stock as anything in SSrogue_treasury.stockpile_datums)
		stock.reprice()
	for(var/region_type in subtypesof(/datum/rogue_trade_region))
		var/datum/rogue_trade_region/region = new region_type
		for(var/key in GLOB.rogue_region_order_templates[region.id])
			region.order_templates |= key
		regions[region.id] = region
	for(var/template_type in subtypesof(/datum/rogue_order_template))
		var/datum/rogue_order_template/template = new template_type
		order_templates[template.key] = template
	for(var/realm_type in subtypesof(/datum/rogue_foreign_realm))
		var/datum/rogue_foreign_realm/realm = new realm_type
		realms[realm.id] = realm
	roll_realm_conditions()
	setup_catalogs()
	setup_crown_imports()
	register_levy(ROGUE_TAX_HEADEATER, rogue_value("trade_headeater_levy"))
	register_levy(ROGUE_TAX_EXPORT, rogue_value("trade_export_duty"))
	middleman_cut = rogue_value("trade_middleman_cut")
	last_merchant_activity = world.time
	reset_regions()
	roundstart_events()
	roundstart_blockades()
	start_day()
	RegisterSignal(SSdcs, COMSIG_GLOB_ROCKHILL_TIME_OF_DAY, PROC_REF(on_time_of_day))
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawn))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/rogue_trade/stat_entry(msg)
	msg = "Ships: [length(docked_ships())]/[length(ships)], orders: [length(orders)], events: [length(events)], blockades: [length(blockades)]"
	return ..()

/// Every minute: ships whose time at the pier is up sail; a harbor the merchant leaves idle gets a ship unbidden; the harbor
/// crew, if the merchant retains one, works the pier.
/datum/controller/subsystem/rogue_trade/fire(resumed)
	for(var/datum/rogue_trade_ship/ship as anything in docked_ships())
		if(world.time >= ship.dock_expires_at)
			depart(ship, TRUE)
	auto_hail()
	auto_hailer_tick()

/// A Crown levy the trade code collects, added to the treasury's levies so the Steward sets it with the others.
/datum/controller/subsystem/rogue_trade/proc/register_levy(levy, percent)
	if(!(levy in SSrogue_treasury.tax_rates))
		SSrogue_treasury.tax_rates[levy] = percent / 100

/// Ties each trade good to its stockpile entry (Ratwood trade_good_id), or to the entry that takes the same item.
/datum/controller/subsystem/rogue_trade/proc/link_stockpile()
	for(var/datum/roguestock/stock as anything in SSrogue_treasury.stockpile_datums)
		var/datum/rogue_trade_good/good = goods[GLOB.rogue_stock_trade_goods["[stock.type]"]]
		if(!good)
			for(var/id in goods)
				var/datum/rogue_trade_good/candidate = goods[id]
				if(candidate.item_type && candidate.item_type == stock.item_type)
					good = candidate
					break
		if(good && !good.stock && !good.finished())
			good.stock = stock
			stock.trade_good = good

/// The trade good an item is sold as at the harbor (Ratwood identify_trade_good()).
/datum/controller/subsystem/rogue_trade/proc/good_for(obj/item/thing)
	for(var/id in goods)
		var/datum/rogue_trade_good/good = goods[id]
		if(good.accepts(thing))
			return good
	return null

/// Players who count for the size of the day's trade (Ratwood get_active_player_count()).
/datum/controller/subsystem/rogue_trade/proc/player_count()
	return length(GLOB.alive_player_list)

/// How much the realm's trade grows with its people (Ratwood REGION_POP_SCALE_*).
/datum/controller/subsystem/rogue_trade/proc/region_pop_mult()
	return min(rogue_value("trade_region_pop_max"), 1 + player_count() * rogue_value("trade_region_pop_per_player"))

// The day.

/datum/controller/subsystem/rogue_trade/proc/on_time_of_day(datum/source, datum/rockhill_clock_step/phase/old_phase, datum/rockhill_clock_step/phase/new_phase)
	SIGNAL_HANDLER
	if(new_phase?.name != ROCKHILL_DAWN)
		return
	INVOKE_ASYNC(src, PROC_REF(new_day))

/**
 * A new dawn (Ratwood daily_tick() of the economy and of merchant trade): the regions' trade and the crown imports reset, open
 * orders and spent events run out, new events break out, blockades disperse or fall, the held roads cost the Crown its
 * caravans, new orders are posted, the merchant's hails and catalogs refill and a new set of ships waits offshore.
 */
/datum/controller/subsystem/rogue_trade/proc/new_day()
	reset_regions()
	reset_crown_imports()
	expire_orders()
	expire_events()
	roll_events()
	tick_blockades()
	tick_banditry()
	start_day()

/datum/controller/subsystem/rogue_trade/proc/start_day()
	hails_left = rogue_value("trade_hails_per_day")
	restock_catalogs()
	expire_orders()
	dawn_orders += roll_orders()
	expire_offshore_ships()
	roll_ships()
	announce_dawn()

/// Ratwood daily_tick()'s dawn summary on the SCOM: the new orders, the urgent ones, the shortages and gluts.
/datum/controller/subsystem/rogue_trade/proc/announce_dawn()
	var/list/parts = list()
	if(dawn_orders || dawn_urgent)
		parts += "[dawn_orders] new standing order\s[dawn_urgent ? " ([dawn_urgent] URGENT)" : ""]"
	if(length(dawn_shortages))
		parts += "Shortages: [jointext(dawn_shortages, ", ")]"
	if(length(dawn_gluts))
		parts += "Gluts: [jointext(dawn_gluts, ", ")]"
	if(length(parts))
		rogue_scom_announce("[jointext(parts, " - ")].")
	dawn_orders = 0
	dawn_urgent = 0
	dawn_shortages.Cut()
	dawn_gluts.Cut()

/// Each region's daily produce and demand, grown with the population (Ratwood REGION_POP_SCALE_*).
/datum/controller/subsystem/rogue_trade/proc/reset_regions()
	var/pop_mult = region_pop_mult()
	for(var/id in regions)
		var/datum/rogue_trade_region/region = regions[id]
		region.new_day(pop_mult)

// Regions: imports for the stockpile and exports of its surplus.

/**
 * The cheapest region that produces a good today, and the price of the next unit from it (Ratwood get_best_import_region()
 * and compute_import_unit_price()): a region sells at the good's market price up to its daily pace, dearer past it, double
 * on a held road; a held road is used only when no open region produces the good.
 * Returns list("region" = region, "unit_cost" = mammons) or null when no region produces the good.
 */
/datum/controller/subsystem/rogue_trade/proc/import_quote(datum/rogue_trade_good/good)
	if(!good)
		return null
	var/datum/rogue_trade_region/best
	var/best_cost = INFINITY
	var/datum/rogue_trade_region/fallback
	var/fallback_cost = INFINITY
	for(var/id in regions)
		var/datum/rogue_trade_region/region = regions[id]
		var/cost = region.import_unit_cost(good)
		if(!cost)
			continue
		if(cost < fallback_cost)
			fallback = region
			fallback_cost = cost
		if(!region.blockaded && cost < best_cost)
			best = region
			best_cost = cost
	if(!best)
		best = fallback
		best_cost = fallback_cost
	if(!best)
		return null
	return list("region" = best, "unit_cost" = best_cost)

/**
 * The region that pays most for the next unit of a good today (Ratwood get_best_export_region()), open roads first.
 * Returns list("region" = region, "unit_price" = mammons) or null when no region wants the good.
 */
/datum/controller/subsystem/rogue_trade/proc/export_quote(datum/rogue_trade_good/good)
	if(!good)
		return null
	var/datum/rogue_trade_region/best
	var/best_price = 0
	var/datum/rogue_trade_region/fallback
	var/fallback_price = 0
	for(var/id in regions)
		var/datum/rogue_trade_region/region = regions[id]
		var/price = region.export_unit_price(good)
		if(price <= 0)
			continue
		if(price > fallback_price)
			fallback = region
			fallback_price = price
		if(!region.blockaded && price > best_price)
			best = region
			best_price = price
	if(!best)
		best = fallback
		best_price = fallback_price
	if(!best)
		return null
	return list("region" = best, "unit_price" = best_price)

/**
 * The Crown buys units of a good from a region into the stockpile at the region's climbing price (Ratwood manual_import()),
 * by the Steward's hand or by the Crown's standing imports. Returns the mammons spent, or 0.
 */
/datum/controller/subsystem/rogue_trade/proc/region_import(datum/rogue_trade_region/region, datum/rogue_trade_good/good, units, mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	units = round(units)
	if(!region || !good?.stock || units <= 0 || !region.produces[good.id] || !treasury.crown_purse)
		return 0
	var/total = 0
	for(var/i in 1 to units)
		total += region.import_unit_cost(good, i - 1)
	if(!treasury.crown_purse.has_money(total))
		if(user)
			to_chat(user, span_warning("Crown's Purse insufficient: [treasury.crown_purse.account_balance]m < [total]m."))
		return 0
	if(!treasury.burn(treasury.crown_purse, total, "[user ? "Manual" : "Auto"] Import: [units] [good.name] from [region.name][user ? " by [user.real_name]" : ""]"))
		return 0
	region.produces_today[good.id] = (region.produces_today[good.id] || 0) - units
	good.stock.stockpile_amount += units
	treasury.total_import += total
	treasury.economic_output += total
	if(user)
		log_game("MANUAL IMPORT: [key_name(user)] imported [units] [good.name] from [region.name] for [total]m")
	return total

/**
 * The Crown ships units of a good from the stockpile to a region that wants it (Ratwood manual_export()): each unit past the
 * region's daily wants fetches less, a held road half. Units shipped count towards ending a shortage of the good. Returns the
 * mammons earned, or 0.
 */
/datum/controller/subsystem/rogue_trade/proc/region_export(datum/rogue_trade_region/region, datum/rogue_trade_good/good, units, mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	units = round(units)
	if(!region || !good?.stock || units <= 0 || !region.demands[good.id] || !treasury.crown_purse)
		return 0
	if(good.stock.stockpile_amount < units)
		if(user)
			to_chat(user, span_warning("Insufficient [good.name] in stockpile: have [good.stock.stockpile_amount], need [units]."))
		return 0
	var/total = 0
	for(var/i in 1 to units)
		total += region.export_unit_price(good, i - 1)
	good.stock.stockpile_amount -= units
	region.demands_today[good.id] = (region.demands_today[good.id] || 0) - units
	treasury.mint(treasury.crown_purse, total, "[user ? "Manual" : "Auto"] Export: [units] [good.name] to [region.name][user ? " by [user.real_name]" : ""]")
	treasury.total_export += total
	treasury.economic_output += total
	credit_event_saturation(good.id, units)
	if(user)
		log_game("MANUAL EXPORT: [key_name(user)] exported [units] [good.name] to [region.name] for [total]m")
	return total

// Standing orders.

/datum/controller/subsystem/rogue_trade/proc/expire_orders()
	for(var/datum/rogue_standing_order/order as anything in orders.Copy())
		if(order.dawn_expires <= GLOB.rockhill_dawns)
			orders -= order
			qdel(order)

/// Orders open in a region, a pair counted once (Ratwood's count by pair_id).
/datum/controller/subsystem/rogue_trade/proc/open_orders_of(datum/rogue_trade_region/region)
	. = 0
	var/list/seen_pairs = list()
	for(var/datum/rogue_standing_order/order as anything in orders)
		if(order.region != region)
			continue
		if(order.pair_id)
			if(seen_pairs[order.pair_id])
				continue
			seen_pairs[order.pair_id] = TRUE
		.++

/// The region's templates by weight (Ratwood possible_standing_order_types), within keys if given.
/datum/controller/subsystem/rogue_trade/proc/region_templates(datum/rogue_trade_region/region, list/keys)
	var/list/weighted = list()
	for(var/key in region.order_templates)
		if(keys && !(key in keys))
			continue
		var/datum/rogue_order_template/template = order_templates[key]
		if(template)
			weighted[template] = max(1, template.roll_weight)
	return weighted

/**
 * Posts an order of a template from a region, and its sibling if the template comes in a pair (Ratwood
 * instantiate_standing_order(), instantiate_standing_order_pair()). Returns the order, or null if no good of it is traded.
 */
/datum/controller/subsystem/rogue_trade/proc/post_order(datum/rogue_order_template/template, datum/rogue_trade_region/region, petitioned = FALSE)
	var/datum/rogue_standing_order/order = template.instantiate(region, petitioned)
	if(!order)
		return null
	var/datum/rogue_order_template/sibling_template = order_templates[GLOB.rogue_order_pairs[template.key]]
	if(sibling_template)
		var/datum/rogue_standing_order/sibling = sibling_template.instantiate(region, petitioned)
		if(!sibling)
			qdel(order)
			return null
		order.pair_id = "[order.id]"
		sibling.pair_id = order.pair_id
		sibling.dawn_expires = order.dawn_expires
		orders += sibling
	orders += order
	return order

/**
 * Posts the day's standing orders (Ratwood daily_tick()): a few more with more players, up to a cap, from regions with fewer
 * than their share open; each region picks one of its templates by weight. Returns how many were posted.
 */
/datum/controller/subsystem/rogue_trade/proc/roll_orders()
	. = 0
	var/to_roll = min(rogue_value("trade_orders_max_per_day"), rogue_value("trade_orders_per_day") + round(player_count() * rogue_value("trade_orders_per_player")))
	for(var/i in 1 to to_roll)
		if(length(orders) >= rogue_value("trade_orders_cap"))
			return
		var/list/eligible = list()
		for(var/id in regions)
			var/datum/rogue_trade_region/region = regions[id]
			if(length(region.order_templates) && open_orders_of(region) < rogue_value("trade_orders_per_region"))
				eligible += region
		if(!length(eligible))
			return
		var/datum/rogue_trade_region/region = pick(eligible)
		var/list/weighted = region_templates(region)
		if(!length(weighted))
			continue
		if(post_order(pick_weight(weighted), region))
			.++

/datum/controller/subsystem/rogue_trade/proc/find_order(order_id)
	if(isnull(order_id))
		return null
	for(var/datum/rogue_standing_order/order as anything in orders)
		if(order.id == order_id)
			return order
	return null

/**
 * Fills a standing order (Ratwood fulfill_order()): raw goods from the Crown's stockpile, finished items and potions left at
 * the warehouse docks (economy/petitions.dm). Everything there: the goods go and the whole payout, moved by the quality of the
 * finished items, comes into the Crown's Purse. Short of some: if what there is is worth at least half the order, the Steward
 * may settle it partially for a reduced share; otherwise it is refused. An order of a region behind a held road waits.
 * Returns ROGUE_ORDER_FULL, ROGUE_ORDER_PARTIAL, ROGUE_ORDER_NEEDS_CONFIRM, or FALSE.
 */
/datum/controller/subsystem/rogue_trade/proc/fulfill_order(datum/rogue_standing_order/order, mob/user, partial = FALSE)
	if(!order || !(order in orders))
		return FALSE
	if(order.region?.blockaded)
		to_chat(user, span_warning("[order.region.name] is blockaded - the order cannot be delivered until the road is cleared."))
		return FALSE
	var/list/at_docks = order.finished_at_docks()
	var/list/delivered = list()
	var/delivered_value = 0
	var/quality_delta = 0
	var/list/short = list()
	for(var/datum/rogue_trade_good/good as anything in order.required)
		var/needed = order.required[good]
		var/have = 0
		if(good.finished())
			var/list/found = at_docks[good]
			have = min(found ? found["units"] : 0, needed)
			if(good.behavior == ROGUE_GOOD_EQUIPMENT && have)
				var/list/items = found["items"]
				for(var/i in 1 to have)
					var/obj/item/thing = items[i]
					quality_delta += CEILING(order.unit_payout(good) * rogue_quality_price_mult(thing.rogue_quality), 1) - order.unit_payout(good)
		else
			have = good.stock ? min(good.stock.stockpile_amount, needed) : 0
		delivered[good] = have
		delivered_value += order.unit_payout(good) * have
		if(have < needed)
			short += good.name
	if(order.petitioned)
		delivered_value = round(delivered_value * rogue_value("trade_petition_payout"))
		quality_delta = round(quality_delta * rogue_value("trade_petition_payout"))
	var/payout
	if(!length(short))
		payout = max(0, order.payout + quality_delta)
		. = ROGUE_ORDER_FULL
	else
		var/coverage = order.payout ? delivered_value / order.payout : 0
		if(coverage < rogue_value("trade_order_partial_threshold"))
			to_chat(user, span_warning("Coverage [round(coverage * 100)]% - below the [round(rogue_value("trade_order_partial_threshold") * 100)]% partial threshold. Short on: [english_list(short)]."))
			return FALSE
		if(!partial)
			return ROGUE_ORDER_NEEDS_CONFIRM
		payout = max(0, round((delivered_value + quality_delta) * rogue_value("trade_order_partial_payout")))
		. = ROGUE_ORDER_PARTIAL
	for(var/datum/rogue_trade_good/good as anything in delivered)
		var/units = delivered[good]
		if(good.finished())
			order.consume_at_docks(at_docks[good], units)
		else if(good.stock)
			good.stock.stockpile_amount -= units
			credit_event_saturation(good.id, units)
	orders -= order
	SSrogue_treasury.mint(SSrogue_treasury.crown_purse, payout, "Standing Order[. == ROGUE_ORDER_PARTIAL ? " (Partial)" : ""]: [order.title]")
	total_order_payouts += payout
	if(. == ROGUE_ORDER_FULL)
		to_chat(user, span_notice("Order fulfilled: [payout]m paid to the Crown's Purse."))
	else
		to_chat(user, span_notice("Order settled (partial): [payout]m paid to the Crown's Purse."))
	if(quality_delta > 0)
		to_chat(user, span_green("Quality bonus: +[quality_delta]m for above-standard goods."))
	else if(quality_delta < 0)
		to_chat(user, span_warning("Quality penalty: [quality_delta]m for shoddy goods."))
	log_game("STANDING ORDER: [key_name(user)] filled [order.title] for [payout]m ([.])")
	qdel(order)

// Ships.

/datum/controller/subsystem/rogue_trade/proc/docked_ships()
	. = list()
	for(var/datum/rogue_trade_ship/ship as anything in ships)
		if(ship.state == ROGUE_SHIP_DOCKED)
			. += ship

/datum/controller/subsystem/rogue_trade/proc/offshore_ships()
	. = list()
	for(var/datum/rogue_trade_ship/ship as anything in ships)
		if(ship.state == ROGUE_SHIP_OFFSHORE)
			. += ship

/datum/controller/subsystem/rogue_trade/proc/find_ship(ship_id)
	for(var/datum/rogue_trade_ship/ship as anything in ships)
		if(ship.id == ship_id)
			return ship
	return null

/// Piers of the harbor; the company rents one more for favor (Ratwood get_dock_spots_max()).
/datum/controller/subsystem/rogue_trade/proc/dock_spots()
	return min(rogue_value("trade_dock_spots_max"), rogue_value("trade_dock_spots") + (extra_pier ? 1 : 0))

/// The day's ships wait offshore, from realms picked by weight; the merchant's kin always send one (Ratwood roll_daily_pool()).
/datum/controller/subsystem/rogue_trade/proc/roll_ships()
	var/list/weighted = list()
	for(var/id in realms)
		var/datum/rogue_foreign_realm/realm = realms[id]
		weighted[realm] = max(1, realm.roll_weight)
	if(!length(weighted))
		return
	var/to_roll = rogue_value("trade_ships_per_day")
	if(realms[kinship_realm] && to_roll > 0)
		ships += new /datum/rogue_trade_ship(realms[kinship_realm], ++next_ship_id)
		to_roll--
	for(var/i in 1 to to_roll)
		ships += new /datum/rogue_trade_ship(pick_weight(weighted), ++next_ship_id)

/// Ships nobody hailed sail on at dawn (Ratwood expire_undocked_ships()).
/datum/controller/subsystem/rogue_trade/proc/expire_offshore_ships()
	for(var/datum/rogue_trade_ship/ship as anything in offshore_ships())
		ships -= ship
		qdel(ship)

/// The merchant hails a ship into port (Ratwood hail_ship()). Returns null on success or the reason it failed.
/datum/controller/subsystem/rogue_trade/proc/hail(datum/rogue_trade_ship/ship, mob/user)
	if(!ship || ship.state != ROGUE_SHIP_OFFSHORE)
		return "That ship has sailed on."
	if(hails_left <= 0)
		return "No more hails today."
	if(length(docked_ships()) >= dock_spots())
		return "Every pier is taken."
	hails_left--
	dock(ship)
	var/hail_line = ship.realm.pick_hail_line()
	if(hail_line && user)
		to_chat(user, span_notice("<i>Captain [ship.captain] calls from the deck: \"[hail_line]\"</i>"))
	return null

/datum/controller/subsystem/rogue_trade/proc/dock(datum/rogue_trade_ship/ship)
	ship.state = ROGUE_SHIP_DOCKED
	ship.docked_at = world.time
	ship.dock_expires_at = world.time + rogue_value("trade_dock_time")
	rogue_scom_announce("The [ship.ship_type] [ship.name], flying the colors of [ship.realm.name], has made port at the docks.")

/// The merchant sends a ship away (Ratwood send_away_ship()): not before its grace time unless it came unbidden or its trade
/// was done. Returns null on success or the reason it failed.
/datum/controller/subsystem/rogue_trade/proc/send_away(datum/rogue_trade_ship/ship)
	if(!ship || ship.state != ROGUE_SHIP_DOCKED)
		return "That ship has sailed on."
	if(!ship.auto_hailed && !ship.honored() && world.time < ship.docked_at + rogue_value("trade_send_away_grace"))
		return "The captain will not cast off so soon."
	depart(ship)
	return null

/**
 * A ship leaves port (Ratwood finalize_ship_departure()): its captain weighs the trade he got against what he hoped for, and
 * the merchant's favor with the trading company follows (economy/merchant_favor.dm). A ship whose time ran out (auto) may cost
 * the merchant favor below nothing.
 */
/datum/controller/subsystem/rogue_trade/proc/depart(datum/rogue_trade_ship/ship, auto = FALSE)
	resolve_ship_favor(ship, auto)
	ships -= ship
	qdel(ship)

/datum/controller/subsystem/rogue_trade/proc/touch_merchant_activity()
	last_merchant_activity = world.time

/// A harbor left idle draws a ship in unbidden, once a day (Ratwood auto_hail_tick()).
/datum/controller/subsystem/rogue_trade/proc/auto_hail()
	if(auto_hail_dawn == GLOB.rockhill_dawns || world.time - last_merchant_activity < rogue_value("trade_auto_hail_idle"))
		return
	if(length(docked_ships()) >= dock_spots())
		return
	var/datum/rogue_trade_ship/ship = pick_offshore_ship()
	if(!ship)
		return
	ship.auto_hailed = TRUE
	auto_hail_dawn = GLOB.rockhill_dawns
	dock(ship)

/// An offshore ship, by its realm's weight (Ratwood pick_available_ship_weighted()).
/datum/controller/subsystem/rogue_trade/proc/pick_offshore_ship()
	var/list/weighted = list()
	for(var/datum/rogue_trade_ship/ship as anything in offshore_ships())
		weighted[ship] = max(1, ship.realm.roll_weight)
	return length(weighted) ? pick_weight(weighted) : null

/// The first docked ship that still buys this good, and its cargo line (Ratwood find_demand_match()).
/datum/controller/subsystem/rogue_trade/proc/find_demand(datum/rogue_trade_good/good)
	for(var/datum/rogue_trade_ship/ship as anything in docked_ships())
		for(var/list/line as anything in ship.demands)
			if(line[ROGUE_LINE_GOOD] == good && line[ROGUE_LINE_DONE] < line[ROGUE_LINE_TARGET])
				return list(ship, line)
	return null

/// Says a line on every SCOM of the realm (Ratwood scom_announce()).
/proc/rogue_scom_announce(message)
	for(var/obj/structure/roguemachine/scomm/scom as anything in GLOB.rockhill_scomms)
		scom.say(message)

/**
 * A good the realm trades in (Ratwood /datum/trade_good): its trade price and its item, or for a potion its reagent. Data in
 * economy/trade_data.dm and, for finished items and potions, economy/trade_extra_data.dm.
 */
/datum/rogue_trade_good
	var/id
	var/name = ""
	/// Trade price of one unit (Ratwood base_price); a good priced by its recipe takes its derived price at round start.
	var/base_price = 1
	/// What the market does to the price now: economic events multiply it (Ratwood global_price_mod).
	var/global_price_mod = 1
	/// Item path as text, resolved at New(); a good whose item is not ported is left out.
	var/item_path
	var/obj/item/item_type
	/// Any subtype of the item counts (Ratwood accept_subtypes).
	var/accept_subtypes = FALSE
	/// More exact item types that count as the good, as text (Ratwood alt_item_types).
	var/list/alt_item_paths
	var/list/alt_item_types
	/// The stockpile entry of the good, if the Crown stocks it.
	var/datum/roguestock/stock
	/// Delivered as a finished item or a potion at the warehouse docks (ROGUE_GOOD_*), or null for a raw good (Ratwood behavior).
	var/behavior
	/// Its trade price is the derived price of its item (Ratwood derive_price).
	var/derive_price = FALSE
	/// A potion: its reagent, as text and resolved, and how much of it makes one unit in any container (Ratwood reagent_type,
	/// required_volume).
	var/reagent_path
	var/datum/reagent/reagent_type
	var/required_volume = 0
	/// The container a potion comes in when bought (Ratwood purchase_item_type).
	var/purchase_path
	var/obj/item/purchase_type

/datum/rogue_trade_good/New()
	. = ..()
	var/path = text2path(item_path)
	if(ispath(path, /obj/item))
		item_type = path
	for(var/alt_path in alt_item_paths)
		var/alt = text2path(alt_path)
		if(ispath(alt, /obj/item))
			LAZYADD(alt_item_types, alt)
	var/reagent = text2path(reagent_path)
	if(ispath(reagent, /datum/reagent))
		reagent_type = reagent
		var/container = text2path(purchase_path)
		if(ispath(container, /obj/item))
			purchase_type = container

/datum/rogue_trade_good/Destroy()
	stock = null
	return ..()

/// Finished items and potions are delivered at the warehouse docks, not through the stockpile.
/datum/rogue_trade_good/proc/finished()
	return behavior == ROGUE_GOOD_EQUIPMENT || behavior == ROGUE_GOOD_POTION

/// The good's price before the market moves it: its item's derived price, or its trade price (Ratwood compute_good_unit_payout()).
/datum/rogue_trade_good/proc/unit_price()
	if(item_type)
		var/derived = GLOB.rogue_derived_prices[item_type]
		if(derived)
			return derived
	return base_price

/// The good's price on the market now (Ratwood base_price × global_price_mod).
/datum/rogue_trade_good/proc/market_price()
	return max(1, round(unit_price() * global_price_mod))

/// The item is this good (Ratwood identify_trade_good(), scan_equipment_availability()).
/datum/rogue_trade_good/proc/accepts(obj/item/thing)
	if(item_type && (accept_subtypes ? istype(thing, item_type) : thing.type == item_type))
		return TRUE
	return LAZYLEN(alt_item_types) && (thing.type in alt_item_types)

/// Units of a finished good a thing left at the warehouse docks counts for: a container by the potion in it, an item once.
/datum/rogue_trade_good/proc/dock_units(obj/item/thing)
	if(behavior == ROGUE_GOOD_POTION)
		return potion_units(thing)
	return accepts(thing) ? 1 : 0

/// Units of the potion a container holds (Ratwood scan_potion_availability()).
/datum/rogue_trade_good/proc/potion_units(obj/item/thing)
	if(!reagent_type || required_volume <= 0 || !thing.reagents)
		return 0
	return thing.reagents.get_reagent_amount(reagent_type) / required_volume

/**
 * A region of the realm (Ratwood /datum/economic_region): how many units of each good it produces and demands a day. Data in
 * economy/trade_data.dm.
 */
/datum/rogue_trade_region
	var/id
	var/name = ""
	var/subtitle = ""
	/// Good id -> units a day at the baseline population.
	var/list/produces = list()
	var/list/demands = list()
	/// Keys of the standing order templates the region posts.
	var/list/order_templates = list()
	/// Good id -> units it still produces, and still wants, today.
	var/list/produces_today = list()
	var/list/demands_today = list()

/datum/rogue_trade_region/proc/new_day(pop_mult)
	produces_today = list()
	for(var/id in produces)
		produces_today[id] = max(1, round(produces[id] * pop_mult))
	demands_today = list()
	for(var/id in demands)
		demands_today[id] = max(1, round(demands[id] * pop_mult))

/**
 * Price of the next unit of a good from this region (or of the one so many units further), dearer the more it has sold past
 * its daily pace, double on a held road (Ratwood compute_import_unit_price() with TRADE_ESCALATION_SLOPE and
 * BLOCKADE_IMPORT_MULT); 0 if it does not produce the good.
 */
/datum/rogue_trade_region/proc/import_unit_cost(datum/rogue_trade_good/good, further = 0)
	var/pace = produces[good.id]
	if(!pace)
		return 0
	var/unit_index = max(0, pace - (produces_today[good.id] || 0)) + 1 + further
	var/overshoot = max(0, (unit_index - pace) / pace)
	var/held = blockaded ? rogue_value("trade_blockade_import_mult") : 1
	return max(1, round(good.base_price * (1 + overshoot * rogue_value("trade_escalation_slope")) * good.global_price_mod * held))

/**
 * What this region pays for the next unit of a good (or the one so many units further): the good's market price less the
 * import-export spread, less and less past its daily wants, half on a held road, never under a floor share of the trade price
 * (Ratwood compute_export_unit_price(), low_price); 0 if it does not want the good.
 */
/datum/rogue_trade_region/proc/export_unit_price(datum/rogue_trade_good/good, further = 0)
	var/pace = demands[good.id]
	if(!pace)
		return 0
	var/unit_index = max(0, pace - (demands_today[good.id] || 0)) + 1 + further
	var/overshoot = max(0, (unit_index - pace) / pace)
	var/held = blockaded ? rogue_value("trade_blockade_export_mult") : 1
	var/price = good.base_price * good.global_price_mod / (1 + overshoot * rogue_value("trade_escalation_slope")) * (1 - ROGUE_TRADE_SPREAD) * held
	return max(round(price), round(good.base_price * rogue_value("trade_export_floor_share")), 1)

/// One unit bought from the region (Ratwood manual_import()): its daily produce shrinks.
/datum/rogue_trade_region/proc/take_import(datum/rogue_trade_good/good)
	produces_today[good.id] = (produces_today[good.id] || 0) - 1

/// Names of the goods of a produce or demand list, for the trade windows.
/datum/rogue_trade_region/proc/good_names(list/source)
	. = list()
	for(var/id in source)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		if(good)
			. += good.name

/// What the region produces or wants today, with prices, for the Steward's trade window.
/datum/rogue_trade_region/proc/trade_lines(importing)
	. = list()
	var/list/pace_list = importing ? produces : demands
	var/list/today = importing ? produces_today : demands_today
	for(var/id in pace_list)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		if(!good?.stock)
			continue
		var/datum/rogue_economic_event/event = SSrogue_trade.event_for_good(id)
		. += list(list(
			"id" = id,
			"name" = good.name,
			"today" = max(0, today[id] || 0),
			"pace" = max(1, round(pace_list[id] * SSrogue_trade.region_pop_mult())),
			"price" = importing ? import_unit_cost(good) : export_unit_price(good),
			"stocked" = good.stock.stockpile_amount,
			"event" = event?.name,
		))

/**
 * A template of a region's standing order (Ratwood /datum/standing_order subtypes): each mix entry may be in the order (prob),
 * as one of its goods (pick) or, by chance, of another set (or, or_prob), in a random count. Data in economy/trade_data.dm and
 * economy/trade_orders_extra.dm.
 */
/datum/rogue_order_template
	var/key
	var/title = "STANDING ORDER"
	/// Flavor line; %REGION% is the region's name.
	var/description = ""
	/// Flavor naming who orders, for the regions listed in projects: %PROJECT% at %REGION% (Ratwood project_by_region).
	var/project_description
	/// Region id -> who there may post the order.
	var/list/projects
	var/roll_weight = 1
	/// list("goods" = ids, "min" =, "max" =, "prob" =, optionally "or" = ids, "or_prob" =) entries.
	var/list/mix = list()

/datum/rogue_order_template/New()
	. = ..()
	key = copytext("[type]", length("[/datum/rogue_order_template]/") + 1)

/**
 * A standing order of this template from the region (Ratwood instantiate_standing_order()); null if none of its goods are
 * traded: raw goods the Crown stocks, or finished goods with a price.
 */
/datum/rogue_order_template/proc/instantiate(datum/rogue_trade_region/region, petitioned = FALSE)
	var/list/required = list()
	for(var/list/entry as anything in mix)
		if(!prob(entry["prob"]))
			continue
		var/list/pool = entry["goods"]
		if(entry["or"] && prob(entry["or_prob"]))
			pool = entry["or"]
		var/list/options = list()
		for(var/id in pool)
			var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
			if(good && (good.stock || good.finished()) && good.unit_price() > 0)
				options += good
		if(!length(options))
			continue
		var/datum/rogue_trade_good/good = pick(options)
		required[good] = max(required[good] || 0, rand(entry["min"], entry["max"]))
	if(!length(required))
		return null
	var/datum/rogue_standing_order/order = new
	order.id = ++SSrogue_trade.next_order_id
	order.region = region
	order.petitioned = petitioned
	order.title = "[uppertext(region.name)] - [title]"
	var/list/who = projects?[region.id]
	var/flavor = (length(who) && project_description) ? replacetext(project_description, "%PROJECT%", capitalize(pick(who))) : description
	order.description = replacetext(flavor, "%REGION%", region.name)
	order.required = required
	order.dawn_issued = GLOB.rockhill_dawns
	order.dawn_expires = GLOB.rockhill_dawns + rogue_value("trade_order_days")
	order.compute_payout()
	return order

/// An open standing order of a region (Ratwood /datum/standing_order).
/datum/rogue_standing_order
	var/id
	var/datum/rogue_trade_region/region
	var/title
	var/description
	/// Good -> units wanted.
	var/list/required = list()
	/// Mammons the Crown's Purse gets for the whole order (Ratwood total_payout).
	var/payout = 0
	var/dawn_issued
	var/dawn_expires
	/// Posted by a shortage, paying the shortage price (Ratwood /datum/standing_order/urgent).
	var/urgent = FALSE
	/// Posted at the Steward's petition, for a smaller payout (Ratwood petitioned).
	var/petitioned = FALSE
	/// Orders posted together and expiring together, each filled apart (Ratwood pair_id).
	var/pair_id

/datum/rogue_standing_order/Destroy()
	region = null
	required = null
	return ..()

/**
 * What the order pays per unit of a good (Ratwood compute_good_unit_payout()): its price with the standing order bonus, or for
 * an urgent order its price as the shortage moved it.
 */
/datum/rogue_standing_order/proc/unit_payout(datum/rogue_trade_good/good)
	if(urgent)
		return CEILING(good.unit_price() * max(1, good.global_price_mod), 1)
	return CEILING(good.unit_price() * (1 + rogue_value("trade_order_bonus")), 1)

/// Ratwood compute_order_payout(): the whole order at its unit prices, less the petition's share.
/datum/rogue_standing_order/proc/compute_payout()
	payout = 0
	for(var/datum/rogue_trade_good/good as anything in required)
		payout += unit_payout(good) * required[good]
	if(petitioned)
		payout = round(payout * rogue_value("trade_petition_payout"))

/datum/rogue_standing_order/proc/ui_entry()
	var/list/at_docks = finished_at_docks()
	var/list/lines = list()
	for(var/datum/rogue_trade_good/good as anything in required)
		var/list/found = at_docks[good]
		lines += list(list(
			"name" = good.name,
			"needed" = required[good],
			"stocked" = good.finished() ? (found ? found["units"] : 0) : (good.stock?.stockpile_amount || 0),
			"finished" = good.finished(),
		))
	return list(
		"id" = id,
		"title" = title,
		"description" = description,
		"region" = region.name,
		"blockaded" = region.blockaded,
		"payout" = payout,
		"days_left" = max(0, dawn_expires - GLOB.rockhill_dawns),
		"urgent" = urgent,
		"petitioned" = petitioned,
		"paired" = !!pair_id,
		"lines" = lines,
	)

/**
 * A foreign realm whose ships call at the harbor (Ratwood /datum/foreign_realm): ship names, captains and the cargo its ships
 * buy and sell. Data in economy/trade_data.dm; its conditions, provisions and cultural stock in economy/trade_extra_data.dm.
 */
/datum/rogue_foreign_realm
	var/id
	var/name = ""
	var/roll_weight = 10
	var/list/ship_name_words = list()
	/// Ship names are one word, not two (Ratwood single_word_base).
	var/single_word_base = FALSE
	var/list/captain_first_names = list()
	var/list/captain_last_names = list()
	/// list("name" =, "tonnage" =, "weight" =) entries.
	var/list/ship_types = list()
	/// list("text" =, "chance" =) entries; the first that rolls is used.
	var/list/name_prefixes = list()
	var/list/name_suffixes = list()
	var/list/city_tags = list()
	var/city_tag_chance = 0
	/// list("good" =, "qty_min" =, "qty_max" =, "price_mod" =, "always" =) entries: what its ships buy and sell.
	var/list/demand_pool = list()
	var/list/supply_pool = list()
	var/list/hail_lines = list()

/datum/rogue_foreign_realm/proc/pick_ship_type()
	var/list/weighted = list()
	for(var/list/entry as anything in ship_types)
		weighted[entry] = entry["weight"] || 1
	return length(weighted) ? pick_weight(weighted) : null

/// Ratwood generate_ship_name() without the saints' names of Otava.
/datum/rogue_foreign_realm/proc/ship_name()
	var/base = "Vessel"
	if(length(ship_name_words) == 1 || (single_word_base && length(ship_name_words)))
		base = pick(ship_name_words)
	else if(length(ship_name_words))
		var/list/words = ship_name_words.Copy()
		var/first = pick_n_take(words)
		base = "[first] [pick(words)]"
	return "[roll_affix(name_prefixes)][base][roll_affix(name_suffixes)]"

/datum/rogue_foreign_realm/proc/roll_affix(list/affixes)
	for(var/list/entry as anything in affixes)
		if(prob(entry["chance"]))
			return entry["text"]
	return ""

/datum/rogue_foreign_realm/proc/captain_name()
	return "[length(captain_first_names) ? pick(captain_first_names) : "Unnamed"] [length(captain_last_names) ? pick(captain_last_names) : "Captain"]"

/datum/rogue_foreign_realm/proc/port_of_origin()
	return (length(city_tags) && prob(city_tag_chance)) ? pick(city_tags) : ""

/datum/rogue_foreign_realm/proc/pick_hail_line()
	return length(hail_lines) ? pick(hail_lines) : null

/**
 * A foreign trading ship (Ratwood /datum/trade_ship): it waits offshore for the day, or lies at the pier for an hour buying
 * the cargo of its demand lines and the provisions it lacks at the harbor and selling the cargo of its supply lines and its
 * realm's cultural stock. Its size scales its cargo.
 */
/datum/rogue_trade_ship
	var/id
	var/datum/rogue_foreign_realm/realm
	var/name
	var/captain
	var/ship_type = "Ship"
	var/port_of_origin = ""
	var/tonnage = ROGUE_SHIP_DEFAULT_TONNAGE
	var/state = ROGUE_SHIP_OFFSHORE
	var/docked_at = 0
	var/dock_expires_at = 0
	/// Came in unbidden: may be sent away at once and never gives a hail back.
	var/auto_hailed = FALSE
	/// Mammons traded with the ship, and how much its captain hopes for (Ratwood favor_earned, expected_favor).
	var/traded = 0
	var/expected_trade = 0
	/// Cargo lines: list(ROGUE_LINE_GOOD = good, ROGUE_LINE_TARGET =, ROGUE_LINE_DONE =, ROGUE_LINE_PRICE =).
	var/list/demands = list()
	var/list/supplies = list()
	/// Provisions it buys (economy/ship_trade.dm) and the cultural stock it sells.
	var/list/provisions = list()
	var/list/cultural_stock = list()

/datum/rogue_trade_ship/New(datum/rogue_foreign_realm/from_realm, new_id)
	. = ..()
	realm = from_realm
	id = new_id
	var/list/picked = realm.pick_ship_type()
	var/listed = ROGUE_SHIP_DEFAULT_TONNAGE
	if(picked)
		ship_type = picked["name"]
		listed = picked["tonnage"] || ROGUE_SHIP_DEFAULT_TONNAGE
	var/swing = listed * ROGUE_SHIP_TONNAGE_VARIANCE
	tonnage = round(listed + rand(-swing, swing))
	name = realm.ship_name()
	captain = realm.captain_name()
	port_of_origin = realm.port_of_origin()
	expected_trade = round(rogue_value("trade_ship_expected_trade") * scale())
	demands = roll_lines(realm.effective_pool(FALSE), FALSE)
	supplies = roll_lines(realm.effective_pool(TRUE), TRUE)
	roll_provisions()
	roll_cultural_stock()

/datum/rogue_trade_ship/Destroy()
	realm = null
	demands = null
	supplies = null
	provisions = null
	cultural_stock = null
	return ..()

/// Bigger ships carry more, up to twice the default (Ratwood tonnage_scale_mult()).
/datum/rogue_trade_ship/proc/scale()
	return clamp(1 + (tonnage - ROGUE_SHIP_DEFAULT_TONNAGE) / ROGUE_SHIP_TONNAGE_SCALE_SPAN, 1, ROGUE_SHIP_TONNAGE_SCALE_CAP)

/// The captain got the trade he hoped for (Ratwood: favor earned at least the expected favor).
/datum/rogue_trade_ship/proc/honored()
	return expected_trade > 0 && traded >= expected_trade

/// The ship comes from the merchant's homeland (Ratwood current_kinship_realm).
/datum/rogue_trade_ship/proc/kin()
	return realm && realm.id == SSrogue_trade.kinship_realm

/// Every line the realm always trades, and a few of the rest (Ratwood roll_bulk_pool()).
/datum/rogue_trade_ship/proc/roll_lines(list/pool, supply)
	. = list()
	var/list/rare = list()
	for(var/list/entry as anything in pool)
		if(!SSrogue_trade.goods[entry["good"]])
			continue
		if(entry["always"])
			var/list/line = build_line(entry, supply)
			if(line)
				. += list(line)
		else
			rare += list(entry)
	if(!length(rare))
		return
	var/count = rand(ROGUE_SHIP_BULK_LINES_MIN, min(ROGUE_SHIP_BULK_LINES_MAX, length(rare)))
	for(var/i in 1 to count)
		if(!length(rare))
			break
		var/list/line = build_line(pick_n_take(rare), supply)
		if(line)
			. += list(line)

/// A cargo line: a count scaled by the ship's size (half for what it sells) and a price around the good's trade price times
/// the realm's markup (Ratwood build_bulk_line()).
/datum/rogue_trade_ship/proc/build_line(list/entry, supply)
	var/datum/rogue_trade_good/good = SSrogue_trade.goods[entry["good"]]
	if(!good)
		return null
	var/qty = round(rand(entry["qty_min"], entry["qty_max"]) * scale() * (supply ? rogue_value("trade_supply_share") : 1))
	var/jitter = 1 - ROGUE_SHIP_PRICE_JITTER + rand() * ROGUE_SHIP_PRICE_JITTER * 2
	var/price = max(1, round(good.base_price * entry["price_mod"] * jitter))
	return list(
		ROGUE_LINE_GOOD = good,
		ROGUE_LINE_TARGET = max(1, qty),
		ROGUE_LINE_DONE = 0,
		ROGUE_LINE_PRICE = price,
	)

/datum/rogue_trade_ship/proc/ui_lines(list/lines)
	. = list()
	for(var/list/line as anything in lines)
		var/datum/rogue_trade_good/good = line[ROGUE_LINE_GOOD]
		. += list(list(
			"good" = good.id,
			"name" = good.name,
			"target" = line[ROGUE_LINE_TARGET],
			"done" = line[ROGUE_LINE_DONE],
			"price" = line[ROGUE_LINE_PRICE],
		))

/datum/rogue_trade_ship/proc/ui_entry()
	return list(
		"id" = id,
		"name" = name,
		"captain" = captain,
		"ship_type" = ship_type,
		"tonnage" = tonnage,
		"realm" = realm.name,
		"port" = port_of_origin,
		"docked" = state == ROGUE_SHIP_DOCKED,
		"minutes_left" = state == ROGUE_SHIP_DOCKED ? max(0, round((dock_expires_at - world.time) / (1 MINUTES))) : 0,
		"traded" = traded,
		"expected" = expected_trade,
		"kin" = kin(),
		"conditions" = realm.condition_entries(),
		"demands" = ui_lines(demands),
		"supplies" = ui_lines(supplies),
		"provisions" = ui_provisions(),
		"cultural" = ui_cultural_stock(),
	)

#undef ROGUE_GOOD_EQUIPMENT
#undef ROGUE_GOOD_POTION
