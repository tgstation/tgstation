/**
 * BRASSFACE (Ratwood code/modules/roguetown/roguemachine/merchant/bathmaster.dm): the bathhouse's import machine, a GOLDFACE
 * for vices. Coins go in, the bathhouse's packs come out at the buyer's feet - as in Ratwood, a pack yields as many wares as it
 * lists, each picked at random from its contents - and the import tariff is paid on each, to the Crown or, while the Ordinance
 * of the Baths holds, to the Church with its tithe (collect_bathhouse_tariff(), fund_income.dm), unless the bathhouse stopped
 * paying it, which the machine tallies. The Nightmaster's key locks it. The bathhouse reads its hoard ledger here (hoard.dm).
 * Packs of Ratwood's Discreet Zads, Drugs, Exotic Apparel, Perfumes, Roguery and Toys appear once the porter brings them.
 */
/obj/structure/roguemachine/bathvend
	var/locked = FALSE
	var/lockid = "nightman"
	var/motto = "BRASSFACE - Sweet Dreams for Cheap"
	/// Pack categories it sells (Ratwood categories).
	var/list/categories = list(
		"Alcohols",
		"Discreet Zads",
		"Drugs",
		"Exotic Apparel",
		"Instruments",
		"Perfumes",
		"Roguery",
		"Toys",
	)
	/// The bathhouse stopped paying the Crown's tariff (Ratwood UPGRADE_NOTAX).
	var/dodging_tax = FALSE
	/// Tariff paid and dodged at this machine, for the Bathmaster's audit.
	var/tariff_paid = 0
	var/tariff_dodged = 0

/obj/structure/roguemachine/bathvend/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/roguemachine/bathvend/update_overlays()
	. = ..()
	set_light(1, 1, "#1b7bf1")
	. += mutable_appearance(icon, "vendor-merch")

/obj/structure/roguemachine/bathvend/examine(mob/user)
	. = ..()
	. += span_info("Insert coins and buy the bathhouse's imports. The Nightmaster's key locks it.")

/obj/structure/roguemachine/bathvend/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		if(!rockhill_key_fits(tool, lockid))
			to_chat(user, span_warning("Wrong key."))
			return ITEM_INTERACT_BLOCKING
		locked = !locked
		playsound(src, ROGUE_SOUND_GOLD_MISC, 100, FALSE, -1)
		if(locked)
			SStgui.close_uis(src)
		else
			ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		if(take_coins(tool, user))
			playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/roguemachine/bathvend/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	if(locked)
		to_chat(user, span_warning("It's locked. Of course."))
		return TRUE
	return ..()

/obj/structure/roguemachine/bathvend/ui_interact(mob/user, datum/tgui/ui)
	if(locked)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(src, ROGUE_SOUND_GOLD_MENU, 100, FALSE, -1)
		ui = new(user, src, "RogueBrassface", name)
		ui.open()

/obj/structure/roguemachine/bathvend/proc/sells(datum/rogue_supply_pack/pack)
	return pack && (pack.group in categories)

/obj/structure/roguemachine/bathvend/proc/pack_tariff(datum/rogue_supply_pack/pack)
	return round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * pack.cost)

/obj/structure/roguemachine/bathvend/ui_static_data(mob/user)
	var/list/data = list()
	data["motto"] = motto
	data["categories"] = categories
	data["is_public"] = FALSE
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
			"base" = pack.cost,
		))
	data["packs"] = packs
	return data

/obj/structure/roguemachine/bathvend/ui_data(mob/user)
	var/list/data = list()
	data["budget"] = budget
	data["tariff_rate"] = dodging_tax ? 0 : SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT)
	data["dodging"] = dodging_tax
	data["proprietor"] = rogue_bathhouse_staff(user, FALSE)
	data["tariff_paid"] = tariff_paid
	data["tariff_dodged"] = tariff_dodged
	var/staff = rogue_bathhouse_staff(user, FALSE)
	data["hoard_paid"] = staff ? SSrogue_hoard.total_paid : 0
	data["hoard_log"] = staff ? SSrogue_hoard.hoard_log : list()
	return data

/obj/structure/roguemachine/bathvend/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || locked)
		return
	var/mob/living/user = ui.user
	switch(action)
		if("change")
			return_change(user)
			return TRUE
		if("toggle_tariff")
			if(!rogue_bathhouse_staff(user, FALSE))
				return TRUE
			dodging_tax = !dodging_tax
			playsound(src, ROGUE_SOUND_GOLD_MISC, 100, FALSE, -1)
			if(dodging_tax)
				playsound(src, ROGUE_SOUND_SEAL, 100, FALSE, -1)
			return TRUE
		if("buy")
			var/datum/rogue_supply_pack/pack = GLOB.rogue_supply_packs[text2path(params["ref"])]
			if(sells(pack))
				buy_pack(pack, user)
			return TRUE

/// Ratwood "buy": the tariff is paid unless dodged, the wares are picked from the pack at the buyer's feet.
/obj/structure/roguemachine/bathvend/proc/buy_pack(datum/rogue_supply_pack/pack, mob/living/user)
	var/tariff = pack_tariff(pack)
	var/price = pack.cost + (dodging_tax ? 0 : tariff)
	if(budget < price)
		say("Not enough!")
		return FALSE
	budget -= price
	if(dodging_tax)
		tariff_dodged += tariff
	else
		SSrogue_treasury.collect_bathhouse_tariff(tariff, pack.cost, name)
		tariff_paid += tariff
	var/turf/spot = get_turf(user)
	for(var/i in 1 to length(pack.contains))
		var/ware_type = pick(pack.contains)
		new ware_type(spot)
	playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
	return TRUE
