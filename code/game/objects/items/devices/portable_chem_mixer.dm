///Base power efficiency when using the chem mixer
#define POWER_EFFICIECY (0.1)

/obj/item/storage/portable_chem_mixer
	name = "Portable Chemical Mixer"
	desc = "A portable device that dispenses and mixes chemicals. All necessary reagents need to be supplied with beakers. A label indicates that the 'CTRL'-button on the device may be used to open it for refills. This device can be worn as a belt. The letters 'S&T' are imprinted on the side."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "portablechemicalmixer"
	worn_icon_state = "portable_chem_mixer"
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_CREW * 14

	///Power Cell functionality so the portable mixer can dispense chems
	var/obj/item/stock_parts/cell/cell
	///Creating an empty slot for a beaker that can be added to dispense into
	var/obj/item/reagent_containers/beaker

	///The amount of reagent that is to be dispensed currently
	var/amount = 30
	///List in which all currently dispensable reagents go
	var/list/dispensable_reagents = list()

	/// The Portable Chem Mixer should be able to dispense all the basic chems from the power cell it has installed
	//dispensable_reagents is copypasted from chem dispenser. Please update accordingly.
	var/static/list/battery_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
	)

/obj/item/storage/portable_chem_mixer/Initialize(mapload)
	. = ..()
	battery_reagents = sort_list(battery_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	dispensable_reagents = sort_list(dispensable_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/condiment,
	))
	update_appearance(UPDATE_ICON)

/obj/item/storage/portable_chem_mixer/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/item/storage/portable_chem_mixer/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("Use a screwdriver to remove the cell.")
	else
		. += span_warning("It has no power cell!")

/obj/item/storage/portable_chem_mixer/get_cell()
	return cell

/obj/item/storage/portable_chem_mixer/screwdriver_act(mob/living/user, obj/item/tool)
	if(!cell)
		return FALSE

	cell.forceMove(get_turf(src))
	balloon_alert(user, "removed [cell]")
	cell = null
	tool.play_tool_sound(src, 50)
	return TRUE

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	if(severity > EXPLODE_LIGHT)
		return ..()

/obj/item/storage/portable_chem_mixer/attackby(obj/item/attacking_item, mob/user, params)
	if(!beaker && is_reagent_container(attacking_item) && attacking_item.is_open_container() && !atom_storage.locked)
		if(attacking_item.forceMove(src))
			beaker = attacking_item
			beaker.moveToNullspace()
			update_appearance(UPDATE_ICON)
			ui_interact(user)
			return TRUE //no afterattack
	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, span_warning("[src] already has a cell!"))
			return
		if(attacking_item.forceMove(src))
			cell = attacking_item
			cell.moveToNullspace()
			to_chat(user, span_notice("You install a cell in [src]."))
			update_appearance(UPDATE_ICON)
			return TRUE
	return ..()


/**
 * Updates the contents of the portable chemical mixer
 *
 * A list of dispensable reagents is created by iterating through each source beaker in the portable chemical beaker and reading its contents
 */
/obj/item/storage/portable_chem_mixer/proc/update_contents()
	dispensable_reagents.Cut()

	for (var/obj/item/reagent_containers/B in contents)
		var/key = B.reagents.get_master_reagent_id()
		if (!(key in dispensable_reagents))
			dispensable_reagents[key] = list()
			dispensable_reagents[key]["reagents"] = list()
		dispensable_reagents[key]["reagents"] += B.reagents

	return

/obj/item/storage/portable_chem_mixer/update_icon_state()
	if(beaker)
		icon_state = "[initial(icon_state)]_full"
		return ..()
	if(!atom_storage.locked)
		icon_state = initial(icon_state)
		return ..()
	icon_state = "[initial(icon_state)]_empty"
	return ..()

/obj/item/storage/portable_chem_mixer/AltClick(mob/living/user)
	if(!atom_storage.locked)
		return ..()
	if(!can_interact(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE))
		return
	replace_beaker(user)
	update_appearance()

/obj/item/storage/portable_chem_mixer/CtrlClick(mob/living/user)
	atom_storage.locked = !atom_storage.locked
	if (!atom_storage.locked)
		update_contents()
	if (atom_storage.locked)
		replace_beaker(user)
	update_appearance()
	playsound(src, 'sound/items/screwdriver2.ogg', 50)
	return

/**
 * Replaces the beaker of the portable chemical mixer with another beaker, or simply adds the new beaker if none is in currently
 *
 * Checks if a valid user and a valid new beaker exist and attempts to replace the current beaker in the portable chemical mixer with the one in hand. Simply places the new beaker in if no beaker is currently loaded
 * Arguments:
 * * mob/living/user - The user who is trying to exchange beakers
 * * obj/item/reagent_containers/new_beaker - The new beaker that the user wants to put into the device
 */
/obj/item/storage/portable_chem_mixer/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		user.put_in_hands(beaker)
		beaker = null
	if(new_beaker)
		new_beaker.forceMove(src)
		beaker = new_beaker
	return TRUE

/obj/item/storage/portable_chem_mixer/attack_hand(mob/user, list/modifiers)
	if(atom_storage?.locked && (loc == user))
		ui_interact(user)
	return ..()

/obj/item/storage/portable_chem_mixer/attack_self(mob/user)
	if(loc == user)
		if (atom_storage.locked)
			ui_interact(user)
			return
		else
			to_chat(user, span_notice("It looks like this device can be worn as a belt for increased accessibility. A label indicates that the 'CTRL'-button on the device may be used to close it after it has been filled with bottles and beakers of chemicals."))
			return
	return ..()

/obj/item/storage/portable_chem_mixer/MouseDrop(obj/over_object)
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(!M.incapacitated() && istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/storage/portable_chem_mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableChemMixer", name)

		var/is_hallucinating = FALSE
		if(isliving(user))
			var/mob/living/living_user = user
			is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)

		if(is_hallucinating)
			// to not ruin the immersion by constantly changing the fake chemicals
			ui.set_autoupdate(FALSE)

		ui.open()

/obj/item/storage/portable_chem_mixer/ui_static_data(mob/user)
	var/list/data = ..()
	data["battery_reagents"] = battery_reagents
	return data

/obj/item/storage/portable_chem_mixer/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = amount
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : 0
	data["beakerMaxVolume"] = beaker ? beaker.volume : 0
	data["beakerTransferAmounts"] = beaker ? list(1,5,10,30,50,100) : 0
	data["energy"] = cell ? (cell.charge * POWER_EFFICIECY) : 0
	data["maxEnergy"] = cell ? (cell.maxcharge * POWER_EFFICIECY) : 0

	var/chemicals[0]
	var/battery[0]
	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)

	for(var/ba in battery_reagents)
		var/datum/reagent/tempp = GLOB.chemical_reagents_list[ba]
		if(tempp)
			var/chemname = tempp.name
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "battery")]"
			battery.Add(list(list("title" = chemname, "id" = ckey(tempp.name), "pH" = tempp.ph, "pHCol" = convert_ph_to_readable_color(tempp.ph))))
	data["battery"] = battery

	for(var/re in dispensable_reagents)
		var/value = dispensable_reagents[re]
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			var/total_volume = 0
			var/total_ph = 0
			for (var/datum/reagents/rs in value["reagents"])
				total_volume += rs.total_volume
				total_ph = rs.ph
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name), "volume" = total_volume, "pH" = total_ph, "pHCol" = convert_ph_to_readable_color(temp.ph))))
	data["chemicals"] = chemicals

	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume, "pH" = R.ph))) // list in a list because Byond merges the first list...
		data["beakerCurrentpH"] = round(beaker.reagents.ph, 0.01)
	data["beakerContents"] = beakerContents

	return data

/obj/item/storage/portable_chem_mixer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("amount")
			var/target = text2num(params["target"])
			amount = target
			. = TRUE
		if("battery")
			if(QDELETED(cell))
				return
			var/reagent_name = params["reagent"]
			var/reagent = GLOB.name2reagent[reagent_name]
			if(beaker && battery_reagents.Find(reagent))
				var/datum/reagents/holder = beaker.reagents
				var/to_dispense = max(0, min(amount, holder.maximum_volume - holder.total_volume))
				if(!cell?.use(to_dispense / POWER_EFFICIECY))
					say("Not enough energy to complete operation!")
					return
				holder.add_reagent(reagent, to_dispense, reagtemp = DEFAULT_REAGENT_TEMPERATURE)
		if("storage")
			var/reagent_name = params["reagent"]
			var/datum/reagent/reagent = GLOB.name2reagent[reagent_name]
			var/entry = dispensable_reagents[reagent]
			if(beaker)
				var/datum/reagents/R = beaker.reagents
				var/actual = min(amount, 1000, R.maximum_volume - R.total_volume)
				// todo: add check if we have enough reagent left
				for (var/datum/reagents/source in entry["reagents"])
					var/to_transfer = min(source.total_volume, actual)
					source.trans_to(beaker, to_transfer)
					actual -= to_transfer
					if (actual <= 0)
						break
			. = TRUE
		if("remove")
			var/amount = text2num(params["amount"])
			beaker.reagents.remove_all(amount)
			. = TRUE
		if("eject")
			replace_beaker(usr)
			update_appearance()
			. = TRUE


#undef POWER_EFFICIECY
