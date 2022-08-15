/obj/item/storage/portable_chem_mixer
	name = "Portable Chemical Mixer"
	desc = "A portable device that dispenses and mixes chemicals. All necessary reagents need to be supplied with beakers. A label indicates that the 'CTRL'-button on the device may be used to open it for refills. This device can be worn as a belt. The letters 'S&T' are imprinted on the side."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "portablechemicalmixer_open"
	worn_icon_state = "portable_chem_mixer"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_CREW * 14

	var/obj/item/reagent_containers/beaker = null ///Creating an empty slot for a beaker that can be added to dispense into
	var/amount = 30 ///The amount of reagent that is to be dispensed currently

	var/list/dispensable_reagents = list() ///List in which all currently dispensable reagents go

	///If the UI has the pH meter shown
	var/show_ph = TRUE

/obj/item/storage/portable_chem_mixer/Initialize()
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/food/drinks/waterbottle,
		/obj/item/reagent_containers/food/condiment,
	))

/obj/item/storage/portable_chem_mixer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	if(severity > EXPLODE_LIGHT)
		return ..()

/obj/item/storage/portable_chem_mixer/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container() && atom_storage.locked)
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		update_appearance()
		ui_interact(user)
		return
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
	if(!atom_storage.locked)
		icon_state = "portablechemicalmixer_open"
		return ..()
	if(beaker)
		icon_state = "portablechemicalmixer_full"
		return ..()
	icon_state = "portablechemicalmixer_empty"
	return ..()


/obj/item/storage/portable_chem_mixer/AltClick(mob/living/user)
	if(!atom_storage.locked)
		return ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
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
		beaker = new_beaker
	return TRUE

/obj/item/storage/portable_chem_mixer/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		return ..()
	else
		if (!atom_storage.locked)
			return ..()
	if(atom_storage?.locked)
		ui_interact(user)
		return

/obj/item/storage/portable_chem_mixer/attack_self(mob/user)
	if(loc == user)
		if (atom_storage.locked)
			ui_interact(user)
			return
		else
			to_chat(user, span_notice("It looks like this device can be worn as a belt for increased accessibility. A label indicates that the 'CTRL'-button on the device may be used to close it after it has been filled with bottles and beakers of chemicals."))
			return
	return

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
		if(user.hallucinating())
			// to not ruin the immersion by constantly changing the fake chemicals
			ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/storage/portable_chem_mixer/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = amount
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["beakerTransferAmounts"] = beaker ? list(1,5,10,30,50,100) : null
	data["showpH"] = show_ph
	var/chemicals[0]
	var/is_hallucinating = user.hallucinating()
	if(user.hallucinating())
		is_hallucinating = TRUE
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
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name), "volume" = total_volume, "pH" = total_ph)))
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
		if("dispense")
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
