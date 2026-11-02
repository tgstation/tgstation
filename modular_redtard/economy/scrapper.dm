/**
 * Scrappers (Ratwood code/modules/roguetown/roguemachine/scrapper.dm): the smithy's and the tailor's buyers of raw stock. The
 * guild funds the coffer with coins and lists which materials it takes, at what price a piece and how many it holds; anyone
 * strikes it with an item and is paid in coin for what the item is or smelts down to (or, for clothing, what it unpicks into).
 * Once a minute it calls out a ware it is buying. The smith's scrapper takes ingots, the tailor's rag-picker fibres, cloth,
 * silk, hides and furs. Ratwood's clothing salvage counts (salvage_amount) are not ported yet, so clothing is not taken until
 * the porter brings them.
 */
/obj/structure/roguemachine/scrapper
	/// Lockids of the keys that run it (Ratwood keycontrol).
	var/list/keycontrol = list("crafterguild", "craftermaster")
	/// Material path -> mammons a piece, pieces it holds at most (0: no cap), pieces held now, called out, bought at all.
	var/list/material_prices = list()
	var/list/material_caps = list()
	var/list/material_held = list()
	var/list/material_advertise = list()
	var/list/material_enabled = list()
	/// Materials bought by default, and called out (Ratwood defaults_on).
	var/list/defaults_on = list()
	var/next_bark = 0

/obj/item/clothing
	/// How many pieces of its salvage the clothing unpicks into (Ratwood salvage_amount); the porter does not carry it yet.
	var/rogue_salvage_amount = 0

/obj/structure/roguemachine/scrapper/Initialize(mapload)
	. = ..()
	for(var/path in material_prices)
		material_held[path] = 0
		material_enabled[path] = (path in defaults_on)
		material_advertise[path] = (path in defaults_on)
	budget = rogue_value("machines_scrapper_seed")
	next_bark = world.time + rogue_value("machines_scrapper_bark_interval")
	START_PROCESSING(SSobj, src)

/obj/structure/roguemachine/scrapper/Destroy()
	STOP_PROCESSING(SSobj, src)
	var/turf/spot = drop_location()
	for(var/obj/item/held in src)
		held.forceMove(spot)
	return ..()

/obj/structure/roguemachine/scrapper/examine(mob/user)
	. = ..()
	. += span_info("The proprietor lists per-material prices, capacities, and which wares to call out. Coins fed into the machine fund the coffer; when it runs dry, the scrapper turns away offers.")
	. += span_info("Strike with an item to offer it. The scrapper weighs by what it would smelt down to.")

/obj/structure/roguemachine/scrapper/proc/material_name(path)
	var/atom/material = path
	return capitalize(initial(material.name))

/// The guild runs it: a key of the guild on the user (Ratwood is_keyholder()).
/obj/structure/roguemachine/scrapper/proc/is_keyholder(mob/user)
	if(!ishuman(user))
		return FALSE
	for(var/lockid in keycontrol)
		if(rockhill_find_key(user, lockid))
			return TRUE
	return FALSE

/// The material an item is bought as: itself, what it smelts into, or what its cloth unpicks into (Ratwood identify_material()).
/obj/structure/roguemachine/scrapper/proc/identify_material(obj/item/thing)
	if((thing.type in material_prices) && material_enabled[thing.type])
		return thing.type
	if(thing.smeltresult && (thing.smeltresult in material_prices) && material_enabled[thing.smeltresult])
		return thing.smeltresult
	var/obj/item/clothing/garment = thing
	if(istype(garment) && garment.sewrepair && garment.rogue_sleeve_scrap && (garment.rogue_sleeve_scrap in material_prices) && material_enabled[garment.rogue_sleeve_scrap])
		return garment.rogue_sleeve_scrap
	return null

/obj/structure/roguemachine/scrapper/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		var/fits = FALSE
		for(var/lockid in keycontrol)
			if(rockhill_key_fits(tool, lockid))
				fits = TRUE
				break
		to_chat(user, fits ? span_notice("I rattle the lock to confirm my standing with the machine.") : span_warning("Wrong key."))
		SStgui.update_uis(src)
		return fits ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/roguecoin))
		if(!is_keyholder(user))
			to_chat(user, span_warning("Only the proprietor may fund the machine."))
			return ITEM_INTERACT_BLOCKING
		if(take_coins(tool, user))
			playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
		return ITEM_INTERACT_SUCCESS
	if(!ishuman(user))
		return NONE
	recycle(tool, user)
	return ITEM_INTERACT_SUCCESS

/// Weighs an offered item and pays for it from the coffer (Ratwood try_recycle()).
/obj/structure/roguemachine/scrapper/proc/recycle(obj/item/thing, mob/living/user)
	var/path = identify_material(thing)
	if(!path)
		to_chat(user, span_warning("[src] sees no worth in [thing]."))
		return FALSE
	var/units = 1
	var/obj/item/clothing/garment = thing
	if(path != thing.type && path != thing.smeltresult && istype(garment))
		units = garment.rogue_salvage_amount
		if(units <= 0)
			to_chat(user, span_warning("[src] sees no worth in [thing]."))
			return FALSE
	var/unit_price = material_prices[path]
	if(unit_price <= 0)
		to_chat(user, span_warning("[src] is not taking [material_name(path)] today."))
		return FALSE
	var/total = unit_price * units
	var/cap = material_caps[path]
	var/held = material_held[path]
	if(cap > 0 && held + units > cap)
		to_chat(user, span_warning("[src]'s [material_name(path)] hopper has no room for that."))
		playsound(src, ROGUE_SOUND_MACHINE_NO, 100, FALSE, -1)
		return FALSE
	if(budget < total)
		to_chat(user, span_warning("[src]'s coffer hasn't the coin for that."))
		playsound(src, ROGUE_SOUND_MACHINE_NO, 100, FALSE, -1)
		return FALSE
	if(!user.transferItemToLoc(thing, src))
		return FALSE
	material_held[path] = held + units
	budget -= total
	rogue_coins_out(total, user, null, src)
	var/cap_text = cap > 0 ? "[max(0, cap - material_held[path])] / [cap] left" : "no cap"
	to_chat(user, span_notice("[material_name(path)] weighed and paid: [total]m[units > 1 ? " ([units] units)" : ""]. [cap_text]."))
	SStgui.update_uis(src)
	return TRUE

/// Once a minute it calls out a ware it is buying and has room and coin for (Ratwood process()).
/obj/structure/roguemachine/scrapper/process(seconds_per_tick)
	if(world.time < next_bark)
		return
	next_bark = world.time + rogue_value("machines_scrapper_bark_interval")
	var/list/candidates = list()
	for(var/path in material_prices)
		var/price = material_prices[path]
		var/cap = material_caps[path]
		if(!material_enabled[path] || !material_advertise[path] || price <= 0 || budget < price || (cap > 0 && material_held[path] >= cap))
			continue
		candidates += path
	if(!length(candidates))
		return
	var/path = pick(candidates)
	var/cap = material_caps[path]
	say("Rags and scrap! [material_name(path)] paid at [material_prices[path]]m a piece! [cap > 0 ? "[cap - material_held[path]] left" : "no cap"]!")

/obj/structure/roguemachine/scrapper/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	return ..()

/obj/structure/roguemachine/scrapper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		ui = new(user, src, "RogueScrapper", name)
		ui.open()

/// Items held that came in as a material (Ratwood items_count_for()).
/obj/structure/roguemachine/scrapper/proc/items_held_for(path)
	. = 0
	for(var/obj/item/held in src)
		if(identify_held(held) == path)
			.++

/// The material a held item was bought as, whatever is enabled now.
/obj/structure/roguemachine/scrapper/proc/identify_held(obj/item/held)
	if(held.type in material_prices)
		return held.type
	if(held.smeltresult in material_prices)
		return held.smeltresult
	var/obj/item/clothing/garment = held
	if(istype(garment) && (garment.rogue_sleeve_scrap in material_prices))
		return garment.rogue_sleeve_scrap
	return null

/obj/structure/roguemachine/scrapper/ui_data(mob/user)
	var/list/data = list()
	data["budget"] = budget
	data["is_keyholder"] = is_keyholder(user)
	var/list/rows = list()
	var/total_items = 0
	for(var/path in material_prices)
		var/cap = material_caps[path]
		var/items = items_held_for(path)
		total_items += items
		rows += list(list(
			"path" = "[path]",
			"name" = material_name(path),
			"price" = material_prices[path],
			"cap" = cap,
			"held" = material_held[path],
			"items" = items,
			"left" = cap > 0 ? max(0, cap - material_held[path]) : -1,
			"advertise" = material_advertise[path] ? TRUE : FALSE,
			"enabled" = material_enabled[path] ? TRUE : FALSE,
		))
	data["materials"] = rows
	data["total_items"] = total_items
	return data

/obj/structure/roguemachine/scrapper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !is_keyholder(ui.user))
		return
	var/path = text2path(params["path"])
	if(path && !(path in material_prices))
		return TRUE
	var/number = text2num(params["value"])
	switch(action)
		if("set_price")
			if(path && isnum(number))
				material_prices[path] = clamp(round(number), 0, ROGUE_TRANSFER_MAX)
		if("set_cap")
			if(path && isnum(number))
				material_caps[path] = clamp(round(number), 0, ROGUE_TRANSFER_MAX)
		if("toggle_advertise")
			if(path)
				material_advertise[path] = !material_advertise[path]
		if("toggle_enable")
			if(path)
				material_enabled[path] = !material_enabled[path]
		if("dump_held")
			if(path)
				var/turf/spot = drop_location()
				for(var/obj/item/held in src)
					if(identify_held(held) == path)
						held.forceMove(spot)
				material_held[path] = 0
		if("dump_all")
			var/turf/spot = drop_location()
			for(var/obj/item/held in src)
				held.forceMove(spot)
			for(var/held_path in material_held)
				material_held[held_path] = 0
		if("withdraw")
			if(budget > 0)
				var/amount = budget
				budget = 0
				rogue_coins_out(amount, ui.user, null, src)
				to_chat(ui.user, span_notice("I withdraw [amount]m from the coffer."))
	return TRUE

/obj/structure/roguemachine/scrapper/smith
	material_prices = list(
		/obj/item/ingot/iron = 8,
		/obj/item/ingot/copper = 4,
		/obj/item/ingot/bronze = 10,
		/obj/item/ingot/steel = 14,
		/obj/item/ingot/silver = 60,
		/obj/item/ingot/gold = 50,
		/obj/item/ingot/blacksteel = 80,
	)
	material_caps = list(
		/obj/item/ingot/iron = 10,
		/obj/item/ingot/copper = 5,
		/obj/item/ingot/bronze = 5,
		/obj/item/ingot/steel = 10,
		/obj/item/ingot/silver = 4,
		/obj/item/ingot/gold = 4,
		/obj/item/ingot/blacksteel = 3,
	)
	defaults_on = list(/obj/item/ingot/iron, /obj/item/ingot/steel)

/obj/structure/roguemachine/scrapper/tailor
	material_prices = list(
		/obj/item/natural/fibers = 2,
		/obj/item/natural/cloth = 3,
		/obj/item/natural/silk = 4,
		/obj/item/natural/hide = 8,
		/obj/item/natural/hide/cured = 3,
		/obj/item/natural/fur = 10,
	)
	material_caps = list(
		/obj/item/natural/fibers = 10,
		/obj/item/natural/cloth = 10,
		/obj/item/natural/silk = 10,
		/obj/item/natural/hide = 8,
		/obj/item/natural/hide/cured = 12,
		/obj/item/natural/fur = 3,
	)
	defaults_on = list(/obj/item/natural/hide, /obj/item/natural/fur)
