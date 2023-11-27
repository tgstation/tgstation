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
	register_context()

/obj/item/storage/portable_chem_mixer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/item/storage/portable_chem_mixer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "[atom_storage.locked ? "Un" : ""]Lock storage"
	if(atom_storage.locked && !QDELETED(beaker))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Eject beaker"

	if(!isnull(held_item))
		if (!atom_storage.locked  || \
			(held_item.item_flags & ABSTRACT) || \
			!is_reagent_container(held_item) || \
			!held_item.is_open_container() \
		)
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/portable_chem_mixer/examine(mob/user)
	. = ..()
	if(!atom_storage.locked)
		. += span_notice("Use [EXAMINE_HINT("ctrl click")] to lock in order to use its interface.")
	else
		. += span_notice("Its storage is locked, use [EXAMINE_HINT("ctrl click")] to unlock it.")
	if(QDELETED(beaker))
		. += span_notice("A beaker can be inserted to dispense reagents after it is locked.")
	else
		. += span_notice("A beaker of [beaker.reagents.maximum_volume] units capacity is inserted.")
		. += span_notice("It can be ejected with [EXAMINE_HINT("alt click")].")

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	return severity > EXPLODE_LIGHT ? ..() : FALSE

/obj/item/storage/portable_chem_mixer/attackby(obj/item/weapon, mob/user, params)
	if (!atom_storage.locked  || \
		(weapon.item_flags & ABSTRACT) || \
		!is_reagent_container(weapon) || \
		!weapon.is_open_container() \
	)
		return ..()

	replace_beaker(user, weapon)
	update_appearance()
	return TRUE

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
		balloon_alert(user, "lock first to use alt eject!")
		return ..()
	if(!can_interact(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	replace_beaker(user)
	update_appearance()

/obj/item/storage/portable_chem_mixer/CtrlClick(mob/living/user)
	if(atom_storage.locked == STORAGE_FULLY_LOCKED)
		atom_storage.locked = STORAGE_NOT_LOCKED
		replace_beaker(user)
		SStgui.close_all_uis()
	else
		atom_storage.locked = STORAGE_FULLY_LOCKED
		atom_storage.hide_contents(usr)

	update_appearance()

/obj/item/storage/portable_chem_mixer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
	else
		update_contents()

/// Reload dispensable reagents from new contents
/obj/item/storage/portable_chem_mixer/proc/update_contents()
	dispensable_reagents.Cut()
	for (var/obj/item/reagent_containers/container in contents)
		var/key = container.reagents.get_master_reagent_id()
		if (!(key in dispensable_reagents))
			dispensable_reagents[key] = list()
			dispensable_reagents[key]["reagents"] = list()
		dispensable_reagents[key]["reagents"] += container.reagents

/obj/item/storage/portable_chem_mixer/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!atom_storage.locked)
		update_contents()

/**
 * Replaces the beaker of the portable chemical mixer with another beaker, or simply adds the new beaker if none is in currently
 *
 * Checks if a valid user and a valid new beaker exist and attempts to replace the current beaker in the portable chemical mixer with the one in hand. Simply places the new beaker in if no beaker is currently loaded
 * Arguments:
 * * mob/living/user - The user who is trying to exchange beakers
 * * obj/item/reagent_containers/new_beaker - The new beaker that the user wants to put into the device
 */
/obj/item/storage/portable_chem_mixer/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		user.put_in_hands(beaker)
	if(new_beaker)
		if(!user.transferItemToLoc(new_beaker, src))
			return
		beaker = new_beaker

/obj/item/storage/portable_chem_mixer/MouseDrop(obj/over_object)
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(!M.incapacitated() && istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/storage/portable_chem_mixer/ui_interact(mob/user, datum/tgui/ui)
	if(loc != user)
		balloon_alert(user, "hold it in your hand!")
		return
	if(!atom_storage.locked)
		balloon_alert(user, "lock it first!")
		return

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

	var/list/beaker_data = null
	if(!QDELETED(beaker))
		beaker_data = list()
		beaker_data["maxVolume"] = beaker.volume
		beaker_data["transferAmounts"] = beaker.possible_transfer_amounts
		beaker_data["pH"] = round(beaker.reagents.ph, 0.01)
		beaker_data["currentVolume"] = round(beaker.reagents.total_volume, 0.01)
		var/list/beakerContents = list()
		if(length(beaker?.reagents.reagent_list))
			for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
				beakerContents += list(list("name" = reagent.name, "volume" = round(reagent.volume, 0.01))) // list in a list because Byond merges the first list...
		beaker_data["contents"] = beakerContents
	.["beaker"] = beaker_data

/obj/item/storage/portable_chem_mixer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("amount")
			amount = text2num(params["target"])
			return TRUE

		if("dispense")
			var/datum/reagent/reagent = GLOB.name2reagent[params["reagent"]]
			if(isnull(reagent))
				return

			if(!QDELETED(beaker))
				var/datum/reagents/container = beaker.reagents
				var/actual = min(amount, 1000, container.maximum_volume - container.total_volume)
				for (var/datum/reagents/source in dispensable_reagents[reagent]["reagents"])
					var/to_transfer = min(source.total_volume, actual)
					source.trans_to(beaker, to_transfer, transferred_by = ui.user)
					actual -= to_transfer
					if (actual <= 0)
						break
			return TRUE

		if("remove")
			beaker.reagents.remove_all(text2num(params["amount"]))
			return TRUE

		if("eject")
			replace_beaker(ui.user)
			update_appearance()
			return TRUE
