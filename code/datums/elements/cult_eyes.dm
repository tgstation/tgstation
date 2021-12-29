/**
 * # Cult eyes element
 *
 * Applies and removes the glowing cult eyes
 */
/datum/element/cult_eyes

/datum/element/cult_eyes/Attach(datum/target, override = FALSE)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CHANGELING_TRANSFORM, .proc/set_eyes)
	RegisterSignal(target, COMSIG_MONKEY_HUMANIZE, .proc/set_eyes)
	RegisterSignal(target, COMSIG_HUMAN_MONKEYIZE, .proc/set_eyes)

	if (override)
		set_eyes(target)
	else
		addtimer(CALLBACK(src, .proc/set_eyes, target), 20 SECONDS)

/**
 * Cult eye setter proc
 *
 * Changes the eye color, and adds the glowing eye trait to the mob.
 */
/datum/element/cult_eyes/proc/set_eyes(datum/target)
	SIGNAL_HANDLER

	var/mob/living/parent_mob = target
	ADD_TRAIT(parent_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	if (ishuman(parent_mob))
		var/mob/living/carbon/human/human_parent = parent_mob
		human_parent.eye_color = BLOODCULT_EYE
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		human_parent.update_body()

/**
 * Detach proc
 *
 * Removes the eye color, and trait from the mob
 */
/datum/element/cult_eyes/Detach(datum/target, ...)
	. = ..()
	var/mob/living/parent_mob = target
	REMOVE_TRAIT(parent_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	if (ishuman(parent_mob))
		var/mob/living/carbon/human/human_parent = parent_mob
		human_parent.eye_color = initial(human_parent.eye_color)
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		human_parent.update_body()

	UnregisterSignal(target, COMSIG_CHANGELING_TRANSFORM)
	UnregisterSignal(target, COMSIG_HUMAN_MONKEYIZE)
	UnregisterSignal(target, COMSIG_MONKEY_HUMANIZE)
