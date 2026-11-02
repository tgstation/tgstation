/**
 * GOLDFACE (Ratwood code/modules/roguetown/roguemachine/merchant/_goldface.dm): the merchant's import machine. Coins go in, packs
 * of goods from afar come out at the buyer's feet under the trading company's seal; the Crown takes its import tariff on every
 * pack into the Crown's Purse, and every purchase earns the merchant a little favor with the company. The merchant's key locks
 * it; the merchant may stop paying the tariff, which the machine tallies. The merchant's own GOLDFACE is the company's counter:
 * it shows the favor and its ledger, buys the company's services with favor and sells the catalogs the company opened
 * (economy/merchant_favor.dm). SILVERFACEs are public copies that add the porters' margin and cannot be locked (the company's
 * gnomes collect that margin for the merchant fund once hired); the guild ones sell their trade's goods; the COPPERFACE sells
 * contraband untaxed. The harbor and the trade ships live in harbor.dm.
 */
/obj/structure/roguemachine/goldface
	var/locked = FALSE
	/// Lockid of the key that locks it; null when it cannot be locked.
	var/lockid = "merchant"
	var/motto = "GOLDFACE - In the name of greed."
	/// Pack categories it sells (Ratwood categories and categories_gamer).
	var/list/categories = list(
		"Alcohols",
		"Apparel",
		"Consumable",
		"Cosmetics",
		"Food",
		"Games",
		"Gems",
		"Instruments",
		"Luxury",
		"Livestock",
		"Magic",
		"Perfumes",
		"Seeds",
		"Substances",
		"Tools",
		"Wardrobe",
		"Zadpacks",
		"Adventuring Supplies",
		"Armor (Light)",
		"Armor (Iron)",
		"Armor (Bronze)",
		"Armor (Steel)",
		"Armor (Exotic)",
		"Potions",
		"Weapons (Ranged)",
		"Weapons (Iron and Shields)",
		"Weapons (Bronze)",
		"Weapons (Steel)",
		"Weapons (Foreign)",
	)
	/// Public copy: no lock, no packs marked not for the public, the porters' margin on top.
	var/is_public = FALSE
	/// Share added to a pack's cost (Ratwood extra_fee).
	var/extra_fee = 0
	/// Never pays the tariff (the COPPERFACE).
	var/bypass_tax = FALSE
	/// The proprietor stopped paying the tariff (Ratwood UPGRADE_NOTAX).
	var/dodging_tax = FALSE
	/// Roles that run it and may stop paying the tariff (Ratwood profit_id).
	var/list/profit_jobs = list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
	/// Tariff paid and dodged at this machine, for the proprietor's audit.
	var/tariff_paid = 0
	var/tariff_dodged = 0
	/// Wares drawn over the machine.
	var/shelf_overlay = "vendor-merch"

/obj/structure/roguemachine/goldface/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/roguemachine/goldface/update_overlays()
	. = ..()
	set_light(1, 1, "#1b7bf1")
	if(shelf_overlay)
		. += mutable_appearance(icon, shelf_overlay)

/obj/structure/roguemachine/goldface/examine(mob/user)
	. = ..()
	if(is_public)
		. += span_info("A public version of the GOLDFACE. The company charges a hefty fee for its usage. Per agreement, it cannot be locked by anyone.")

/// The merchant's own GOLDFACE: the counter of the trading company, with its favor, services and catalogs (Ratwood is_command_center).
/obj/structure/roguemachine/goldface/proc/command_center()
	return !is_public && !bypass_tax && lockid == "merchant"

/obj/structure/roguemachine/goldface/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		if(is_public || !lockid)
			to_chat(user, span_warning("This is a public vendor. Keys won't work here."))
			return ITEM_INTERACT_BLOCKING
		if(!rockhill_key_fits(tool, lockid))
			to_chat(user, span_warning("Wrong key."))
			return ITEM_INTERACT_BLOCKING
		locked = !locked
		playsound(src, ROGUE_SOUND_GOLD_MISC, 100, FALSE, -1)
		if(locked)
			SStgui.close_uis(src)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		take_coins(tool, user)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/roguemachine/goldface/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	if(locked)
		to_chat(user, span_warning("It's locked. Of course."))
		return TRUE
	return ..()

/obj/structure/roguemachine/goldface/ui_interact(mob/user, datum/tgui/ui)
	if(locked)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(src, ROGUE_SOUND_GOLD_MENU, 100, FALSE, -1)
		ui = new(user, src, "RogueGoldface", name)
		ui.open()

/// The pack is on this machine's shelves.
/obj/structure/roguemachine/goldface/proc/sells(datum/rogue_supply_pack/pack)
	return pack && (pack.group in categories) && !(is_public && pack.not_in_public)

/obj/structure/roguemachine/goldface/proc/pays_tariff()
	return !bypass_tax && !dodging_tax

/// The Crown's import tariff on a pack (Ratwood compute_pack_tax()).
/obj/structure/roguemachine/goldface/proc/pack_tariff(datum/rogue_supply_pack/pack)
	return round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * pack.cost)

/// A pack's price with the margin, without the tariff.
/obj/structure/roguemachine/goldface/proc/pack_base(datum/rogue_supply_pack/pack)
	return round(pack.cost + pack.cost * extra_fee)

/obj/structure/roguemachine/goldface/ui_static_data(mob/user)
	var/list/data = list()
	data["motto"] = motto
	data["categories"] = categories
	data["is_public"] = is_public
	data["command_center"] = command_center()
	var/list/packs = list()
	for(var/pack_type in GLOB.rogue_supply_packs)
		var/datum/rogue_supply_pack/pack = GLOB.rogue_supply_packs[pack_type]
		if(!sells(pack))
			continue
		packs += list(list(
			"ref" = "[pack_type]",
			"name" = pack.name,
			"category" = pack.group,
			"qty" = pack.no_name_quantity ? 1 : length(pack.contains),
			"cost" = pack.cost,
			"base" = pack_base(pack),
		))
	data["packs"] = packs
	return data

/obj/structure/roguemachine/goldface/ui_data(mob/user)
	var/list/data = list()
	data["budget"] = budget
	data["tariff_rate"] = pays_tariff() ? SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) : 0
	data["dodging"] = dodging_tax
	var/proprietor = !is_public && (user.mind?.assigned_role?.title in profit_jobs)
	data["proprietor"] = proprietor
	data["tariff_paid"] = tariff_paid
	data["tariff_dodged"] = tariff_dodged
	if(command_center())
		data["favor"] = SSrogue_trade.favor_ui_data()
		data["catalogs"] = catalog_ui_data()
	return data

/// The company's catalogs, open or not, with what each sells today (Ratwood build_catalog_data()).
/obj/structure/roguemachine/goldface/proc/catalog_ui_data()
	var/datum/controller/subsystem/rogue_trade/trade = SSrogue_trade
	var/list/catalogs = list()
	for(var/catalog_id in trade.catalogs)
		var/datum/rogue_merchant_catalog/catalog = trade.catalogs[catalog_id]
		var/list/packs = list()
		var/list/available = catalog.available_packs()
		for(var/pack_type in available)
			var/datum/rogue_supply_pack/pack = available[pack_type]
			packs += list(list(
				"ref" = "[pack_type]",
				"name" = pack.name,
				"cost" = pack.cost,
				"left" = trade.catalog_units_left(catalog_id, pack_type),
			))
		catalogs += list(list(
			"id" = catalog_id,
			"name" = catalog.name,
			"desc" = catalog.desc,
			"favor_cost" = catalog.favor_cost(),
			"open" = (catalog_id in trade.unlocked_catalogs),
			"packs" = packs,
			"stocked" = length(catalog.stock),
		))
	return catalogs

/obj/structure/roguemachine/goldface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || locked)
		return
	var/mob/living/user = ui.user
	var/proprietor = !is_public && (user.mind?.assigned_role?.title in profit_jobs)
	switch(action)
		if("change")
			return_change(user)
			return TRUE
		if("toggle_tariff")
			if(!proprietor)
				return TRUE
			dodging_tax = !dodging_tax
			playsound(src, ROGUE_SOUND_GOLD_MISC, 100, FALSE, -1)
			return TRUE
		if("buy")
			var/datum/rogue_supply_pack/pack = GLOB.rogue_supply_packs[text2path(params["ref"])]
			if(!sells(pack))
				return TRUE
			buy_pack(pack, user)
			return TRUE
	if(!command_center() || !proprietor)
		return TRUE
	SSrogue_trade.touch_merchant_activity()
	switch(action)
		if("upgrade")
			var/failure = SSrogue_trade.buy_upgrade("[params["id"]]", user)
			if(failure)
				to_chat(user, span_warning(failure))
				refuse()
			else
				playsound(src, ROGUE_SOUND_SEAL, 100, FALSE, -1)
		if("toggle_hailer")
			if(SSrogue_trade.toggle_auto_hailer())
				to_chat(user, span_notice("The harbor crew [SSrogue_trade.auto_hailer_on ? "takes up its work at the pier" : "stands down"]."))
		if("unlock_catalog")
			var/failure = SSrogue_trade.unlock_catalog("[params["id"]]", user)
			if(failure)
				to_chat(user, span_warning(failure))
				refuse()
			else
				playsound(src, ROGUE_SOUND_SEAL, 100, FALSE, -1)
		if("catalog_buy")
			buy_catalog_pack("[params["id"]]", text2path(params["ref"]), user)
	return TRUE

/// What the merchant is paid in favor for a purchase, and the gnomes' margin of a public machine (Ratwood "buy").
/obj/structure/roguemachine/goldface/proc/company_takings(datum/rogue_supply_pack/pack, price)
	SSrogue_trade.favor_for_purchase(price, is_public)
	if(!is_public || !SSrogue_trade.gnome_automation)
		return
	var/margin = round(pack.cost * extra_fee)
	var/datum/bank_account/rogue/merchant_fund = SSrogue_treasury.get_fund(ROGUE_FUND_MERCHANT)
	if(margin > 0 && merchant_fund && SSrogue_treasury.mint(merchant_fund, margin, "Company Gnomes margin ([name])"))
		SSrogue_trade.gnome_margin_collected += margin

/// Leaves a pack's wares at the spot under the trading company's seal.
/obj/structure/roguemachine/goldface/proc/deliver_pack(datum/rogue_supply_pack/pack, turf/spot)
	for(var/ware_type in pack.contains)
		var/obj/item/ware = new ware_type(spot)
		if(istype(ware))
			ware.rogue_company_seal = TRUE

/// Sells a pack for the budget (Ratwood "buy"): the tariff goes to the Crown's Purse, the goods drop at the buyer's feet.
/obj/structure/roguemachine/goldface/proc/buy_pack(datum/rogue_supply_pack/pack, mob/living/user)
	var/tariff = pack_tariff(pack)
	var/price = pack_base(pack) + (pays_tariff() ? tariff : 0)
	if(budget < price)
		say("Not enough!")
		return FALSE
	budget -= price
	if(pays_tariff())
		SSrogue_treasury.mint(SSrogue_treasury.crown_purse, tariff, "[ROGUE_TAX_IMPORT] ([name])")
		SSrogue_treasury.apply_concordat_tithe(pack.cost, ROGUE_TAX_IMPORT)
		SSrogue_treasury.total_tariff += tariff
		tariff_paid += tariff
	else if(!bypass_tax)
		tariff_dodged += tariff
	company_takings(pack, price)
	deliver_pack(pack, get_turf(user))
	playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
	return TRUE

/**
 * Sells a pack of an open catalog for the budget (Ratwood "catalog_buy"): the catalog's units for the day run down, the tariff
 * goes to the Crown's Purse unless dodged, the goods drop at the buyer's feet under the company's seal.
 */
/obj/structure/roguemachine/goldface/proc/buy_catalog_pack(catalog_id, pack_type, mob/living/user)
	var/datum/controller/subsystem/rogue_trade/trade = SSrogue_trade
	var/datum/rogue_merchant_catalog/catalog = trade.catalogs[catalog_id]
	if(!catalog || !(catalog_id in trade.unlocked_catalogs))
		to_chat(user, span_warning("That catalog is not open."))
		return FALSE
	var/list/available = catalog.available_packs()
	var/datum/rogue_supply_pack/pack = pack_type ? available[pack_type] : null
	if(!pack)
		return FALSE
	if(trade.catalog_units_left(catalog_id, pack_type) <= 0)
		to_chat(user, span_warning("The [catalog.name] has none of that left. Wait until the next restock."))
		return FALSE
	var/tariff = pays_tariff() ? round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * pack.cost) : 0
	var/price = pack.cost + tariff
	if(budget < price)
		say("Not enough!")
		return FALSE
	budget -= price
	trade.take_catalog_unit(catalog_id, pack_type)
	if(tariff > 0)
		SSrogue_treasury.mint(SSrogue_treasury.crown_purse, tariff, "[ROGUE_TAX_IMPORT] ([name])")
		SSrogue_treasury.apply_concordat_tithe(pack.cost, ROGUE_TAX_IMPORT)
		SSrogue_treasury.total_tariff += tariff
		tariff_paid += tariff
	else if(!bypass_tax)
		tariff_dodged += round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * pack.cost)
	deliver_pack(pack, get_turf(user))
	to_chat(user, span_notice("You order [pack.name] from the [catalog.name] for [price]m[tariff ? " (incl. [tariff]m Crown duty)" : ""]."))
	playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
	return TRUE

/obj/structure/roguemachine/goldface/public
	motto = "SILVERFACE - Commerce for all."
	is_public = TRUE
	extra_fee = 0.5
	categories = list(
		"Adventuring Supplies",
		"Alcohols",
		"Consumable",
		"Cosmetics",
		"Food",
		"Games",
		"Gems",
		"Instruments",
		"Luxury",
		"Livestock",
		"Magic",
		"Perfumes",
		"Seeds",
		"Substances",
		"Tools",
		"Weapons (Foreign)",
	)

/obj/structure/roguemachine/goldface/public/smith
	lockid = "crafterguild"
	profit_jobs = list(JOB_ROCKHILL_GUILDSMAN, JOB_ROCKHILL_GUILDMASTER, JOB_ROCKHILL_TAILOR)
	categories = list(
		"Armor (Iron)",
		"Armor (Bronze)",
		"Armor (Steel)",
		"Armor (Exotic)",
		"Weapons (Ranged)",
		"Weapons (Iron and Shields)",
		"Weapons (Bronze)",
		"Weapons (Steel)",
	)

/obj/structure/roguemachine/goldface/public/tailor
	lockid = "tailor"
	profit_jobs = list(JOB_ROCKHILL_GUILDSMAN, JOB_ROCKHILL_GUILDMASTER, JOB_ROCKHILL_TAILOR)
	categories = list(
		"Apparel",
		"Wardrobe",
		"Armor (Light)",
	)

/obj/structure/roguemachine/goldface/public/apothecary
	lockid = "physician"
	profit_jobs = list(JOB_ROCKHILL_HEAD_PHYSICIAN, JOB_ROCKHILL_APOTHECARY)
	categories = list(
		"Potions",
	)

/obj/structure/roguemachine/goldface/copperface
	motto = "COPPERFACE - Everyone has a price."
	lockid = null
	profit_jobs = list()
	bypass_tax = TRUE
	extra_fee = 0.5
	shelf_overlay = null
	categories = list(
		"Diplomacy and Persuasion",
		"Beverages",
		"Exotic Import",
		"General Labour",
		"Health and Hygiene",
		"Self Defense",
	)
