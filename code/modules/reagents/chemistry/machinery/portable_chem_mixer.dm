/obj/item/storage/portable_chem_mixer
	name = "Portable Chemical Mixer"
	desc = "A portable device that dispenses and mixes chemicals using the beakers inserted inside."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "portablechemicalmixer_open"
	worn_icon_state = "portable_chem_mixer"
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_CREW * 14
	interaction_flags_click = FORBID_TELEKINESIS_REACH
	interaction_flags_mouse_drop = FORBID_TELEKINESIS_REACH
	storage_type = /datum/storage/portable_chem_mixer

	///Creating an empty slot for a beaker that can be added to dispense into
	var/obj/item/reagent_containers/beaker
	///The amount of reagent that is to be dispensed currently
	var/amount = 30
	///List in which all currently dispensable reagents go
	var/list/dispensable_reagents = list()

/obj/item/storage/portable_chem_mixer/Initialize(mapload)
	. = ..()

	register_context()

/obj/item/storage/portable_chem_mixer/Destroy()
	dispensable_reagents.Cut()
	QDEL_NULL(beaker)
	return ..()

/obj/item/storage/portable_chem_mixer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "[atom_storage.locked ? "Un" : ""]Lock storage"
	if(atom_storage.locked && !QDELETED(beaker))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Eject beaker"

	if(!isnull(held_item))
		if (!atom_storage.locked  || \
			(held_item.item_flags & ABSTRACT) || \
			(held_item.flags_1 & HOLOGRAM_1) || \
			!is_reagent_container(held_item) || \
			!held_item.is_open_container() \
		)
			return CONTEXTUAL_SCREENTIP_SET
		context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/portable_chem_mixer/examine(mob/user)
	. = ..()
	if(!atom_storage.locked)
		. += span_notice("Use [EXAMINE_HINT("Ctrl Click")] to lock in order to use its interface.")
	else
		. += span_notice("Its storage is locked, use [EXAMINE_HINT("Ctrl Click")] to unlock it.")
	if(QDELETED(beaker))
		. += span_notice("A beaker can be inserted to dispense reagents after it is locked.")
	else
		. += span_notice("A beaker of [beaker.reagents.maximum_volume]u capacity is inserted.")
		. += span_notice("It can be ejected with [EXAMINE_HINT("Alt Click")].")

/obj/item/storage/portable_chem_mixer/update_icon_state()
	if(!atom_storage.locked)
		icon_state = "portablechemicalmixer_open"
		return ..()
	if(!QDELETED(beaker))
		icon_state = "portablechemicalmixer_full"
		return ..()
	icon_state = "portablechemicalmixer_empty"
	return ..()

/obj/item/storage/portable_chem_mixer/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!atom_storage.locked)
		update_contents()

/// Reload dispensable reagents from new contents
/obj/item/storage/portable_chem_mixer/proc/update_contents()
	PRIVATE_PROC(TRUE)

	dispensable_reagents.Cut()
	for (var/obj/item/reagent_containers/container in contents)
		var/datum/reagent/key = container.reagents.get_master_reagent()
		if(isnull(key)) //no reagent inside container
			continue

		var/key_type = key.type
		if (!(key_type in dispensable_reagents))
			dispensable_reagents[key_type] = list()
			dispensable_reagents[key_type]["reagents"] = list()
		dispensable_reagents[key_type]["reagents"] += container.reagents

/obj/item/storage/portable_chem_mixer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		beaker = null
	else
		update_contents()

/obj/item/storage/portable_chem_mixer/ex_act(severity, target)
	return severity > EXPLODE_LIGHT ? ..() : FALSE

/obj/item/storage/portable_chem_mixer/storage_insert_on_interacted_with(datum/storage, obj/item/weapon, mob/living/user)
	if (!atom_storage.locked || \
		(weapon.item_flags & ABSTRACT) || \
		(weapon.flags_1 & HOLOGRAM_1) || \
		!is_reagent_container(weapon) || \
		!weapon.is_open_container() \
	)
		return TRUE //continue with regular insertion

	replace_beaker(user, weapon)
	update_appearance()
	return FALSE //block insertion cause we handled it ourselves

/**
 * Replaces the beaker of the portable chemical mixer with another beaker, or simply adds the new beaker if none is in currently
 *
 * Checks if a valid user and a valid new beaker exist and attempts to replace the current beaker in the portable chemical mixer with the one in hand. Simply places the new beaker in if no beaker is currently loaded
 * Arguments:
 * * mob/living/user - The user who is trying to exchange beakers
 * * obj/item/reagent_containers/new_beaker - The new beaker that the user wants to put into the device
 */
/obj/item/storage/portable_chem_mixer/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	PRIVATE_PROC(TRUE)

	if(!QDELETED(beaker))
		user.put_in_hands(beaker)

	if(!QDELETED(new_beaker))
		if(!user.transferItemToLoc(new_beaker, src))
			return
		beaker = new_beaker

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

	var/is_hallucinating = FALSE
	if(isliving(user))
		var/mob/living/living_user = user
		is_hallucinating = !!living_user.has_status_effect(/datum/status_effect/hallucination)

	.["chemicals"] = list()
	for(var/datum/reagent/reagent_type as anything in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[reagent_type]
		if(temp)
			var/chemname = temp.name
			var/total_volume = 0
			var/total_ph = 0
			for (var/datum/reagents/rs as anything in dispensable_reagents[reagent_type]["reagents"])
				total_volume += rs.total_volume
				total_ph = rs.ph
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			.["chemicals"] += list(list("title" = chemname, "id" = temp.name, "volume" = total_volume, "pH" = total_ph))

	var/list/beaker_data = null
	if(!QDELETED(beaker))
		beaker_data = list()
		beaker_data["maxVolume"] = beaker.volume
		beaker_data["transferAmounts"] = beaker.possible_transfer_amounts
		beaker_data["pH"] = round(beaker.reagents.ph, 0.01)
		beaker_data["currentVolume"] = round(beaker.reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
		var/list/beakerContents = list()
		if(length(beaker.reagents.reagent_list))
			for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
				beakerContents += list(list("name" = reagent.name, "volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING))) // list in a list because Byond merges the first list...
		beaker_data["contents"] = beakerContents
	.["beaker"] = beaker_data

/obj/item/storage/portable_chem_mixer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("amount")
			var/target = params["target"]
			if(isnull(target))
				return

			target = text2num(target)
			if(isnull(target))
				return

			amount = target
			return TRUE

		if("dispense")
			var/datum/reagent/reagent = GLOB.name2reagent[params["reagent"]]
			if(isnull(reagent))
				return

			if(!QDELETED(beaker))
				var/datum/reagents/container = beaker.reagents
				var/actual = min(amount, container.maximum_volume - container.total_volume)
				for(var/datum/reagents/source as anything in dispensable_reagents[reagent]["reagents"])
					actual -= source.trans_to(beaker, min(source.total_volume, actual), transferred_by = ui.user)
					if(actual <= 0)
						break
				return TRUE

		if("remove")
			var/target = params["amount"]
			if(isnull(target))
				return

			target = text2num(target)
			if(isnull(target))
				return

			beaker.reagents.remove_all(target)
			return TRUE

		if("eject")
			replace_beaker(ui.user)
			update_appearance()
			return TRUE

/obj/item/storage/portable_chem_mixer/mouse_drop_dragged(atom/over_object)
	if(ismob(loc))
		var/mob/M = loc
		if(istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/storage/portable_chem_mixer/click_alt(mob/living/user)
	if(!atom_storage.locked)
		balloon_alert(user, "lock first to use alt eject!")
		return CLICK_ACTION_BLOCKING

	replace_beaker(user)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/storage/portable_chem_mixer/item_ctrl_click(mob/user)
	if(atom_storage.locked == STORAGE_FULLY_LOCKED)
		atom_storage.locked = STORAGE_NOT_LOCKED
		replace_beaker(user)
		SStgui.close_uis(src)
	else
		atom_storage.locked = STORAGE_FULLY_LOCKED
		atom_storage.hide_contents(user)

	update_appearance()
	return CLICK_ACTION_SUCCESS
