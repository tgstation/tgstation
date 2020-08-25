/obj/item/storage/portable_chem_mixer
	name = "Portable Chemical Mixer"
	desc = "A portable device that dispenses and mixes chemicals. Requires a vortex anomaly core. All necessary reagents need to be supplied with beakers. A label indicates that a screwdriver is required to open it for refills. This device can be worn on a belt. The letters 'S&T' are imprinted on the side."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "portablechemicalmixer_open"
	worn_icon_state = "portable_chem_mixer"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	custom_price = 2000
	custom_premium_price = 2000

	var/obj/item/reagent_containers/beaker = null	///Creating an empty slot for a beaker that can be added to dispense into
	var/amount = 30	///The amount of reagent that is to be dispensed currently

	var/anomaly_core_present = FALSE	///TRUE if an anomaly core has been added

	var/list/dispensable_reagents = list()	///List in which all currently dispensable reagents go

/obj/item/storage/portable_chem_mixer/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 200
	STR.max_items = 50
	STR.insert_preposition = "in"
	STR.set_holdable(list(
		/obj/item/reagent_containers/glass/beaker,
	))

/obj/item/storage/portable_chem_mixer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/item/storage/portable_chem_mixer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly/signaler/anomaly/vortex) && !anomaly_core_present)
		anomaly_core_present = TRUE
		QDEL_NULL(I)
		to_chat(user, "<span class='notice'>You insert the vortex anomaly core. The device is now functional. A screwdriver is needed to open and close the device for refills.</span>")
		return
	if(!anomaly_core_present)
		to_chat(user, "<span class='warning'>A vortex anomaly core has to be inserted to activate this device.</span>")
		return
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if (I.tool_behaviour == TOOL_SCREWDRIVER)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, !locked)
		if (!locked)
			update_contents()
		if (locked)
			replace_beaker(user)
		update_icon()
		I.play_tool_sound(src, 50)
		return

	else if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container() && locked)
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		update_icon()
		updateUsrDialog()
		return

	return ..()

/**
  * Updates the contents of the portable chemical mixer
  *
  * A list of dispensable reagents is created by iterating through each source beaker in the portable chemical beaker and reading its contents
  */
/obj/item/storage/portable_chem_mixer/proc/update_contents()
	dispensable_reagents.Cut()

	for (var/obj/item/reagent_containers/glass/beaker/B in contents)
		var/key = B.reagents.get_master_reagent_id()
		if (!(key in dispensable_reagents))
			dispensable_reagents[key] = list()
			dispensable_reagents[key]["reagents"] = list()
		dispensable_reagents[key]["reagents"] += B.reagents

	return

/obj/item/storage/portable_chem_mixer/update_icon_state()
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if (!locked)
		icon_state = "portablechemicalmixer_open"
	else if (beaker)
		icon_state = "portablechemicalmixer_full"
	else
		icon_state = "portablechemicalmixer_empty"


/obj/item/storage/portable_chem_mixer/AltClick(mob/living/user)
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if (!locked)
		return ..()
	if(!can_interact(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)
	update_icon()

/**
  * Replaces the beaker of the portable chemical mixer with another beaker, or simply adds the new beaker if none is in currently
  *
  * Checks if a valid user and a valid new beaker exist and attempts to replace the current beaker in the portable chemical mixer with the one in hand. Simply places the new beaker in if no beaker is currently loaded
  *	Arguments:
  * * mob/living/user							-	The user who is trying to exchange beakers
  *	* obj/item/reagent_containers/new_beaker	-	The new beaker that the user wants to put into the device
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

/obj/item/storage/portable_chem_mixer/attack_hand(mob/user)
	if(!anomaly_core_present)
		to_chat(user, "<span class='warning'>A vortex anomaly core has to be inserted to activate this device.</span>")
	else if(loc == user)
		var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
		if (locked)
			ui_interact(user)
			return
	return ..()

/obj/item/storage/portable_chem_mixer/attack_self(mob/user)
	if(!anomaly_core_present)
		to_chat(user, "<span class='warning'>A vortex anomaly core has to be inserted to activate this device.</span>")
		return
	if(loc == user)
		var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
		if (locked)
			ui_interact(user)
			return
		else
			to_chat(user, "<span class='notice'>The portable chemical mixer is currently open and its contents can be accessed.</span>")
			return
	return

/obj/item/storage/portable_chem_mixer/MouseDrop(obj/over_object)
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(!M.incapacitated() && istype(over_object, /obj/screen/inventory/hand))
			var/obj/screen/inventory/hand/H = over_object
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
	data["beakerTransferAmounts"] = beaker ? beaker.possible_transfer_amounts : null
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
			for (var/datum/reagents/rs in value["reagents"])
				total_volume += rs.total_volume
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name), "volume" = total_volume )))
	data["chemicals"] = chemicals
	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	return data

/obj/item/storage/portable_chem_mixer/ui_act(action, params)
	if(..())
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
			update_icon()
			. = TRUE
