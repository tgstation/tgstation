/obj/item/ai_module/law/syndicate // This one doesn't inherit from ion boards because it doesn't call ..() in transmitInstructions. ~Miauw
	name = "Hacked AI Module"
	desc = "An AI Module for hacking additional laws to an AI."
	laws = list("")

/obj/item/ai_module/law/syndicate/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Enter a new law for the AI", "Freeform Law Entry", laws[1], max_length = CONFIG_GET(number/max_law_len), multiline = TRUE)
	if(!targName || !user.is_holding(src))
		return
	if(is_ic_filtered(targName)) // not even the syndicate can uwu
		to_chat(user, span_warning("Error: Law contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your law contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[targName]\"")
	laws[1] = targName

/obj/item/ai_module/law/syndicate/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	combined_lawset.add_hacked_law(laws[1])

/// Makes the AI Malf, as well as give it syndicate laws.
/obj/item/malf_board
	name = "Infected AI Module"
	desc = "A virus-infected AI Module."

	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "std_mod"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'

	obj_flags = CONDUCTS_ELECTRICITY
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.5)

	///Is this upload board unused?
	var/functional = TRUE

/obj/item/malf_board/examine(mob/user)
	. = ..()
	if(IS_TRAITOR(user) && isliving(user) && functional)
		. += span_alert("You can use this on an AI core to infect it with a virus, causing it to malfunction.")
		. += span_alert("It can alternatively be used on a core module rack to infect the first AI linked to it, if any.")

/obj/item/malf_board/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/blocking = ismachinery(interacting_with) || issilicon(interacting_with)
	if(!IS_TRAITOR(user))
		if(blocking)
			to_chat(user, span_warning("You have no clue how to use this thing."))
			return ITEM_INTERACT_BLOCKING
		return NONE
	if(!functional)
		if(blocking)
			to_chat(user, span_warning("It's broken and non-functional, what do you want from it?"))
			return ITEM_INTERACT_BLOCKING
		return NONE

	var/mob/living/silicon/ai/target_ai = interacting_with
	if(istype(interacting_with, /obj/machinery/ai_law_rack/core))
		var/obj/machinery/ai_law_rack/rack = interacting_with
		// find the first non-malf ai linked, but also allow a malf ai to be selected if it's the only one
		for(var/mob/living/silicon/ai/linked_ai in assoc_to_values(rack.linked_mobs))
			if(!target_ai?.mind?.has_antag_datum(/datum/antagonist/malf_ai))
				break
			target_ai = linked_ai
			continue

	if(!isAI(target_ai))
		to_chat(user, span_warning("You can only use this on an AI or a core module rack connected to an AI."))
		return ITEM_INTERACT_BLOCKING
	if(target_ai.mind?.has_antag_datum(/datum/antagonist/malf_ai))
		to_chat(user, span_warning("An unknown error has occured. Upload cancelled."))
		return ITEM_INTERACT_BLOCKING

	var/datum/antagonist/malf_ai/infected/malf_datum = new (give_objectives = TRUE, new_boss = user.mind)
	target_ai.mind.add_antag_datum(malf_datum)
	target_ai.malf_picker.processing_time += 50
	to_chat(target_ai, span_notice("The virus has enhanced your system, overclocking your CPU 50-fold."))
	to_chat(user, span_notice("You upload the virus to [target_ai] successfully."))

	functional = FALSE
	update_appearance()
	return ITEM_INTERACT_BLOCKING

/obj/item/malf_board/update_name(updates)
	. = ..()
	if(!functional)
		name = "Broken AI Module"

/obj/item/malf_board/update_desc(updates)
	. = ..()
	if(!functional)
		desc = "A law upload module, it is broken and non-functional."

/obj/item/malf_board/update_overlays()
	. = ..()
	if(!functional)
		. += "damaged"
