/obj/item/brain_processor
	abstract_type = /obj/item/brain_processor // It is functionally complete though (sans sprites)

	name = "\improper Cerebral Processing Unit"
	desc = "Pure processing potential packed into a powerful puny pundit."
	icon = 'icons/obj/devices/assemblies.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = null

	/// The current occupant.
	VAR_FINAL/mob/living/brain/brainmob = null
	/// The processor's built-in radio.
	VAR_FINAL/obj/item/radio/brain_processor/radio = null
	/// The mech that the MMI is slotted inside.
	VAR_FINAL/obj/vehicle/sealed/mecha = null
	/// If supplied with a law datum, the laws will be transferred to whatever it's placed in.
	/// - If placed in a cyborg, it will start de-synced from the AI.
	/// The cyborg's laws will be unmodifiable unless synced to the AI or a law rack.
	/// - If placed in an AI, it will override the AI's laws.
	/// Likewise, the AI's laws will be unmodifiable unless synced to a law rack.
	VAR_FINAL/datum/ai_laws/laws = null

	var/braintype = "Cyborg"
	/// Whether the brainmob can move. Doesnt usually matter but SPHERICAL POSIBRAINSSS
	var/immobilize = TRUE
	/// If TRUE, and placed in an AI, calls replacement_ai_name() and uses that as the AI's name.
	var/force_replace_ai_name = FALSE

/obj/item/radio/brain_processor
	custom_materials = null

/obj/item/brain_processor/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.set_broadcasting(FALSE) //researching radio mmis turned the robofabs into radios because this didnt start as FALSE.

/obj/item/brain_processor/Destroy(force)
	set_mecha(null)
	QDEL_NULL(brainmob)
	QDEL_NULL(laws)
	QDEL_NULL(radio)
	return ..()

/obj/item/brain_processor/proc/set_brainmob(mob/living/brain/new_brainmob)
	SHOULD_CALL_PARENT(TRUE)

	if(brainmob == new_brainmob)
		return brainmob

	var/mob/living/brain/old_brainmob = brainmob
	if(old_brainmob)
		old_brainmob.container = null
		old_brainmob.emp_damage = 0 // okay?
		old_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
		REMOVE_TRAIT(old_brainmob, TRAIT_SILICON_EMOTES_ALLOWED, MMI_ASSISTED)

	brainmob = new_brainmob

	if(new_brainmob)
		new_brainmob.container = src
		ADD_TRAIT(new_brainmob, TRAIT_SILICON_EMOTES_ALLOWED, MMI_ASSISTED)
		if(mecha)
			new_brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
		else
			new_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)

	SEND_SIGNAL(src, COMSIG_MMI_SET_BRAINMOB, old_brainmob)

/// Proc to hook behavior associated to the change in value of the [obj/vehicle/sealed/var/mecha] variable.
/obj/item/brain_processor/proc/set_mecha(obj/vehicle/sealed/mecha/new_mecha)
	if(mecha == new_mecha)
		return new_mecha
	var/obj/vehicle/sealed/mecha/old_mecha = mecha
	. = mecha
	mecha = new_mecha
	if(new_mecha)
		if(!old_mecha && brainmob) // There was no mecha, there now is, and we have a brain mob that is no longer unaided.
			brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	else if(old_mecha && brainmob && immobilize) // There was a mecha, there no longer is one, and there is a brain mob that is now again unaided.
		brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)

GAME_VERB_SRC_DESC(/obj/item/brain_processor, Toggle_Listening, usr.loc, "Toggle Listening", "Toggle listening channel on or off.", "MMI")

	if(IS_UNCONSCIOUS_OR_CRIT(brainmob))
		to_chat(brainmob, span_warning("Can't do that while incapacitated or dead!"))
		return
	if(!radio.is_on())
		to_chat(brainmob, span_warning("Your radio is disabled!"))
		return

	radio.set_listening(!radio.get_listening())
	to_chat(brainmob, span_notice("Radio is [radio.get_listening() ? "now" : "no longer"] receiving broadcast."))

/obj/item/brain_processor/examine(mob/user)
	. = ..()
	if(radio)
		. += span_notice("There is a switch to toggle the radio system [radio.is_on() ? "off" : "on"].")

/obj/item/brain_processor/attack_self(mob/user)
	radio.set_on(!radio.is_on())
	var/new_state = radio.is_on() ? "on" : "off"
	to_chat(user, span_notice("You switch [src]'s radio system [span_bold(new_state)]."))
	balloon_alert(user, "radio turned [new_state]")

/obj/item/brain_processor/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(astype(L, /mob/living/carbon)?.has_dna())
		var/mob/living/carbon/carbon_target = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		carbon_target.dna.copy_dna(brainmob.stored_dna)

/obj/item/brain_processor/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return

	switch(severity)
		if(1)
			brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
		if(2)
			brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
		if(3)
			brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
	brainmob.emote("alarm")

/obj/item/brain_processor/relaymove(mob/living/user, direction)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/brain_processor/proc/brain_check(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(!brainmob)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that there is no mind present!"))
		return FALSE
	if(!brainmob.key || !brainmob.mind)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is completely unresponsive!"))
		return FALSE
	if(!brainmob.client)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is currently inactive."))
		return FALSE
	if(suicided())
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind has no will to live!"))
		return FALSE
	if(brainmob.stat >= DEAD)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is dead!"))
		return FALSE
	return TRUE

/obj/item/brain_processor/proc/replacement_ai_name()
	return brainmob.name

/obj/item/brain_processor/proc/suicided()
	return HAS_TRAIT(brainmob, TRAIT_SUICIDED)

/obj/item/brain_processor/proc/set_name(new_name)
	brainmob.name = new_name
	brainmob.real_name = new_name

/obj/item/brain_processor/proc/set_suicide(suicided)
	brainmob.set_suicide(suicided)
