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

/datum/component/living_heart/Initialize()
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/organ/organ_parent = parent
	// These are incompatible for "balance" reasons, not due to code limitations.
	if(organ_parent.status != ORGAN_ORGANIC || (organ_parent.organ_flags & ORGAN_SYNTHETIC))
		return COMPONENT_INCOMPATIBLE

	if(!IS_HERETIC(organ_parent.owner))
		return COMPONENT_INCOMPATIBLE

	action = new(organ_parent)
	action.Grant(organ_parent.owner)

	ADD_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

	// The heart's not technically visible (and is never visible to anyone besides the heretic),
	// but the organ sprite shows up in the organ action  - so we'll do this anyways
	parent.AddElement(/datum/element/update_icon_blocker)
	old_icon = organ_parent.icon

	organ_parent.icon = 'icons/obj/eldritch.dmi'
	organ_parent.icon_state = "living_heart"
	action.UpdateButtons()

/datum/component/living_heart/Destroy(force, silent)
	QDEL_NULL(action)
	REMOVE_TRAIT(parent, TRAIT_LIVING_HEART, REF(src))
	UnregisterSignal(parent, COMSIG_ORGAN_REMOVED)

	// Restore the heart to look normal
	parent.RemoveElement(/datum/element/update_icon_blocker)
	var/obj/item/organ/organ_parent = parent
	organ_parent.icon = old_icon
	organ_parent.icon_state = initial(organ_parent.icon_state)

	// Sets the icon state to be the correct state
	organ_parent.update_appearance(UPDATE_ICON_STATE)

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
	var/track_cooldown_lenth = 4 SECONDS
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

	return TRUE

/datum/action/item_action/organ_action/track_target/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(owner)
	var/datum/heretic_knowledge/sac_knowledge = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!LAZYLEN(heretic_datum.sac_targets))
		owner.balloon_alert(owner, "no targets, visit a rune!")
		return TRUE

	var/list/targets_to_choose = list()
	var/list/mob/living/carbon/human/human_targets = list()
	for(var/mob/living/carbon/human/sac_target as anything in heretic_datum.sac_targets)
		human_targets[sac_target.real_name] = sac_target
		targets_to_choose[sac_target.real_name] = heretic_datum.sac_targets[sac_target]

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
	UpdateButtons()
	addtimer(CALLBACK(src, .proc/UpdateButtons), track_cooldown_lenth + 1)
	playsound(owner, 'sound/effects/singlebeat.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	owner.balloon_alert(owner, get_balloon_message(tracked_mob))

	// Let them know how to sacrifice people if they're able to be sac'd
	if(tracked_mob.stat == DEAD)
		to_chat(owner, span_hierophant("[tracked_mob] is dead. Bring them to a transmutation rune \
			and invoke \"[sac_knowledge.name]\" to sacrifice them!"))

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

/// Gets the balloon message for who we're tracking.
/datum/action/item_action/organ_action/track_target/proc/get_balloon_message(mob/living/carbon/human/tracked_mob)
	var/balloon_message = "error text!"
	var/turf/their_turf = get_turf(tracked_mob)
	var/turf/our_turf = get_turf(owner)
	var/their_z = their_turf?.z
	var/our_z = our_turf?.z

	// One of us is in somewhere we shouldn't be
	if(!our_z || !their_z)
		// "Hell if I know"
		balloon_message = "on another plane!"

	// They're not on the same z-level as us
	else if(our_z != their_z)
		// They're on the station
		if(is_station_level(their_z))
			// We're on a multi-z station
			if(is_station_level(our_z))
				if(our_z > their_z)
					balloon_message = "below you!"
				else
					balloon_message = "above you!"
			// We're off station, they're not
			else
				balloon_message = "on station!"

		// Mining
		else if(is_mining_level(their_z))
			balloon_message = "on lavaland!"

		// In the gateway
		else if(is_away_level(their_z) || is_secret_level(their_z))
			balloon_message = "beyond the gateway!"

		// They're somewhere we probably can't get too - sacrifice z-level, centcom, etc
		else
			balloon_message = "on another plane!"

	// They're on the same z-level as us!
	else
		var/dist = get_dist(our_turf, their_turf)
		var/dir = get_dir(our_turf, their_turf)

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

	return balloon_message
