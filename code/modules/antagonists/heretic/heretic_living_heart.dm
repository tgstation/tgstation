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
	desc = "LMB: Chose one of your sacrifice targets to track. RMB: Repeats last target you chose to track."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_ecult"
	/// The real name of the last mob we tracked
	var/last_tracked_name
	/// Whether the target radial is currently opened.
	var/radial_open = FALSE
	/// How long we have to wait between tracking uses.
	var/track_cooldown_lenth = 8 SECONDS
	/// The cooldown between button uses.
	COOLDOWN_DECLARE(track_cooldown)

/datum/action/item_action/organ_action/track_target/Grant(mob/granted)
	if(!IS_HERETIC(granted))
		return

	return ..()

/datum/action/item_action/organ_action/track_target/IsAvailable()
	. = ..()
	if(!.)
		return

	if(!IS_HERETIC(owner))
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_LIVING_HEART))
		return FALSE
	if(!COOLDOWN_FINISHED(src, track_cooldown))
		return FALSE
	if(radial_open)
		return FALSE

/datum/action/item_action/organ_action/track_target/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner)
	if(!LAZYLEN(heretic_datum.sac_targets))
		owner.balloon_alert(owner, "no targets, visit a rune!")
		return TRUE

	var/list/targets_to_choose = list()
	var/list/mob/living/carbon/human/human_targets = list()
	for(var/datum/weakref/target_ref as anything in heretic_datum.sac_targets)
		var/mob/living/carbon/human/real_target = target_ref.resolve()
		if(QDELETED(real_target))
			continue

		human_targets[real_target.real_name] = real_target
		targets_to_choose[real_target.real_name] = heretic_datum.sac_targets[target_ref]

	// If we don't have a last tracked name, open a radial to set one.
	// If we DO have a last tracked name, we skip the radial if they right click the action.
	if(isnull(last_tracked_name) || !(trigger_flags & TRIGGER_SECONDARY_ACTION))
		radial_open = TRUE
		last_tracked_name = show_radial_menu(
			owner,
			owner,
			targets_to_choose,
			custom_check = CALLBACK(src, .proc/check_menu),
			radius = 40,
			require_near = TRUE,
			tooltips = TRUE,
		)
		radial_open = FALSE

	// If our last tracked name is still null, skip the trigger
	if(isnull(last_tracked_name))
		return FALSE

	var/mob/living/carbon/human/tracked_mob = human_targets[last_tracked_name]
	if(QDELETED(tracked_mob))
		last_tracked_name = null
		return FALSE

	COOLDOWN_START(src, track_cooldown, track_cooldown_lenth)
	var/balloon_message = "error text!"

	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(isturf(tracked_mob.loc) && owner.z != tracked_mob.z)
		balloon_message = "on another plane!"
	else
		var/dist = get_dist(get_turf(owner), get_turf(tracked_mob))
		var/dir = get_dir(get_turf(owner), get_turf(tracked_mob))

		switch(dist)
			if(0 to 15)
				balloon_message = "very near, [dir2text(dir)]!"
			if(16 to 31)
				balloon_message = "near, [dir2text(dir)]!"
			if(32 to 127)
				balloon_message = "far, [dir2text(dir)]!"
			else
				balloon_message = "very far!"

	if(tracked_mob.stat == DEAD)
		balloon_message = "they're dead, " + balloon_message

	owner.balloon_alert(owner, balloon_message)
	return TRUE

/// Callback for the radial to ensure it's closed when not allowed.
/datum/action/item_action/organ_action/track_target/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!IS_HERETIC(owner))
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_LIVING_HEART))
		return FALSE
	return TRUE
