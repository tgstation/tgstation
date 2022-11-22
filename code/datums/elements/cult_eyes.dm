/**
 * # Cult eyes element
 *
 * Applies and removes the glowing cult eyes
 */
/datum/element/cult_eyes

/datum/element/cult_eyes/Attach(datum/target, initial_delay = 20 SECONDS)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Register signals for mob transformation to prevent premature halo removal
	RegisterSignals(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_MONKEY_HUMANIZE, COMSIG_HUMAN_MONKEYIZE), PROC_REF(set_eyes))
	addtimer(CALLBACK(src, PROC_REF(set_eyes), target), initial_delay)

/**
 * Cult eye setter proc
 *
 * Changes the eye color, and adds the glowing eye trait to the mob.
 */
/datum/element/cult_eyes/proc/set_eyes(mob/living/target)
	SIGNAL_HANDLER

	ADD_TRAIT(target, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		human_parent.eye_color_left = BLOODCULT_EYE
		human_parent.eye_color_right = BLOODCULT_EYE
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_LEFT_BLOCK)
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)
		human_parent.update_body()

/**
 * Detach proc
 *
 * Removes the eye color, and trait from the mob
 */
/datum/element/cult_eyes/Detach(mob/living/target, ...)
	REMOVE_TRAIT(target, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	if (ishuman(target))
		var/mob/living/carbon/human/human_parent = target
		human_parent.eye_color_left = initial(human_parent.eye_color_left)
		human_parent.eye_color_right = initial(human_parent.eye_color_right)
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_LEFT_BLOCK)
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)
		human_parent.update_body()
	UnregisterSignal(target, list(COMSIG_CHANGELING_TRANSFORM, COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE))
	return ..()
