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
	var/obj/item/part = locate(part_reference) in parts
	if(!istype(part) || user.incapacitated())
		return
	if(active || activating)
		balloon_alert(user, "deactivate the suit first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/parts_to_check = parts - part
	if(part.loc == src)
		deploy(user, part)
		SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc != src)
				continue
			choose_deploy(user)
			break
	else
		retract(user, part)
		SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc == src)
				continue
			choose_deploy(user)
			break

/// Quickly deploys all parts (or retracts if all are on the wearer)
/obj/item/mod/control/proc/quick_deploy(mob/user)
	if(active || activating)
		balloon_alert(user, "deactivate the suit first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	var/deploy = TRUE
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		deploy = FALSE
		break
	for(var/obj/item/part as anything in get_parts())
		if(deploy && part.loc == src)
			deploy(null, part)
		else if(!deploy && part.loc != src)
			retract(null, part)
	wearer.visible_message(span_notice("[wearer]'s [src] [deploy ? "deploys" : "retracts"] its parts with a mechanical hiss."),
		span_notice("[src] [deploy ? "deploys" : "retracts"] its parts with a mechanical hiss."),
		span_hear("You hear a mechanical hiss."))
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(deploy)
		SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)
	else
		SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
	return TRUE

/// Deploys a part of the suit onto the user.
/obj/item/mod/control/proc/deploy(mob/user, obj/item/part)
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(!wearer)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE // pAI is trying to deploy it from your hands
	if(part.loc != src)
		if(!user)
			return FALSE
		balloon_alert(user, "[part.name] already deployed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(part_datum.can_overslot)
		var/obj/item/overslot = wearer.get_item_by_slot(part.slot_flags)
		if(overslot)
			part_datum.overslotting = overslot
			wearer.transferItemToLoc(overslot, part, force = TRUE)
			RegisterSignal(part, COMSIG_ATOM_EXITED, PROC_REF(on_overslot_exit))
	if(wearer.equip_to_slot_if_possible(part, part.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		ADD_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
		if(!user)
			return TRUE
		wearer.visible_message(span_notice("[wearer]'s [part.name] deploy[part.p_s()] with a mechanical hiss."),
			span_notice("[part] deploy[part.p_s()] with a mechanical hiss."),
			span_hear("You hear a mechanical hiss."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		SEND_SIGNAL(src, COMSIG_MOD_PART_DEPLOYED, user, part)
		return TRUE
	else
		if(!user)
			return FALSE
		balloon_alert(user, "bodypart clothed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/// Retract a part of the suit from the user.
/obj/item/mod/control/proc/retract(mob/user, obj/item/part)
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(part.loc == src)
		if(!user)
			return FALSE
		balloon_alert(user, "[part.name] already retracted!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	REMOVE_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
	wearer.transferItemToLoc(part, src, force = TRUE)
	if(part_datum.overslotting)
		UnregisterSignal(part, COMSIG_ATOM_EXITED)
		var/obj/item/overslot = part_datum.overslotting
		if(!QDELING(wearer) && !wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
			wearer.dropItemToGround(overslot, force = TRUE, silent = TRUE)
		part_datum.overslotting = null
	SEND_SIGNAL(src, COMSIG_MOD_PART_RETRACTED, user, part)
	if(!user)
		return
	wearer.visible_message(span_notice("[wearer]'s [part.name] retract[part.p_s()] back into [src] with a mechanical hiss."),
		span_notice("[part] retract[part.p_s()] back into [src] with a mechanical hiss."),
		span_hear("You hear a mechanical hiss."))
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/// Starts the activation sequence, where parts of the suit activate one by one until the whole suit is on.
/obj/item/mod/control/proc/toggle_activate(mob/user, force_deactivate = FALSE)
	if(!wearer)
		if(!force_deactivate)
			balloon_alert(user, "equip suit first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!force_deactivate && (SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/part as anything in get_parts())
		if(!force_deactivate && part.loc == src)
			balloon_alert(user, "deploy all parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
	if(locked && !active && !allowed(user) && !force_deactivate)
		balloon_alert(user, "access insufficient!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!get_charge() && !force_deactivate)
		balloon_alert(user, "suit not powered!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(open && !force_deactivate)
		balloon_alert(user, "close the suit panel!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(activating)
		if(!force_deactivate)
			balloon_alert(user, "suit already [active ? "shutting down" : "starting up"]!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/mod/module/module as anything in modules)
		if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
			continue
		module.deactivate(display_message = FALSE)
	activating = TRUE
	mod_link.end_call()
	to_chat(wearer, span_notice("MODsuit [active ? "shutting down" : "starting up"]."))
	for(var/obj/item/part as anything in get_parts())
		var/datum/mod_part/part_datum = get_part_datum(part)
		if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(get_wearer)), hidden = TRUE))
			to_chat(wearer, span_notice("[part] [active ? part_datum.unsealed_message : part_datum.sealed_message]."))
			playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			seal_part(part, is_sealed = !active)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(get_wearer)), hidden = TRUE))
		to_chat(wearer, span_notice("Systems [active ? "shut down. Parts unsealed. Goodbye" : "started up. Parts sealed. Welcome"], [wearer]."))
		if(ai_assistant)
			to_chat(ai_assistant, span_notice("<b>SYSTEMS [active ? "DEACTIVATED. GOODBYE" : "ACTIVATED. WELCOME"]: \"[ai_assistant]\"</b>"))
		finish_activation(is_on = !active)
		if(active)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
			if(!malfunctioning)
				wearer.playsound_local(get_turf(src), 'sound/mecha/nominal.ogg', 50)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
	activating = FALSE
	SEND_SIGNAL(src, COMSIG_MOD_TOGGLED, user)
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
	wearer.update_clothing(part.slot_flags)
	wearer.update_obscured_slots(part.visor_flags_inv)
	if((part.clothing_flags & (MASKINTERNALS|HEADINTERNALS)) && wearer.invalid_internals())
		wearer.cutoff_internals()

/// Finishes the suit's activation
/obj/item/mod/control/proc/finish_activation(is_on)
	var/datum/mod_part/part_datum = get_part_datum(src)
	part_datum.sealed = is_on
	active = is_on
	if(active)
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_suit_activation()
	else
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_suit_deactivation()
	update_speed()
	update_appearance(UPDATE_ICON_STATE)
	update_charge_alert()
	wearer.update_clothing(slot_flags)

/// Quickly deploys all the suit parts and if successful, seals them and turns on the suit. Intended mostly for outfits.
/obj/item/mod/control/proc/quick_activation()
	var/seal = TRUE
	for(var/obj/item/part as anything in get_parts())
		if(!deploy(null, part))
			seal = FALSE
	if(!seal)
		return
	for(var/obj/item/part as anything in get_parts())
		seal_part(part, is_sealed = TRUE)
	finish_activation(is_on = TRUE)

#undef MOD_ACTIVATION_STEP_FLAGS
