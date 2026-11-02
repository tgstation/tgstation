// The merchant's favor with the trading company (Ratwood code/controllers/subsystem/rogue/merchant_trade.dm resolve_ship_favor(),
// adjust_merchant_favor(), the upgrades, and merchant/trade/merchant_catalog.dm): every ship that leaves weighs the trade it
// got against what its captain hoped for, and the company's favor follows; every purchase at a GOLDFACE earns a little more.
// Favor buys the company's services (an extra pier, a harbor crew that hails and dismisses ships, gnomes that collect the
// SILVERFACEs' margin for the merchant fund) and opens its catalogs, whose stock refills every dawn.
// Not ported: Ratwood's triumph bonus by the favor's high-water mark, and the navigator's share of favor (the navigator is Б9б's).

/datum/controller/subsystem/rogue_trade
	/// The company's favor now and the most it ever was (Ratwood merchant_favor, merchant_favor_high).
	var/merchant_favor = 0
	var/merchant_favor_high = 0
	var/favor_from_sendoffs = 0
	var/favor_from_goldface = 0
	var/favor_from_silverface = 0
	var/favor_penalties = 0
	/// The last ships' outcomes, newest first (Ratwood favor_ledger).
	var/list/favor_ledger = list()
	/// Services bought with favor (Ratwood extra_pier_rented, auto_hailer_unlocked, gnome_automation_unlocked).
	var/extra_pier = FALSE
	var/auto_hailer = FALSE
	var/auto_hailer_on = FALSE
	var/gnome_automation = FALSE
	/// Margin of the public SILVERFACEs the gnomes collected for the merchant fund (Ratwood gnome_margin_collected).
	var/gnome_margin_collected = 0
	/// When the harbor crew next works the pier (Ratwood AUTO_HAILER_TICK_INTERVAL).
	var/next_auto_hailer = 0
	/// Catalog id -> catalog, the ones the company opened, and catalog id -> pack path -> units left today.
	var/list/catalogs = list()
	var/list/unlocked_catalogs = list()
	var/list/catalog_stock = list()

/datum/controller/subsystem/rogue_trade/proc/adjust_favor(amount, allow_negative = FALSE)
	merchant_favor += amount
	if(!allow_negative)
		merchant_favor = max(0, merchant_favor)
	merchant_favor_high = max(merchant_favor_high, merchant_favor)
	return merchant_favor

/datum/controller/subsystem/rogue_trade/proc/spend_favor(amount)
	if(amount <= 0 || merchant_favor < amount)
		return FALSE
	merchant_favor -= amount
	return TRUE

/**
 * Ratwood resolve_ship_favor(): a captain who got all he hoped for honors the company with favor for all of it and gives back a
 * hail; one who got half earns half; less is a dishonor that costs favor by the ship's size. A ship that came unbidden is
 * merely content; one whose time ran out may cost favor below nothing.
 */
/datum/controller/subsystem/rogue_trade/proc/resolve_ship_favor(datum/rogue_trade_ship/ship, auto = FALSE)
	if(!ship)
		return
	var/ratio = ship.traded / max(1, ship.expected_trade)
	var/outcome
	var/awarded = 0
	var/refunded = FALSE
	if(ship.auto_hailed)
		outcome = ROGUE_FAVOR_PARTIAL
	else if(ratio >= 1)
		outcome = ROGUE_FAVOR_HONORED
		awarded = round(ship.traded)
		if(hails_left < rogue_value("trade_hails_per_day"))
			hails_left++
			refunded = TRUE
	else if(ratio >= rogue_value("trade_favor_partial_threshold"))
		outcome = ROGUE_FAVOR_PARTIAL
		awarded = round(ship.traded * rogue_value("trade_favor_partial_share"))
	else
		outcome = ROGUE_FAVOR_DISHONORED
		awarded = -round(rogue_value("trade_favor_dishonor") * ship.scale())
	adjust_favor(awarded, auto)
	if(awarded >= 0)
		favor_from_sendoffs += awarded
	else
		favor_penalties -= awarded
	favor_ledger.Insert(1, list(list(
		"realm" = ship.realm.name,
		"ship" = ship.name,
		"outcome" = outcome,
		"traded" = ship.traded,
		"expected" = ship.expected_trade,
		"awarded" = awarded,
		"refunded_hail" = refunded,
	)))
	if(length(favor_ledger) > 8)
		favor_ledger.Cut(9)

/// Ratwood's passive favor: a share of every purchase at a GOLDFACE or SILVERFACE.
/datum/controller/subsystem/rogue_trade/proc/favor_for_purchase(price, public)
	var/passive = round(price * rogue_value("trade_favor_purchase_share"))
	if(passive <= 0)
		return
	adjust_favor(passive)
	if(public)
		favor_from_silverface += passive
	else
		favor_from_goldface += passive

/// Favor a service of the company costs (Ratwood ADDITIONAL_PIER_FAVOR, AUTO_HAILER_FAVOR, GNOME_AUTOMATION_FAVOR).
/datum/controller/subsystem/rogue_trade/proc/upgrade_cost(upgrade)
	switch(upgrade)
		if(ROGUE_UPGRADE_PIER)
			return rogue_value("trade_favor_pier")
		if(ROGUE_UPGRADE_HAILER)
			return rogue_value("trade_favor_hailer")
		if(ROGUE_UPGRADE_GNOMES)
			return rogue_value("trade_favor_gnomes")
	return 0

/datum/controller/subsystem/rogue_trade/proc/has_upgrade(upgrade)
	switch(upgrade)
		if(ROGUE_UPGRADE_PIER)
			return extra_pier
		if(ROGUE_UPGRADE_HAILER)
			return auto_hailer
		if(ROGUE_UPGRADE_GNOMES)
			return gnome_automation
	return FALSE

/// Buys a service of the company with favor (Ratwood try_favor_unlock()). Returns null on success or why it failed.
/datum/controller/subsystem/rogue_trade/proc/buy_upgrade(upgrade, mob/user)
	var/cost = upgrade_cost(upgrade)
	if(!cost)
		return "No such service."
	if(has_upgrade(upgrade))
		return "The company already provides it."
	if(!spend_favor(cost))
		return "Not enough favor with the Company."
	switch(upgrade)
		if(ROGUE_UPGRADE_PIER)
			extra_pier = TRUE
		if(ROGUE_UPGRADE_HAILER)
			auto_hailer = TRUE
		if(ROGUE_UPGRADE_GNOMES)
			gnome_automation = TRUE
	log_game("MERCHANT FAVOR: [key_name(user)] bought the company's [upgrade] for [cost] favor")
	return null

/datum/controller/subsystem/rogue_trade/proc/toggle_auto_hailer()
	if(!auto_hailer)
		return FALSE
	auto_hailer_on = !auto_hailer_on
	next_auto_hailer = world.time
	return TRUE

/**
 * Ratwood auto_hailer_tick(): while the merchant keeps the harbor crew working, every few minutes it sends off the ships whose
 * captains are satisfied or whose time at the pier ran long, and hails offshore ships into the free piers while hails last.
 */
/datum/controller/subsystem/rogue_trade/proc/auto_hailer_tick()
	if(!auto_hailer || !auto_hailer_on || world.time < next_auto_hailer)
		return
	next_auto_hailer = world.time + rogue_value("trade_auto_hailer_interval")
	for(var/datum/rogue_trade_ship/ship as anything in docked_ships())
		if(ship.honored() || world.time >= ship.docked_at + rogue_value("trade_auto_hailer_timeout"))
			depart(ship, TRUE)
	var/free_piers = dock_spots() - length(docked_ships())
	while(free_piers > 0 && hails_left > 0)
		var/datum/rogue_trade_ship/ship = pick_offshore_ship()
		if(!ship)
			break
		hails_left--
		dock(ship)
		free_piers--

/// The favor ledger and services, for the GOLDFACE's window.
/datum/controller/subsystem/rogue_trade/proc/favor_ui_data()
	var/list/services = list()
	for(var/upgrade in list(ROGUE_UPGRADE_PIER, ROGUE_UPGRADE_HAILER, ROGUE_UPGRADE_GNOMES))
		services += list(list("id" = upgrade, "cost" = upgrade_cost(upgrade), "owned" = has_upgrade(upgrade)))
	return list(
		"current" = merchant_favor,
		"high" = merchant_favor_high,
		"from_sendoffs" = favor_from_sendoffs,
		"from_goldface" = favor_from_goldface,
		"from_silverface" = favor_from_silverface,
		"penalties" = favor_penalties,
		"ledger" = favor_ledger,
		"services" = services,
		"hailer_on" = auto_hailer_on,
		"gnome_margin" = gnome_margin_collected,
	)

// Catalogs.

/**
 * A catalog of the trading company (Ratwood /datum/merchant_catalog): a supplier whose wares the merchant's GOLDFACE sells once
 * the company opens it for favor, a few units of each a day. Packs are module paths the porter brings; data in
 * economy/trade_extra_data.dm.
 */
/datum/rogue_merchant_catalog
	var/id
	var/name = ""
	var/desc = ""
	/// Pack path text -> units a day.
	var/list/stock = list()

/// Favor it costs to open (Ratwood ROSAWOOD_ARSENAL_FAVOR, UNDERDARK_CARAVAN_FAVOR).
/datum/rogue_merchant_catalog/proc/favor_cost()
	switch(id)
		if("rosawood")
			return rogue_value("trade_favor_catalog_rosawood")
		if("underdark")
			return rogue_value("trade_favor_catalog_underdark")
	return rogue_value("trade_favor_catalog_rosawood")

/// The packs of it the porter has brought: pack type -> pack.
/datum/rogue_merchant_catalog/proc/available_packs()
	var/list/packs = list()
	for(var/path_text in stock)
		var/pack_type = text2path(path_text)
		var/datum/rogue_supply_pack/pack = pack_type ? GLOB.rogue_supply_packs[pack_type] : null
		if(pack)
			packs[pack_type] = pack
	return packs

/datum/controller/subsystem/rogue_trade/proc/setup_catalogs()
	for(var/catalog_type in subtypesof(/datum/rogue_merchant_catalog))
		var/datum/rogue_merchant_catalog/catalog = new catalog_type
		if(catalog.id)
			catalogs[catalog.id] = catalog
		else
			qdel(catalog)
	restock_catalogs()

/// Ratwood restock_catalogs(): every dawn each catalog has its daily units again.
/datum/controller/subsystem/rogue_trade/proc/restock_catalogs()
	for(var/id in catalogs)
		var/datum/rogue_merchant_catalog/catalog = catalogs[id]
		var/list/counts = list()
		for(var/path_text in catalog.stock)
			var/pack_type = text2path(path_text)
			if(pack_type)
				counts[pack_type] = catalog.stock[path_text]
		catalog_stock[id] = counts

/// Ratwood unlock_catalog(): the company opens a catalog for favor. Returns null on success or why it failed.
/datum/controller/subsystem/rogue_trade/proc/unlock_catalog(catalog_id, mob/user)
	var/datum/rogue_merchant_catalog/catalog = catalogs[catalog_id]
	if(!catalog)
		return "No such catalog."
	if(catalog_id in unlocked_catalogs)
		return "The [catalog.name] is already open to the company."
	if(!spend_favor(catalog.favor_cost()))
		return "Not enough favor with the Company to open the [catalog.name]."
	unlocked_catalogs += catalog_id
	log_game("MERCHANT FAVOR: [key_name(user)] opened the [catalog.name] catalog")
	return null

/datum/controller/subsystem/rogue_trade/proc/catalog_units_left(catalog_id, pack_type)
	var/list/counts = catalog_stock[catalog_id]
	return counts ? (counts[pack_type] || 0) : 0

/// Takes a unit of a catalog's pack for a sale. Returns TRUE if one was left.
/datum/controller/subsystem/rogue_trade/proc/take_catalog_unit(catalog_id, pack_type)
	var/list/counts = catalog_stock[catalog_id]
	if(!counts || (counts[pack_type] || 0) <= 0)
		return FALSE
	counts[pack_type]--
	return TRUE
