/obj/item/brain_processor/organic
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon_state = "mmi_off"
	base_icon_state = "mmi"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)

	VAR_FINAL/obj/item/organ/brain/brain = null //The actual brain

/obj/item/brain_processor/organic/Initialize(mapload, obj/item/organ/brain/initial_brain = null)
	. = ..()
	if(initial_brain)
		initial_brain.brainmob ||= new(initial_brain)
		insert_brain(initial_brain)

/obj/item/brain_processor/organic/Destroy()
	QDEL_NULL(brain)
	return ..()

/obj/item/brain_processor/organic/update_icon_state()
	if(!brain)
		icon_state = "[base_icon_state]_off"
	else
		icon_state = "[base_icon_state]_brain[istype(brain, /obj/item/organ/brain/alien) ? "_alien" : null]"
	return ..()

/obj/item/brain_processor/organic/update_overlays()
	. = ..()
	if(brain) // doing it like this will make it extremely apparent if something goes wrong
		if(brainmob?.stat <= DEAD)
			. += "mmi_alive"
		else
			. += "mmi_dead"

/obj/item/brain_processor/organic/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/organ/brain)) //Time to stick a brain in it --NEO
		return NONE

	var/obj/item/organ/brain/newbrain = tool
	if(brain)
		balloon_alert(user, "[p_Theyre()] already full!")
		return ITEM_INTERACT_BLOCKING

	if(!newbrain.brainmob)
		var/install = tgui_alert(user, "[newbrain] is inactive, slot it in anyway?", "Installing Brain", list("Yes", "No"))
		if(install != "Yes")
			return ITEM_INTERACT_BLOCKING
		// user.visible_message(span_notice("[user] sticks [newbrain] into [src]."), span_notice("[src]'s indicator light turns red as you insert [newbrain]. Its brainwave activity alarm buzzes."))

	if(!user.transferItemToLoc(newbrain, src))
		return ITEM_INTERACT_BLOCKING

	insert_brain(newbrain)
	user.visible_message(
		span_notice("[user] sticks \a [newbrain] into [src]..."),
		span_notice("You stick [newbrain] into [src]..."),
		span_hear("You hear a wet squelch..."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE
		)

	if(suicided())
		to_chat(user, span_warning("[src]'s indicator light turns red and its brainwave activity alarm beeps harshly."))
		playsound(src, 'sound/machines/beep/triple_beep.ogg', 5, TRUE)
	else if(newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
		to_chat(user, span_warning("[src]'s indicator light turns yellow and its brain integrity alarm beeps softly."))
		playsound(src, 'sound/machines/synth/synth_no.ogg', 5, TRUE)
	else
		to_chat(user, span_notice("[src]'s indicator light turns green!"))
		playsound(src, 'sound/machines/beep/beep.ogg', 5, TRUE)

	SSblackbox.record_feedback("amount", "mmis_filled", 1)
	user.log_message("has put the brain of [key_name(brainmob)] into an MMI", LOG_GAME)
	return ITEM_INTERACT_SUCCESS

/obj/item/brain_processor/organic/attack_self(mob/user)
	if(!brain)
		..()
	else
		var/obj/item/organ/brain/dumped_brain = remove_brain()
		var/caught_brain = user.put_in_hands(dumped_brain)
		var/fate_of_brain = caught_brain \
			? "[span_italics("gently")] scooping [dumped_brain] into your hand" \
			: "spilling [dumped_brain] onto the floor"

		to_chat(user, span_notice("You unlock and upend [src], [fate_of_brain]."))
		if(caught_brain)
			balloon_alert(user, "scooped up brain")
		else
			user.balloon_alert_to_viewers("dropped a brain!", "dropped the brain!")

		if(dumped_brain.brainmob)
			user.log_message("has ejected the brain of [key_name(brainmob)] from \a [src]", LOG_GAME)

/obj/item/brain_processor/organic/proc/insert_brain(obj/item/organ/brain/new_brain)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!istype(new_brain))
		CRASH("tried to insert invalid value into [type]")

	if(brain)
		remove_brain() // also clears the brainmob

	brain = new_brain
	if(new_brain.loc != src)
		new_brain.forceMove(src)
	new_brain.organ_flags |= ORGAN_FROZEN
	braintype = istype(brain, /obj/item/organ/brain/alien) ? "Xenoborg" : "Cyborg"

	set_brainmob(brain.brainmob)
	brain.brainmob = null
	if(brainmob)
		brainmob.forceMove(src)
		brainmob.reset_perspective()
		var/fubar_brain = brain.suicided || HAS_TRAIT(brainmob, TRAIT_SUICIDED)
		if(!fubar_brain && !(brain.organ_flags & ORGAN_FAILING))
			brainmob.set_stat(STABLE)
		if(brainmob.key && !brain.decoy_override)
			brainmob.notify_revival("Your brain was inserted into an MMI!", source = src)

	update_appearance()

/// Removes the currently inserted brain from the MMI.
/obj/item/brain_processor/organic/proc/remove_brain(atom/destination = drop_location()) as /obj/item/organ/brain
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!brain)
		return

	if(brainmob)
		var/mob/living/brain/old_brainmob = brainmob
		set_brainmob(null)
		brain.brainmob = old_brainmob
		old_brainmob.forceMove(brain) //Throw mob into brain.
		old_brainmob.set_stat(DEAD)
		old_brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision

	brain.forceMove(destination)
	brain.organ_flags &= ~ORGAN_FROZEN
	. = brain
	brain = null

	update_appearance()

/obj/item/brain_processor/organic/transfer_identity(mob/living/target) //Same deal as the regular brain proc. Used for human-->robot people.
	var/obj/item/organ/brain/new_brain = astype(target, /mob/living/carbon)?.get_organ_by_type(/obj/item/organ/brain)
	if(!new_brain)
		new_brain = new(src)
		new_brain.transfer_identity(target)
	else
		new_brain.Remove(target, special = TRUE)
		new_brain.forceMove(src)

	insert_brain(new_brain)

/obj/item/brain_processor/organic/atom_deconstruct(disassembled = TRUE)
	remove_brain()

/obj/item/brain_processor/organic/examine(mob/user)
	. = ..()
	if(brain)
		if((!brainmob || !brainmob.mind) && !brain.decoy_override) // covers suicide and ghosting
			. += span_danger("[src]'s indicator light glows a grim red.")
		else if((brain.organ_flags & ORGAN_FAILING) || brainmob?.stat >= DEAD)
			. += span_warning("[src]'s indicator light glows yellow.")
		else if(!brainmob.client && !brain.decoy_override)
			. += span_notice("[src]'s indicator light slowly pulses green...")
		else
			. += span_nicegreen("[src]'s indicator light glows green!")

/obj/item/brain_processor/organic/brain_check(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(brain?.decoy_override)
		if(user)
			to_chat(user, span_warning("This [name] does not seem to fit!"))
		return FALSE
	if(brain?.organ_flags & ORGAN_FAILING)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is damaged!"))
		return FALSE
	return TRUE

/obj/item/brain_processor/organic/suicided()
	return brain.suicided || HAS_TRAIT(brainmob, TRAIT_SUICIDED)

/obj/item/brain_processor/organic/set_name(new_name)
	. = ..()
	brain.name = "[new_name]'s brain"

/obj/item/brain_processor/organic/set_suicide(suicided)
	. = ..()
	brain.suicided = suicided

/obj/item/brain_processor/organic/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. \
		It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."

/obj/item/brain_processor/organic/syndie/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.set_on(FALSE)

/obj/item/brain_processor/organic/syndie/examine(mob/user)
	. = ..()
	. += span_notice("If used to create a cyborg, it will be unlinked from the station's AI. \
		The lawset cannot be modified until it is synced to a module rack or an AI.")
	. += span_notice("If used to create an AI, it will not automatically sync to a module rack. \
		The lawset cannot be modified until it is synced to a module rack.")
