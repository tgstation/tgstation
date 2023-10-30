/obj/item/storage/portable_chem_mixer
	name = "Portable Chemical Mixer"
	desc = "A portable device that dispenses and mixes chemicals. All necessary reagents need to be supplied with beakers. A label indicates that the 'CTRL'-button on the device may be used to open it for refills. This device can be worn as a belt. The letters 'S&T' are imprinted on the side."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "portablechemicalmixer_open"
	worn_icon_state = "portable_chem_mixer"
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_CREW * 14

	///Creating an empty slot for a beaker that can be added to dispense into
	var/obj/item/reagent_containers/beaker = null
	///The amount of reagent that is to be dispensed currently
	var/amount = 30
	///List in which all currently dispensable reagents go
	var/list/dispensable_reagents = list()
	///List of possible transfer ammounts
	var/static/list/transfer_amounts = list(1, 5, 10, 30, 50, 100)

/obj/item/storage/portable_chem_mixer/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/condiment,
	))

/obj/item/storage/portable_chem_mixer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	return severity > EXPLODE_LIGHT ? ..() : FALSE

/obj/item/storage/portable_chem_mixer/attackby(obj/item/I, mob/user, params)
	if (is_reagent_container(I) && !(I.item_flags & ABSTRACT) && I.is_open_container() && atom_storage.locked)
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return TRUE

		replace_beaker(user, B)
		update_appearance()
		ui_interact(user)

		return TRUE
	return ..()

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
	if(!can_interact(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	update_appearance()

/obj/item/storage/portable_chem_mixer/CtrlClick(mob/living/user)
	if(atom_storage.locked)
		atom_storage.locked = STORAGE_NOT_LOCKED
	else
		atom_storage.locked = STORAGE_FULLY_LOCKED

	//reload reagents
	if (!atom_storage.locked)
		dispensable_reagents.Cut()
		for (var/obj/item/reagent_containers/B in contents)
			var/key = B.reagents.get_master_reagent_id()
			if (!(key in dispensable_reagents))
				dispensable_reagents[key] = list()
				dispensable_reagents[key]["reagents"] = list()
			dispensable_reagents[key]["reagents"] += B.reagents

	//replace beaker
	if (atom_storage.locked)
		atom_storage.hide_contents(usr)
		replace_beaker(user)

	update_appearance()
	playsound(src, 'sound/items/screwdriver2.ogg', 50)

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
		ui.open()

	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)
	ui.set_autoupdate(!is_hallucinating) // to not ruin the immersion by constantly changing the fake chemicals

/obj/item/storage/portable_chem_mixer/ui_data(mob/user)
	. = list()
	.["amount"] = amount

	var/list/chemicals = list()
	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)

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
			chemicals += list(list("title" = chemname, "id" = temp.name, "volume" = total_volume, "pH" = total_ph))
	.["chemicals"] = chemicals

	.["isBeakerLoaded"] = beaker ? 1 : 0
	.["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : 0
	.["beakerMaxVolume"] = beaker ? beaker.volume : 0
	.["beakerTransferAmounts"] = beaker ? transfer_amounts : 0
	.["beakerCurrentpH"] = beaker ? round(beaker.reagents.ph, 0.01) : 0
	var/list/beakerContents = list()
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "id" = R.name, "volume" = R.volume, "pH" = R.ph)) // list in a list because Byond merges the first list...
	.["beakerContents"] = beakerContents

/obj/item/storage/portable_chem_mixer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("amount")
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				return TRUE

		if("dispense")
			var/reagent_name = params["reagent"]
			var/datum/reagent/reagent = GLOB.name2reagent[reagent_name]
			var/entry = dispensable_reagents[reagent]
			if(beaker && beaker.loc == src)
				var/datum/reagents/R = beaker.reagents
				var/actual = min(amount, 1000, R.maximum_volume - R.total_volume)
				// todo: add check if we have enough reagent left
				for (var/datum/reagents/source in entry["reagents"])
					var/to_transfer = min(source.total_volume, actual)
					source.trans_to(beaker, to_transfer, transferred_by = ui.user)
					actual -= to_transfer
					if (actual <= 0)
						break
			return TRUE

		if("remove")
			var/amount = text2num(params["amount"])
			beaker.reagents.remove_all(amount)
			return TRUE

		if("eject")
			replace_beaker(ui.user)
			update_appearance()
			return TRUE
