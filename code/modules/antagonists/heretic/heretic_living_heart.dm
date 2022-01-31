/**
 * # Living Heart Component
 *
 * Applied to a heart to turn it into a heretic's 'living heart'.
 * The living heart is what they use to track people they need to sacrifice.
 *
 * This component handles adding the associated action, as well as updating the heart's icon.
 *
 * Must be attached to an organ located within a heretic.
 * If removed from the body of a heretic, it will self-delete and become a normal heart again.
 */
/datum/component/living_heart
	/// The action we create and give to our heart.
	var/datum/action/item_action/organ_action/track_target/action
	/// The icon of the heart before we made it a living heart.
	var/old_icon
	/// The icon_state of the heart before we made it a living heart.
	var/old_icon_state

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	if(organ_parent.status != ORGAN_ORGANIC)
		return COMPONENT_INCOMPATIBLE

	if(!IS_HERETIC(organ_parent.owner))
		return COMPONENT_INCOMPATIBLE

	action = new(organ_parent)
	action.Grant(organ_parent.owner)

	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

	// It's not technically visible,
	// but the organ sprite shows up in the action
	// So we'll do this anyways
	parent.AddElement(/datum/element/update_icon_blocker)
	old_icon = organ_parent.icon
	old_icon_state = organ_parent.icon_state

	organ_parent.icon = 'icons/obj/eldritch.dmi'
	organ_parent.icon_state = "living_heart"
	action.UpdateButtonIcon()

/datum/component/living_heart/Destroy(force, silent)
	QDEL_NULL(action)
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, COMSIG_ORGAN_REMOVED)

	parent.RemoveElement(/datum/element/update_icon_blocker)
	var/obj/item/organ/organ_parent = parent
	organ_parent.icon = old_icon
	organ_parent.icon_state = old_icon_state

	return ..()

/**
 * Signal proc for [COMSIG_ORGAN_REMOVED].
 *
 * If the organ is removed, the component will remove itself.
 */
/datum/component/living_heart/proc/on_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	to_chat(old_owner, span_userdanger("As your living [source.name] leaves your body, you feel less connected to the Mansus!"))
	qdel(src)

/*
 * The action associated with the living heart.
 * Allows a heretic to track sacrifice targets.
 */
/datum/action/item_action/organ_action/track_target
	name = "Living Heartbeat"
	desc = "Track your targets."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_ecult"
	/// How long we have to wait between tracking uses.
	var/track_cooldown_lenth = 8 SECONDS
	/// The cooldown between button uses.
	COOLDOWN_DECLARE(track_cooldown)

/datum/action/item_action/organ_action/track_target/Grant(mob/granted)
	if(!IS_HERETIC(granted))
		return

	return ..()

/datum/action/item_action/organ_action/track_target/IsAvailable()
	if(!IS_HERETIC(owner))
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_LIVING_HEART))
		return FALSE
	if(!COOLDOWN_FINISHED(src, track_cooldown))
		return FALSE

	return ..()

/datum/action/item_action/organ_action/track_target/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner)
	if(!LAZYLEN(heretic_datum.sac_targets))
		to_chat(owner, span_danger("You have no targets. Visit a transmutation rune to aquire targets!"))
		return TRUE

	COOLDOWN_START(src, track_cooldown, track_cooldown_lenth)

	var/list/mob/living/carbon/human/human_targets = list()
	for(var/datum/weakref/target_ref as anything in heretic_datum.sac_targets)
		var/mob/living/carbon/human/real_target = target_ref?.resolve()
		if(!QDELETED(real_target))
			human_targets += real_target

	playsound(owner, 'sound/effects/singlebeat.ogg', 40, TRUE, SILENCED_SOUND_EXTRARANGE)
	for(var/mob/living/carbon/human/mob_target as anything in human_targets)
		var/dist = get_dist(get_turf(owner), get_turf(mob_target))
		var/dir = get_dir(get_turf(owner), get_turf(mob_target))

		if(isturf(mob_target.loc) && owner.z != mob_target.z)
			to_chat(owner, span_warning("[mob_target.real_name] is on another plane of existence!"))
		else
			switch(dist)
				if(0 to 15)
					to_chat(owner, span_warning("[mob_target.real_name] is near you. They are to the [dir2text(dir)] of you!"))
				if(16 to 31)
					to_chat(owner, span_warning("[mob_target.real_name] is somewhere in your vicinity. They are to the [dir2text(dir)] of you!"))
				if(32 to 127)
					to_chat(owner, span_warning("[mob_target.real_name] is far away from you. They are to the [dir2text(dir)] of you!"))
				else
					to_chat(owner, span_warning("[mob_target.real_name] is beyond our reach."))

		if(mob_target.stat == DEAD)
			to_chat(owner, span_warning("[mob_target.real_name] is dead. Bring them to a transmutation rune!"))
