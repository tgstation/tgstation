/obj/item/mod/control/proc/choose_deploy(mob/user)
	if(!length(mod_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/piece as anything in mod_parts)
		display_names[piece.name] = REF(piece)
		var/image/piece_image = image(icon = piece.icon, icon_state = piece.icon_state)
		items += list(piece.name = piece_image)
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in mod_parts
	if(!istype(part) || user.incapacitated())
		return
	if(active || activating)
		balloon_alert(user, "deactivate the suit first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/parts_to_check = mod_parts - part
	if(part.loc == src)
		deploy(user, part)
		for(var/obj/item/piece as anything in parts_to_check)
			if(piece.loc != src)
				continue
			choose_deploy(user)
			break
	else
		conceal(user, part)
		for(var/obj/item/piece as anything in parts_to_check)
			if(piece.loc == src)
				continue
			choose_deploy(user)
			break

/obj/item/mod/control/proc/deploy(mob/user, part)
	var/obj/item/piece = part
	if(piece == gauntlets && wearer.gloves)
		gauntlets.overslot = wearer.gloves
		wearer.transferItemToLoc(gauntlets.overslot, gauntlets, TRUE)
	if(piece == boots && wearer.shoes)
		boots.overslot = wearer.shoes
		wearer.transferItemToLoc(boots.overslot, boots, TRUE)
	if(wearer.equip_to_slot_if_possible(piece,piece.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		ADD_TRAIT(piece, TRAIT_NODROP, MOD_TRAIT)
		if(!user)
			return
		wearer.visible_message(span_notice("[wearer]'s [piece] deploy[piece.p_s()] with a mechanical hiss."),
			span_notice("[piece] deploy[piece.p_s()] with a mechanical hiss."),
			span_hear("You hear a mechanical hiss."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else if(piece.loc != src)
		if(!user)
			return
		balloon_alert(user, "[piece] already deployed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	else
		if(!user)
			return
		balloon_alert(user, "bodypart clothed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/conceal(mob/user, part)
	var/obj/item/piece = part
	REMOVE_TRAIT(piece, TRAIT_NODROP, MOD_TRAIT)
	wearer.transferItemToLoc(piece, src, TRUE)
	if(piece == gauntlets)
		gauntlets.show_overslot()
	if(piece == boots)
		boots.show_overslot()
	if(!user)
		return
	wearer.visible_message(span_notice("[wearer]'s [piece] retract[piece.p_s()] back into [src] with a mechanical hiss."),
		span_notice("[piece] retract[piece.p_s()] back into [src] with a mechanical hiss."),
		span_hear("You hear a mechanical hiss."))
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/toggle_activate(mob/user, force_deactivate = FALSE)
	if(!wearer)
		if(!force_deactivate)
			balloon_alert(user, "put suit on back!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!force_deactivate && (SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/part as anything in mod_parts)
		if(!force_deactivate && part.loc == src)
			balloon_alert(user, "deploy all parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
	if(locked && !active && !allowed(user) && !force_deactivate)
		balloon_alert(user, "access insufficient!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!cell?.charge && !force_deactivate)
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
	activating = TRUE
	to_chat(wearer, span_notice("MODsuit [active ? "shutting down" : "starting up"]."))
	if(do_after(wearer,2 SECONDS,wearer,IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED))
		to_chat(wearer, span_notice("[boots] [active ? "relax their grip on your legs" : "seal around your feet"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(boots, !active)
	if(do_after(wearer,2 SECONDS,wearer,IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED))
		to_chat(wearer, span_notice("[gauntlets] [active ? "become loose around your fingers" : "tighten around your fingers and wrists"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(gauntlets, !active)
	if(do_after(wearer,2 SECONDS,wearer,IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED))
		to_chat(wearer, span_notice("[chestplate] [active ? "releases your chest" : "cinches tightly against your chest"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(chestplate, !active)
	if(do_after(wearer,2 SECONDS,wearer,IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED))
		to_chat(wearer, span_notice("[helmet] hisses [active ? "open" : "closed"]."))
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(helmet, !active)
	if(do_after(wearer,2 SECONDS,wearer,IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED))
		to_chat(wearer, span_notice("Systems [active ? "shut down. Parts unsealed. Goodbye" : "started up. Parts sealed. Welcome"], [wearer]."))
		if(ai)
			to_chat(ai, span_notice("<b>SYSTEMS [active ? "DEACTIVATED. GOODBYE" : "ACTIVATED. WELCOME"]: \"[ai]\"</b>"))
		finish_activation(!active)
		if(active)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
			SEND_SOUND(wearer, sound('sound/mecha/nominal.ogg',volume=50))
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
	activating = FALSE
	return TRUE

/obj/item/mod/control/proc/seal_part(obj/item/clothing/part, seal)
	if(seal)
		part.clothing_flags |= part.visor_flags
		part.flags_inv |= part.visor_flags_inv
		part.flags_cover |= part.visor_flags_cover
	else
		part.flags_cover &= ~part.visor_flags_cover
		part.flags_inv &= ~part.visor_flags_inv
		part.clothing_flags &= ~part.visor_flags
	if(part == boots)
		boots.icon_state = "[skin]-boots[seal ? "-sealed" : ""]"
		wearer.update_inv_shoes()
	if(part == gauntlets)
		gauntlets.icon_state = "[skin]-gauntlets[seal ? "-sealed" : ""]"
		wearer.update_inv_gloves()
	if(part == chestplate)
		chestplate.icon_state = "[skin]-chestplate[seal ? "-sealed" : ""]"
		wearer.update_inv_wear_suit()
		wearer.update_inv_w_uniform()
	if(part == helmet)
		helmet.icon_state = "[skin]-helmet[seal ? "-sealed" : ""]"
		if(seal)
			helmet.alternate_worn_layer = null
		else
			helmet.alternate_worn_layer = helmet.alternate_layer
		wearer.update_inv_head()
		wearer.update_inv_wear_mask()
		wearer.update_hair()

/obj/item/mod/control/proc/finish_activation(on)
	icon_state = "[skin]-control[on ? "-sealed" : ""]"
	slowdown = on ? slowdown_active : slowdown_inactive
	if(on)
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_equip()
		START_PROCESSING(SSobj, src)
	else
		for(var/obj/item/mod/module/module as anything in modules)
			module.on_unequip()
			if(module.active)
				module.on_deactivation()
		STOP_PROCESSING(SSobj, src)
	wearer.update_equipment_speed_mods()
	active = on
	wearer.update_inv_back()

/obj/item/mod/control/proc/quick_activation() //quick activation, for stuff like outfits with the suit on
	for(var/obj/item/part in mod_parts)
		deploy(null, part)
		seal_part(part, TRUE)
	finish_activation(TRUE)
