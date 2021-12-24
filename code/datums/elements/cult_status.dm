//TODO: make halos a trait
//handle all of the signal sending and stage on the cult side










/**
 * # Cult Status element
 *
 * Element used to manage and display the visual cult effects.
 *
 * Used to apply and remove the traits, and overlays associated with the growing size of a cult.
 */
/datum/element/cult_status

/**
 * Check if the cultist needs to have their
 */
/datum/element/cult_status/Attach(datum/target)
	if (!ismob(target))
		return
	var/mob/living/parent = target
	//RegisterSignal(parent, COMSIG_CULT_VIS, .proc/raise_level)
	//RegisterSignal(parent, COMSIG_ANTAGONIST_REMOVED, .proc/UnregisterFromParent)
	RegisterSignal(parent, COMSIG_MOB_TRANSFORMING, .proc/handle_transform)

	var/datum/team/cult/parent_team
	var/mob/parent_mob = parent
	for (var/datum/antagonist/cult/cult_datum in parent_mob.mind.antag_datums)
		parent_team = cult_datum.get_team()
	if (parent_team.cult_risen)
		set_eyes()
	else if (parent_team.cult_ascendent)
		set_eyes()
		set_halo()

/**
 * Removes all the effects applied when removing the component.
 */
/datum/element/cult_status/Detach(datum/source, ...)
	. = ..()
	var/mob/parent = source
	if (HAS_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		REMOVE_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
		if (ishuman(parent))
			var/mob/living/carbon/human/human_parent = parent
			human_parent.eye_color = initial(human_parent.eye_color)
			human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
	if (HAS_TRAIT(parent, TRAIT_CULT_HALO))
		REMOVE_TRAIT(parent, TRAIT_CULT_HALO, CULT_TRAIT)
		if (ishuman(parent))
			var/mob/living/carbon/human/human_parent = parent
			human_parent.remove_overlay(HALO_LAYER)
			human_parent.update_body()
		else
			var/mob/living/mob = parent
			mob.cut_overlay(HALO_LAYER)
	UnregisterSignal(parent, COMSIG_CULT_VIS)
	UnregisterSignal(parent, COMSIG_ANTAGONIST_REMOVED)
	UnregisterSignal(parent, COMSIG_MOB_TRANSFORMING)

/**
 * Raise the current visibility level of the cultist.
 *
 * Checks the current stage, raises it if a specific level is not applied.
 * Supplies the flavour text, and the sounds, then calls the procs associated with each stage.
 * Arguments:
 * * _stage - (Optional) Specify the cult visibility stage to raise to.
 */
/datum/element/cult_status/proc/raise_level(datum/parent)
	// TODO: change this to fit new specs
	// this should be checking the status of the cult
	if (STAGE_CULT_RED_EYES)
		SEND_SOUND(parent, 'sound/hallucinations/i_see_you2.ogg')
		to_chat(parent, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
		addtimer(CALLBACK(src, .proc/set_eyes, parent), 20 SECONDS)
	if (STAGE_CULT_HALOS)
		SEND_SOUND(parent, 'sound/hallucinations/im_here1.ogg')
		to_chat(parent, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
		addtimer(CALLBACK(src, .proc/set_halo, parent), 20 SECONDS)

/**
 * Set the eyes of the cultist to begin glowing.
 *
 * Humans will have their eye colour changed, while any other mob will just have "glowing eyes".
 */
/datum/element/cult_status/proc/set_eyes(datum/parent)
	ADD_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES, CULT_TRAIT)
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		human_parent.eye_color = BLOODCULT_EYE
		human_parent.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		human_parent.update_body()

/**
 * Apply a floating halo above the cultist.
 */
/datum/element/cult_status/proc/set_halo(datum/parent)
	ADD_TRAIT(parent, TRAIT_CULT_HALO, CULT_TRAIT)
	var/icon_state = pick ("halo1", "halo2", "halo3", "halo4", "halo5", "halo6")
	var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/effects/32x64.dmi', icon_state, -HALO_LAYER)
	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		new /obj/effect/temp_visual/cult/sparks(get_turf(human_parent), human_parent.dir)
		human_parent.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_parent.apply_overlay(HALO_LAYER)
	else
		var/mob/living/mob = parent
		mob.add_overlay(new_halo_overlay)

/**
 * Handle mob transformation.
 *
 * Prevents deleting the given traits by transforming into a different mob.
 */
/datum/element/cult_status/proc/handle_transform(datum/parent)
	if (HAS_TRAIT(parent, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		set_eyes()
	if (HAS_TRAIT(parent, TRAIT_CULT_HALO))
		set_halo()
