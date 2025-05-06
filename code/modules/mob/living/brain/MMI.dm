/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "mmi_off"
	base_icon_state = "mmi"
	w_class = WEIGHT_CLASS_NORMAL
	var/braintype = "Cyborg"
	var/obj/item/radio/radio = null //Let's give it a radio.
	var/mob/living/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/vehicle/sealed/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE
	var/overrides_aicore_laws = FALSE // Whether the laws on the MMI, if any, override possible pre-existing laws loaded on the AI core.
	/// Whether the brainmob can move. Doesnt usually matter but SPHERICAL POSIBRAINSSS
	var/immobilize = TRUE

/obj/item/mmi/Initialize(mapload)
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.set_broadcasting(FALSE) //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	laws.set_laws_config()

/obj/item/mmi/Destroy()
	set_mecha(null)
	QDEL_NULL(brainmob)
	QDEL_NULL(brain)
	QDEL_NULL(radio)
	QDEL_NULL(laws)
	return ..()

/obj/item/mmi/update_icon_state()
	if(!brain)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]_brain[istype(brain, /obj/item/organ/brain/alien) ? "_alien" : null]"
	return ..()

/obj/item/mmi/update_overlays()
	. = ..()
	. += add_mmi_overlay()

/obj/item/mmi/proc/add_mmi_overlay()
	if(brainmob && brainmob.stat != DEAD)
		. += "mmi_alive"
		return
	if(brain)
		. += "mmi_dead"

/obj/item/mmi/attackby(obj/item/O, mob/user, list/modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			to_chat(user, span_warning("There's already a brain in the MMI!"))
			return
		if(newbrain.suicided)
			to_chat(user, span_warning("[newbrain] is completely useless."))
			return
		if(!newbrain.brainmob)
			var/install = tgui_alert(user, "[newbrain] is inactive, slot it in anyway?", "Installing Brain", list("Yes", "No"))
			if(install != "Yes")
				return
			if(!user.transferItemToLoc(newbrain, src))
				return
			user.visible_message(span_notice("[user] sticks [newbrain] into [src]."), span_notice("[src]'s indicator light turns red as you insert [newbrain]. Its brainwave activity alarm buzzes."))
			brain = newbrain
			brain.organ_flags |= ORGAN_FROZEN
			name = "[initial(name)]: [copytext(newbrain.name, 1, -8)]"
			update_appearance()
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key && !newbrain.decoy_override)
			B.notify_revival("Someone has put your brain in a MMI!", source = src)
		user.visible_message(span_notice("[user] sticks \a [newbrain] into [src]."), span_notice("[src]'s indicator light turn on as you insert [newbrain]."))

		set_brainmob(newbrain.brainmob)
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		var/fubar_brain = newbrain.suicided || HAS_TRAIT(brainmob, TRAIT_SUICIDED) //brain is from a suicider
		if(!fubar_brain && !(newbrain.organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
			brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
		else if(!fubar_brain && newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
			to_chat(user, span_warning("[src]'s indicator light turns yellow and its brain integrity alarm beeps softly. Perhaps you should check [newbrain] for damage."))
			playsound(src, 'sound/machines/synth/synth_no.ogg', 5, TRUE)
		else
			to_chat(user, span_warning("[src]'s indicator light turns red and its brainwave activity alarm beeps softly. Perhaps you should check [newbrain] again."))
			playsound(src, 'sound/machines/beep/triple_beep.ogg', 5, TRUE)

		brainmob.reset_perspective()
		brain = newbrain
		brain.organ_flags |= ORGAN_FROZEN

		name = "[initial(name)]: [brainmob.real_name]"
		update_appearance()
		if(istype(brain, /obj/item/organ/brain/alien))
			braintype = "Xenoborg" //HISS....Beep.
		else
			braintype = "Cyborg"

		SSblackbox.record_feedback("amount", "mmis_filled", 1)

		user.log_message("has put the brain of [key_name(brainmob)] into an MMI", LOG_GAME)

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()

/**
 * Forces target brain into the MMI. Mainly intended for admin purposes, as this allows transfer without a mob or user.
 *
 * Returns FALSE on failure, TRUE on success.
 *
 * Arguments:
 * * new_brain - Brain to be force-inserted into the MMI. Any calling code should handle proper removal of the brain from the mob, as this proc only forceMoves.
 */
/obj/item/mmi/proc/force_brain_into(obj/item/organ/brain/new_brain)
	if(isnull(new_brain))
		stack_trace("Proc called with null brain.")
		return FALSE

	if(!istype(new_brain))
		stack_trace("Proc called with invalid type: [new_brain] ([new_brain.type])")
		return FALSE

	if(isnull(new_brain.brainmob))
		new_brain.forceMove(src)
		brain = new_brain
		brain.organ_flags |= ORGAN_FROZEN
		name = "[initial(name)]: [copytext(new_brain.name, 1, -8)]"
		update_appearance()
		return TRUE

	new_brain.forceMove(src)

	var/mob/living/brain/new_brain_brainmob = new_brain.brainmob
	if(!new_brain_brainmob.key && !new_brain.decoy_override)
		new_brain_brainmob.notify_revival("Someone has put your brain in a MMI!", source = src)

	set_brainmob(new_brain_brainmob)
	new_brain.brainmob = null
	brainmob.forceMove(src)
	brainmob.container = src

	var/fubar_brain = new_brain.suicided || HAS_TRAIT(brainmob, TRAIT_SUICIDED)
	if(!fubar_brain && !(new_brain.organ_flags & ORGAN_FAILING))
		brainmob.set_stat(CONSCIOUS)

	brainmob.reset_perspective()
	brain = new_brain
	brain.organ_flags |= ORGAN_FROZEN

	name = "[initial(name)]: [brainmob.real_name]"

	update_appearance()
	if(istype(brain, /obj/item/organ/brain/alien))
		braintype = "Xenoborg"
	else
		braintype = "Cyborg"

	SSblackbox.record_feedback("amount", "mmis_filled", 1)

	return TRUE

/obj/item/mmi/attack_self(mob/user)
	if(!brain)
		radio.set_on(!radio.is_on())
		to_chat(user, span_notice("You toggle [src]'s radio system [radio.is_on() == TRUE ? "on" : "off"]."))
	else
		eject_brain(user)
		update_appearance()
		name = initial(name)
		to_chat(user, span_notice("You unlock and upend [src], spilling the brain onto the floor."))

/obj/item/mmi/proc/eject_brain(mob/user)
	if(brainmob)
		brainmob.container = null //Reset brainmob mmi var.
		brainmob.forceMove(brain) //Throw mob into brain.
		brainmob.set_stat(DEAD)
		brainmob.emp_damage = 0
		brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
		brain.brainmob = brainmob //Set the brain to use the brainmob
		user.log_message("has ejected the brain of [key_name(brainmob)] from an MMI", LOG_GAME)
		brainmob = null //Set mmi brainmob var to null
	brain.forceMove(drop_location())
	if(Adjacent(user))
		user.put_in_hands(brain)
	brain.organ_flags &= ~ORGAN_FROZEN
	brain = null //No more brain in here

/obj/item/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/brain/newbrain = H.get_organ_by_type(/obj/item/organ/brain)
		newbrain.Remove(H, special = TRUE, movement_flags = NO_ID_TRANSFER)
		newbrain.forceMove(src)
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"
	brain.organ_flags |= ORGAN_FROZEN

	name = "[initial(name)]: [brainmob.real_name]"
	update_appearance()
	if(istype(brain, /obj/item/organ/brain/alien))
		braintype = "Xenoborg" //HISS....Beep.
	else
		braintype = "Cyborg"


/// Proc to hook behavior associated to the change in value of the [/obj/item/mmi/var/brainmob] variable.
/obj/item/mmi/proc/set_brainmob(mob/living/brain/new_brainmob)
	if(brainmob == new_brainmob)
		return FALSE
	. = brainmob
	SEND_SIGNAL(src, COMSIG_MMI_SET_BRAINMOB, new_brainmob)
	brainmob = new_brainmob
	if(new_brainmob)
		if(mecha)
			new_brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
		else
			new_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	if(.)
		var/mob/living/brain/old_brainmob = .
		old_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)


/// Proc to hook behavior associated to the change in value of the [obj/vehicle/sealed/var/mecha] variable.
/obj/item/mmi/proc/set_mecha(obj/vehicle/sealed/mecha/new_mecha)
	if(mecha == new_mecha)
		return FALSE
	. = mecha
	mecha = new_mecha
	if(new_mecha)
		if(!. && brainmob) // There was no mecha, there now is, and we have a brain mob that is no longer unaided.
			brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	else if(. && brainmob && immobilize) // There was a mecha, there no longer is one, and there is a brain mob that is now again unaided.
		brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)


/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, span_warning("Can't do that while incapacitated or dead!"))
	if(!radio.is_on())
		to_chat(brainmob, span_warning("Your radio is disabled!"))
		return

	radio.set_listening(!radio.get_listening())
	to_chat(brainmob, span_notice("Radio is [radio.get_listening() ? "now" : "no longer"] receiving broadcast."))

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")
		SEND_SIGNAL(brainmob, COMSIG_LIVING_MINOR_SHOCK) // DOPPLER EDIT ADDITION 

/obj/item/mmi/atom_deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()

/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += span_notice("There is a switch to toggle the radio system [radio.is_on() ? "off" : "on"].[brain ? " It is currently being covered by [brain]." : null]")

	if(!isnull(brain))
		// It's dead, show it as much
		if((brain.organ_flags & ORGAN_FAILING) || brainmob?.stat == DEAD)
			if(brain.suicided || (brainmob && HAS_TRAIT(brainmob, TRAIT_SUICIDED)))
				. += span_warning("[src] indicator light is red.")
			else
				. += span_warning("[src] indicator light is yellow - perhaps you should check the brain for damage.")
		// If we have a client, OR it's a decoy brain, show as active
		else if(brain.decoy_override || brainmob?.client)
			. += span_notice("[src] indicates that the brain is active.")
		// If we have a brainmob and it has a mind, it may just be DC'd
		else if(brainmob?.mind)
			. += span_warning("[src] indicates that the brain is currently inactive; it might change.")
		// No brainmob, no mind, and not a decoy, it's a dead brain
		else
			. += span_warning("[src] indicates that the brain is completely unresponsive.")

/obj/item/mmi/relaymove(mob/living/user, direction)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/proc/brain_check(mob/user)
	var/mob/living/brain/B = brainmob
	if(!B)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that there is no mind present!"))
		return FALSE
	if(brain?.decoy_override)
		if(user)
			to_chat(user, span_warning("This [name] does not seem to fit!"))
		return FALSE
	if(!B.key || !B.mind)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is completely unresponsive!"))
		return FALSE
	if(!B.client)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is currently inactive."))
		return FALSE
	if(HAS_TRAIT(B, TRAIT_SUICIDED) || brain?.suicided)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind has no will to live!"))
		return FALSE
	if(B.stat == DEAD)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is dead!"))
		return FALSE
	if(brain?.organ_flags & ORGAN_FAILING)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is damaged!"))
		return FALSE
	return TRUE

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."
	overrides_aicore_laws = TRUE

/obj/item/mmi/syndie/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.set_on(FALSE)
