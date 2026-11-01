/**
 * GOLDFACE (Ratwood code/modules/roguetown/roguemachine/merchant/_goldface.dm): the merchant's import machine. Coins go in, packs
 * of goods from afar come out at the buyer's feet; the Crown takes its import tariff on every pack into the Crown's Purse. The
 * merchant's key locks it; the merchant may stop paying the tariff, which the machine tallies. SILVERFACEs are public copies that
 * add the porters' margin and cannot be locked; the guild ones sell their trade's goods; the COPPERFACE sells contraband untaxed.
 * The harbor and the trade ships live in harbor.dm; Ratwood's catalogs and the merchant's favor are not ported.
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
	data["proprietor"] = !is_public && (user.mind?.assigned_role?.title in profit_jobs)
	data["tariff_paid"] = tariff_paid
	data["tariff_dodged"] = tariff_dodged
	return data

/obj/structure/roguemachine/goldface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || locked)
		return
	var/mob/living/user = ui.user
	switch(action)
		if("change")
			return_change(user)
			return TRUE
		if("toggle_tariff")
			if(is_public || !(user.mind?.assigned_role?.title in profit_jobs))
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
	var/turf/spot = get_turf(user)
	for(var/ware_type in pack.contains)
		new ware_type(spot)
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
