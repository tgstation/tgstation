/obj/item/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard"
	base_icon_state = "aicard"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	sound_vary = TRUE
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	var/flush = FALSE
	var/mob/living/silicon/ai/AI

/obj/item/aicard/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI))
		return INITIALIZE_HINT_QDEL
	ADD_TRAIT(src, TRAIT_CASTABLE_LOC, INNATE_TRAIT)

/obj/item/aicard/Destroy(force)
	if(AI)
		AI.ghostize(can_reenter_corpse = FALSE)
		QDEL_NULL(AI)
	return ..()

/obj/item/aicard/aitater
	name = "intelliTater"
	desc = "A stylish upgrade (?) to the intelliCard."
	icon_state = "aitater"
	base_icon_state = "aitater"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/aicard/aispook
	name = "intelliLantern"
	desc = "A spoOoOoky upgrade to the intelliCard."
	icon_state = "aispook"
	base_icon_state = "aispook"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.5)

/obj/item/aicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to upload [user.p_them()]self into [src]! That's not going to work out well!"))
	return BRUTELOSS

/obj/item/aicard/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(AI)
		if(upload_ai(interacting_with, user))
			return ITEM_INTERACT_SUCCESS
	else
		if(capture_ai(interacting_with, user))
			return ITEM_INTERACT_SUCCESS
	return NONE

/// Tries to get an AI from the atom clicked
/obj/item/aicard/proc/capture_ai(atom/from_what, mob/living/user)
	from_what.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	if(isnull(AI))
		return FALSE
	log_silicon("[key_name(user)] carded [key_name(AI)]", list(src))
	update_appearance()
	AI.cancel_camera()
	RegisterSignal(AI, COMSIG_MOB_STATCHANGE, PROC_REF(on_ai_stat_change))
	RegisterSignal(AI, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_ai_icon_update))
	return TRUE

/// Tries to upload the AI we have captured to the atom clicked
/obj/item/aicard/proc/upload_ai(atom/to_what, mob/living/user)
	var/mob/living/silicon/ai/old_ai = AI
	to_what.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
	if(!isnull(AI))
		return FALSE
	log_combat(user, old_ai, "uploaded", src, "to [to_what].")
	update_appearance()
	old_ai.cancel_camera()
	UnregisterSignal(old_ai, COMSIG_MOB_STATCHANGE)
	UnregisterSignal(old_ai, COMSIG_ATOM_UPDATE_ICON)
	return TRUE

/obj/item/aicard/proc/on_ai_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat == DEAD || old_stat == DEAD)
		update_appearance()

/obj/item/aicard/proc/on_ai_icon_update(datum/source)
	SIGNAL_HANDLER
	update_appearance()

/obj/item/aicard/update_appearance(updates)
	. = ..()

	if(!AI)
		set_light(0)
		return

	set_light(0.5, 0.5, LIGHT_COLOR_FAINT_CYAN)

/obj/item/aicard/update_name(updates)
	. = ..()
	if(AI)
		name = "[initial(name)] - [AI.name]"
	else
		name = initial(name)

/obj/item/aicard/update_icon_state()
	icon_state = base_icon_state
	return ..()

//Support for different displays
/obj/item/aicard/update_overlays()
	. = ..()
	if(!AI)
		return

	var/target_skin = AI.display_icon_override || "ai"
	var/final_state
	var/state_to_find
	var/icon/source_icon = icon

	if(AI.stat == DEAD)
		state_to_find = "[target_skin]_dead"
	else
		state_to_find = target_skin

	if(state_to_find in icon_states(icon))
		final_state = state_to_find
		source_icon = icon

	else if(state_to_find in icon_states(AI.icon))
		final_state = state_to_find
		source_icon = AI.icon

	else
		source_icon = icon
		if(AI.stat == DEAD)
			final_state = "ai_dead"
		else
			final_state = "ai"

	. += mutable_appearance(source_icon, final_state)
	. += emissive_appearance(source_icon, final_state, src, alpha = src.alpha)

	if(AI.control_disabled)
		var/indicator_state = "[base_icon_state]-off"
		. += mutable_appearance(icon, indicator_state)
		. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)

	if(!AI.control_disabled)
		var/indicator_state = "[base_icon_state]-on"
		. += mutable_appearance(icon, indicator_state)
		. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)

/obj/item/aicard/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/aicard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Intellicard", name)
		ui.open()

/obj/item/aicard/ui_data()
	var/list/data = list()
	if(AI)
		data["name"] = AI.name
		data["laws"] = AI.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)
		data["health"] = (AI.health + 100) / 2
		data["wireless"] = !AI.control_disabled
		data["radio"] = AI.radio_enabled
		data["isDead"] = AI.stat == DEAD
		data["isBraindead"] = AI.client ? FALSE : TRUE
	data["wiping"] = flush
	return data

/obj/item/aicard/ui_act(action,params)
	. = ..()
	if(.)
		return
	switch(action)
		if("wipe")
			if(flush)
				flush = FALSE
			else
				var/confirm = tgui_alert(usr, "Are you sure you want to wipe this card's memory?", name, list("Yes", "No"))
				if(confirm == "Yes" && !..())
					flush = TRUE
					wipe_ai()
			. = TRUE
		if("wireless")
			AI.set_control_disabled(!AI.control_disabled)
			to_chat(AI, span_warning("[src]'s wireless port has been [AI.control_disabled ? "disabled" : "enabled"]!"))
			. = TRUE
		if("radio")
			AI.radio_enabled = !AI.radio_enabled
			to_chat(AI, span_warning("Your Subspace Transceiver has been [AI.radio_enabled ? "enabled" : "disabled"]!"))
			. = TRUE
	update_appearance()

/obj/item/aicard/proc/wipe_ai()
	set waitfor = FALSE
	if(AI && AI.loc == src)
		to_chat(AI, span_userdanger("YOUR SYSTEM FILES ARE BEING WIPED!"))
		while(AI.stat != DEAD && flush)
			AI.adjust_oxy_loss(5)
			AI.updatehealth()
			sleep(0.5 SECONDS)
		flush = FALSE

/obj/item/aicard/used_in_craft(atom/result, datum/crafting_recipe/current_recipe)
	. = ..()
	if(!AI || !istype(result, /obj/item/aicard))
		return
	var/obj/item/aicard/new_card = result
	AI.forceMove(new_card)
	new_card.AI = AI
	new_card.update_appearance()
	AI = null

// Special Cards

/obj/item/aicard/aitater/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/item/aicard/aitater/update_overlays()
	..()
	. = list()

	if(!AI)
		return

	var/face_state = "[base_icon_state][AI.stat == DEAD ? "-404" : "-full"]"
	. += mutable_appearance(icon, face_state)
	. += emissive_appearance(icon, face_state, src, alpha = src.alpha)

	var/indicator_state = "[base_icon_state][AI.control_disabled ? "-off" : "-on"]"
	. += mutable_appearance(icon, indicator_state)
	. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)


/obj/item/aicard/aispook/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/item/aicard/aispook/update_overlays()
	..()
	. = list()

	if(!AI)
		return

	var/face_state = "[base_icon_state][AI.stat == DEAD ? "-404" : "-full"]"
	. += mutable_appearance(icon, face_state)
	. += emissive_appearance(icon, face_state, src, alpha = src.alpha)

	var/indicator_state = "[base_icon_state][AI.control_disabled ? "-off" : "-on"]"
	. += mutable_appearance(icon, indicator_state)
	. += emissive_appearance(icon, indicator_state, src, alpha = src.alpha)
