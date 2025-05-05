#define MOD_ACTIVATION_STEP_FLAGS IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED|IGNORE_SLOWDOWNS

/// Creates a radial menu from which the user chooses parts of the suit to deploy/retract. Repeats until all parts are extended or retracted.
/obj/item/mod/control/proc/choose_deploy(mob/user)
	if(!length(mod_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	var/list/parts = get_parts()
	for(var/obj/item/part as anything in parts)
		display_names[part.name] = REF(part)
		var/image/part_image = image(icon = part.icon, icon_state = part.icon_state)
		if(part.loc != src)
			part_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_active")
		items += list(part.name = part_image)
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in get_parts()
	if(!istype(part) || user.incapacitated)
		return
	if(activating)
		balloon_alert(user, "currently [active ? "unsealing" : "sealing"]!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/parts_to_check = parts - part
	if(part.loc == src)
		if(!deploy(user, part))
			return
		SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc != src)
				continue
			choose_deploy(user)
			break
	else
		if(!retract(user, part))
			return
		SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc == src)
				continue
			choose_deploy(user)
			break

/// Quickly deploys all parts (or retracts if all are on the wearer)
/obj/item/mod/control/proc/quick_deploy(mob/user)
	if(activating)
		balloon_alert(user, "currently [active ? "unsealing" : "sealing"]!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	var/deploy = FALSE
	for(var/obj/item/part as anything in get_parts())
		if(part.loc != src)
			continue
		deploy = TRUE
		break
	wearer.visible_message(span_notice("[wearer]'s [src] [deploy ? "deploys" : "retracts"] its parts with a mechanical hiss."),
		span_notice("[src] [deploy ? "deploys" : "retracts"] its parts with a mechanical hiss."),
		span_hear("You hear a mechanical hiss."))
	playsound(src, 'sound/vehicles/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	for(var/obj/item/part as anything in get_parts())
		if(deploy && part.loc == src)
			if(!deploy(null, part))
				continue
		else if(!deploy && part.loc != src)
			retract(null, part)
	if(deploy)
		SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)
	else
		SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
	return TRUE

/// Deploys a part of the suit onto the user.
/obj/item/mod/control/proc/deploy(mob/user, obj/item/part, instant = FALSE)
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(!wearer)
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE // pAI is trying to deploy it from your hands
	if(part.loc != src)
		if(!user)
			return FALSE
		balloon_alert(user, "already deployed!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(part_datum.can_overslot)
		var/obj/item/overslot = wearer.get_item_by_slot(part.slot_flags)
		if(overslot && istype(overslot, /obj/item/clothing))
			var/obj/item/clothing/clothing = overslot
			if(clothing.clothing_flags & CLOTHING_MOD_OVERSLOTTING)
				part_datum.overslotting = overslot
				wearer.transferItemToLoc(overslot, part, force = TRUE)
				RegisterSignal(part, COMSIG_ATOM_EXITED, PROC_REF(on_overslot_exit))
	if(wearer.equip_to_slot_if_possible(part, part.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		ADD_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
		wearer.update_clothing(slot_flags|part.slot_flags)
		SEND_SIGNAL(src, COMSIG_MOD_PART_DEPLOYED, user, part_datum)
		if(user)
			wearer.visible_message(span_notice("[wearer]'s [part.name] deploy[part.p_s()] with a mechanical hiss."),
				span_notice("[part] deploy[part.p_s()] with a mechanical hiss."),
				span_hear("You hear a mechanical hiss."))
			playsound(src, 'sound/vehicles/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(!active || part_datum.sealed)
			return TRUE
		if(instant)
			seal_part(part, is_sealed = TRUE)
			return TRUE
		else if(delayed_seal_part(part))
			return TRUE
		balloon_alert(user, "can't seal, retracting!")
		retract(user, part, instant = TRUE)
	else
		if(part_datum.overslotting)
			var/obj/item/overslot = part_datum.overslotting
			if(!wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
				wearer.dropItemToGround(overslot, force = TRUE, silent = TRUE)
		if(!user)
			return FALSE
		balloon_alert(user, "bodypart clothed!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/// Retract a part of the suit from the user.
/obj/item/mod/control/proc/retract(mob/user, obj/item/part, instant = FALSE)
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(part.loc == src)
		if(!user)
			return FALSE
		balloon_alert(user, "already retracted!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOD_PART_RETRACTING, user, part_datum) & MOD_CANCEL_RETRACTION)
		return FALSE
	var/unsealing = FALSE
	if(active && part_datum.sealed)
		unsealing = TRUE
		if(instant)
			seal_part(part, is_sealed = FALSE)
		else if(!delayed_seal_part(part))
			balloon_alert(user, "can't unseal!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
	REMOVE_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
	wearer.transferItemToLoc(part, src, force = TRUE)
	if(part_datum.overslotting)
		var/obj/item/overslot = part_datum.overslotting
		if(!QDELING(wearer) && !wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
			wearer.dropItemToGround(overslot, force = TRUE, silent = TRUE)
	wearer.update_clothing(slot_flags|part.slot_flags)
	if(!user)
		return TRUE
	wearer.visible_message(span_notice("[wearer]'s [part.name] retract[part.p_s()] back into [src] with a mechanical hiss."),
		span_notice("[part] retract[part.p_s()] back into [src] with a mechanical hiss."),
		span_hear("You hear a mechanical hiss."))
	if (!unsealing)
		playsound(src, 'sound/vehicles/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/// Starts the activation sequence, where parts of the suit activate one by one until the whole suit is on.
/obj/item/mod/control/proc/toggle_activate(mob/user, force_deactivate = FALSE)
	if(!wearer)
		if(!force_deactivate)
			balloon_alert(user, "not equipped!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!force_deactivate && (SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE))
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(locked && !active && !allowed(user) && !force_deactivate)
		balloon_alert(user, "access insufficient!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!get_charge() && !force_deactivate)
		balloon_alert(user, "no power source!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(open && !force_deactivate)
		balloon_alert(user, "panel open!")
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(activating)
		if(!force_deactivate)
			balloon_alert(user, "already [active ? "shutting down" : "starting up"]!")
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/mod/module/module as anything in modules)
		if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
			continue
		module.deactivate(display_message = FALSE)
	activating = TRUE
	mod_link.end_call()
	var/original_active_status = active
	to_chat(wearer, span_notice("MODsuit [active ? "shutting down" : "starting up"]."))
	//deploy the control unit
	if(original_active_status)
		if(delayed_activation())
			playsound(src, 'sound/machines/synth/synth_no.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
			to_chat(wearer, span_notice("Control unit offline. Module capability removed."))
		else
			activating = FALSE
			return

	var/list/sealed_parts = list()

	for(var/obj/item/part as anything in get_parts()) //seals/unseals all deployed parts
		if(part.loc == src)
			continue
		if(!delayed_seal_part(part)) //shit something broke, revert it all
			activating = FALSE
			for(var/obj/item/sealed_part as anything in sealed_parts)
				seal_part(sealed_part, is_sealed = !get_part_datum(sealed_part).sealed)
			if(original_active_status)
				control_activation(is_on = TRUE)
			to_chat(wearer, span_notice("Critical error in sealing systems. Reverting process."))
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
		sealed_parts += part

	if(!original_active_status)
		if(delayed_activation())
			playsound(src, 'sound/machines/synth/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
			if(!malfunctioning)
				wearer.playsound_local(get_turf(src), 'sound/vehicles/mecha/nominal.ogg', 50)
		else
			activating = FALSE
			for(var/obj/item/sealed_part as anything in sealed_parts)
				seal_part(sealed_part, is_sealed = !get_part_datum(sealed_part).sealed)
			to_chat(wearer, span_notice("Critical error in sealing systems. Reverting process."))
			playsound(src, 'sound/machines/scanner/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return

	to_chat(wearer, span_notice("Systems [active ? "started up. Parts sealed. Welcome" : "shut down. Parts unsealed. Goodbye"], [wearer]."))
	if(ai_assistant)
		to_chat(ai_assistant, span_notice("<b>SYSTEMS [active ? "ACTIVATED. WELCOME" : "DEACTIVATED. GOODBYE"]: \"[ai_assistant]\"</b>"))
	activating = FALSE
	SEND_SIGNAL(src, COMSIG_MOD_TOGGLED, user)
	return TRUE

/obj/item/mod/control/proc/delayed_seal_part(obj/item/clothing/part)
	. = FALSE
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(get_wearer)), hidden = TRUE))
		to_chat(wearer, span_notice("[part] [!part_datum.sealed ? part_datum.sealed_message : part_datum.unsealed_message]."))
		playsound(src, 'sound/vehicles/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(part, is_sealed = !part_datum.sealed)
		return TRUE

/obj/item/mod/control/proc/delayed_activation()
	. = FALSE
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(get_wearer)), hidden = TRUE))
		control_activation(is_on = !active)
		return TRUE

///Seals or unseals the given part.
/obj/item/mod/control/proc/seal_part(obj/item/clothing/part, is_sealed)
	var/datum/mod_part/part_datum = get_part_datum(part)
	part_datum.sealed = is_sealed
	if(part_datum.sealed)
		part.icon_state = "[skin]-[part.base_icon_state]-sealed"
		part.clothing_flags |= part.visor_flags
		part.flags_inv |= part.visor_flags_inv
		part.flags_cover |= part.visor_flags_cover
		part.heat_protection = initial(part.heat_protection)
		part.cold_protection = initial(part.cold_protection)
		part.alternate_worn_layer = part_datum.sealed_layer
	else
		part.icon_state = "[skin]-[part.base_icon_state]"
		part.flags_cover &= ~part.visor_flags_cover
		part.flags_inv &= ~part.visor_flags_inv
		part.clothing_flags &= ~part.visor_flags
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.alternate_worn_layer = part_datum.unsealed_layer
	update_speed()
	wearer.update_clothing(part.slot_flags | slot_flags)
	wearer.update_obscured_slots(part.visor_flags_inv)
	if((part.clothing_flags & (MASKINTERNALS|HEADINTERNALS)) && wearer.invalid_internals())
		wearer.cutoff_internals()
	SEND_SIGNAL(src, COMSIG_MOD_PART_SEALED, part_datum)
	if(is_sealed)
		if (!active)
			return
		for(var/obj/item/mod/module/module as anything in modules)
			if(module.part_activated || !module.has_required_parts(mod_parts, need_active = TRUE))
				continue
			module.on_part_activation()
			module.part_activated = TRUE
	else
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.part_activated || module.has_required_parts(mod_parts, need_active = TRUE))
				continue
			module.on_part_deactivation()
			module.part_activated = FALSE
			if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
				continue
			module.deactivate(display_message = FALSE)

/// Finishes the suit's activation
/obj/item/mod/control/proc/control_activation(is_on)
	var/datum/mod_part/part_datum = get_part_datum(src)
	part_datum.sealed = is_on
	active = is_on
	if(active)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.part_activated && module.has_required_parts(mod_parts, need_active = TRUE))
				module.on_part_activation()
				module.part_activated = TRUE
	else
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.part_activated)
				continue
			module.on_part_deactivation()
			module.part_activated = FALSE
	update_charge_alert()
	update_appearance(UPDATE_ICON_STATE)
	wearer.update_clothing()

/// Quickly deploys all the suit parts and if successful, seals them and turns on the suit. Intended mostly for outfits.
/obj/item/mod/control/proc/quick_activation()
	control_activation(is_on = TRUE)
	for(var/obj/item/part as anything in get_parts())
		deploy(null, part, instant = TRUE)

#undef MOD_ACTIVATION_STEP_FLAGS
