/// Called on [/mob/living/Initialize(mapload)], for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_DEATHCOMA), PROC_REF(on_deathcoma_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA), PROC_REF(on_deathcoma_trait_loss))

	RegisterSignals(src, list(
		SIGNAL_ADDTRAIT(TRAIT_FAKEDEATH),
		SIGNAL_REMOVETRAIT(TRAIT_FAKEDEATH),

		SIGNAL_ADDTRAIT(TRAIT_DEFIB_BLACKLISTED),
		SIGNAL_REMOVETRAIT(TRAIT_DEFIB_BLACKLISTED),
	), PROC_REF(update_medhud_on_signal))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_immobilized_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_immobilized_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FORCED_STANDING), PROC_REF(on_forced_standing_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FORCED_STANDING), PROC_REF(on_forced_standing_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_UI_BLOCKED), PROC_REF(on_ui_blocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_UI_BLOCKED), PROC_REF(on_ui_blocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PULL_BLOCKED), PROC_REF(on_pull_blocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PULL_BLOCKED), PROC_REF(on_pull_blocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), PROC_REF(on_incapacitated_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED), PROC_REF(on_incapacitated_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_DEAF), PROC_REF(on_hearing_loss))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_DEAF), PROC_REF(on_hearing_regain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_STASIS), PROC_REF(on_stasis_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_STASIS), PROC_REF(on_stasis_trait_loss))

	RegisterSignals(src, list(
		SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION),
		SIGNAL_REMOVETRAIT(TRAIT_CRITICAL_CONDITION),

		SIGNAL_ADDTRAIT(TRAIT_NODEATH),
		SIGNAL_REMOVETRAIT(TRAIT_NODEATH),
	), PROC_REF(update_succumb_action))

	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_movement_type_flag_enabled))
	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_movement_type_flag_disabled))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_SKITTISH), PROC_REF(on_skittish_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_SKITTISH), PROC_REF(on_skittish_trait_loss))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNDENSE), SIGNAL_REMOVETRAIT(TRAIT_UNDENSE)), PROC_REF(undense_changed))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NEGATES_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_NEGATES_GRAVITY)), PROC_REF(on_negate_gravity))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_IGNORING_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_IGNORING_GRAVITY)), PROC_REF(on_ignore_gravity))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_FORCED_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_FORCED_GRAVITY)), PROC_REF(on_force_gravity))
	// We hook for forced grav changes from our turf and ourselves
	var/static/list/loc_connections = list(
		SIGNAL_ADDTRAIT(TRAIT_FORCED_GRAVITY) = PROC_REF(on_loc_force_gravity),
		SIGNAL_REMOVETRAIT(TRAIT_FORCED_GRAVITY) = PROC_REF(on_loc_force_gravity),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	RegisterSignal(src, COMSIG_MOVABLE_EDIT_UNIQUE_IMMERSE_OVERLAY, PROC_REF(edit_immerse_overlay))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_BASIC_HEALTH_HUD_VISIBLE), PROC_REF(add_to_basic_health_hud))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_BASIC_HEALTH_HUD_VISIBLE), PROC_REF(remove_from_basic_health_hud))


/// Called when [TRAIT_KNOCKEDOUT] is added to the mob.
/mob/living/proc/on_knockedout_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(stat < UNCONSCIOUS)
		set_stat(UNCONSCIOUS)

/// Called when [TRAIT_KNOCKEDOUT] is removed from the mob.
/mob/living/proc/on_knockedout_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(stat <= UNCONSCIOUS)
		update_stat()

/// Called when [TRAIT_DEATHCOMA] is added to the mob.
/mob/living/proc/on_deathcoma_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_DEATHCOMA)

/// Called when [TRAIT_DEATHCOMA] is removed from the mob.
/mob/living/proc/on_deathcoma_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_DEATHCOMA)

/// Updates medhud when receiving relevant signals.
/mob/living/proc/update_medhud_on_signal(datum/source)
	SIGNAL_HANDLER
	med_hud_set_health()
	med_hud_set_status()

/// Called when [TRAIT_IMMOBILIZED] is added to the mob.
/mob/living/proc/on_immobilized_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~MOBILITY_MOVE
	if(living_flags & MOVES_ON_ITS_OWN)
		GLOB.move_manager.stop_looping(src) //stop mid walk //This is also really dumb

/// Called when [TRAIT_IMMOBILIZED] is removed from the mob.
/mob/living/proc/on_immobilized_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_MOVE


/// Called when [TRAIT_FLOORED] is added to the mob.
/mob/living/proc/on_floored_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(buckled && buckled.buckle_lying != NO_BUCKLE_LYING)
		return // Handled by the buckle.
	if(HAS_TRAIT(src, TRAIT_FORCED_STANDING))
		return // Don't go horizontal if mob has forced standing trait.
	mobility_flags &= ~MOBILITY_STAND
	on_floored_start()


/// Called when [TRAIT_FLOORED] is removed from the mob.
/mob/living/proc/on_floored_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_STAND
	on_floored_end()

/// Called when [TRAIT_FORCED_STANDING] is added to the mob.
/mob/living/proc/on_forced_standing_trait_gain(datum/source)
	SIGNAL_HANDLER

	set_body_position(STANDING_UP)
	set_lying_angle(0)

/// Called when [TRAIT_FORCED_STANDING] is removed from the mob.
/mob/living/proc/on_forced_standing_trait_loss(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_FLOORED))
		on_fall()
		set_lying_down()
	else if(resting)
		set_lying_down()

/// Called when [TRAIT_HANDS_BLOCKED] is added to the mob.
/mob/living/proc/on_handsblocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	on_handsblocked_start()

/// Called when [TRAIT_HANDS_BLOCKED] is removed from the mob.
/mob/living/proc/on_handsblocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	on_handsblocked_end()


/// Called when [TRAIT_UI_BLOCKED] is added to the mob.
/mob/living/proc/on_ui_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_UI)
	update_mob_action_buttons()

/// Called when [TRAIT_UI_BLOCKED] is removed from the mob.
/mob/living/proc/on_ui_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_UI
	update_mob_action_buttons()


/// Called when [TRAIT_PULL_BLOCKED] is added to the mob.
/mob/living/proc/on_pull_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_PULL)
	if(pulling)
		stop_pulling()

/// Called when [TRAIT_PULL_BLOCKED] is removed from the mob.
/mob/living/proc/on_pull_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_PULL


/// Called when [TRAIT_INCAPACITATED] is added to the mob.
/mob/living/proc/on_incapacitated_trait_gain(datum/source)
	SIGNAL_HANDLER
	add_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_INCAPACITATED)
	update_appearance()
	update_incapacitated()

/// Called when [TRAIT_INCAPACITATED] is removed from the mob.
/mob/living/proc/on_incapacitated_trait_loss(datum/source)
	SIGNAL_HANDLER
	remove_traits(list(TRAIT_UI_BLOCKED, TRAIT_PULL_BLOCKED), TRAIT_INCAPACITATED)
	update_appearance()
	update_incapacitated()

/// Called when [TRAIT_RESTRAINED] is added to the mob.
/mob/living/proc/on_restrained_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)
	update_incapacitated()

/// Called when [TRAIT_RESTRAINED] is removed from the mob.
/mob/living/proc/on_restrained_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)
	update_incapacitated()

/// Called when [TRAIT_STASIS] is added to the mob
/mob/living/proc/on_stasis_trait_gain(datum/source)
	SIGNAL_HANDLER
	update_incapacitated()

/// Called when [TRAIT_STASIS] is removed from the mob
/mob/living/proc/on_stasis_trait_loss(datum/source)
	SIGNAL_HANDLER
	update_incapacitated()

/**
 * Called when traits that alter succumbing are added/removed.
 *
 * Will show or hide the succumb alert prompt.
 */
/mob/living/proc/update_succumb_action()
	SIGNAL_HANDLER
	if (CAN_SUCCUMB(src) || HAS_TRAIT(src, TRAIT_SUCCUMB_OVERRIDE))
		throw_alert(ALERT_SUCCUMB, /atom/movable/screen/alert/succumb)
	else
		clear_alert(ALERT_SUCCUMB)

///From [element/movetype_handler/on_movement_type_trait_gain()]
/mob/living/proc/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	SIGNAL_HANDLER
	update_movespeed(FALSE)

///From [element/movetype_handler/on_movement_type_trait_loss()]
/mob/living/proc/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	SIGNAL_HANDLER
	update_movespeed(FALSE)


/// Called when [TRAIT_SKITTISH] is added to the mob.
/mob/living/proc/on_skittish_trait_gain(datum/source)
	SIGNAL_HANDLER
	AddElement(/datum/element/skittish)

/// Called when [TRAIT_SKITTISH] is removed from the mob.
/mob/living/proc/on_skittish_trait_loss(datum/source)
	SIGNAL_HANDLER
	RemoveElement(/datum/element/skittish)

/// Called when [TRAIT_NEGATES_GRAVITY] is gained or lost
/mob/living/proc/on_negate_gravity(datum/source)
	SIGNAL_HANDLER
	if(!isgroundlessturf(loc))
		if(HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY))
			ADD_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)
		else
			REMOVE_TRAIT(src, TRAIT_IGNORING_GRAVITY, IGNORING_GRAVITY_NEGATION)

/// Called when [TRAIT_IGNORING_GRAVITY] is gained or lost
/mob/living/proc/on_ignore_gravity(datum/source)
	SIGNAL_HANDLER
	refresh_gravity()

/// Called when [TRAIT_FORCED_GRAVITY] is gained or lost
/mob/living/proc/on_force_gravity(datum/source)
	SIGNAL_HANDLER
	refresh_gravity()

/// Called when our loc's [TRAIT_FORCED_GRAVITY] is gained or lost
/mob/living/proc/on_loc_force_gravity(datum/source)
	SIGNAL_HANDLER
	refresh_gravity()

/mob/living/proc/edit_immerse_overlay(datum/source, atom/movable/immerse_mask/effect_relay)
	SIGNAL_HANDLER
	effect_relay.transform = effect_relay.transform.Scale(1 / current_size)
	effect_relay.transform = effect_relay.transform.Turn(-lying_angle)

/// Called when [TRAIT_UNDENSE] is gained or lost
/mob/living/proc/undense_changed(datum/source)
	SIGNAL_HANDLER
	update_density()

///Called when [TRAIT_DEAF] is added to the mob.
/mob/living/proc/on_hearing_loss()
	SIGNAL_HANDLER
	refresh_looping_ambience()
	stop_sound_channel(CHANNEL_AMBIENCE)

///Called when [TRAIT_DEAF] is added to the mob.
/mob/living/proc/on_hearing_regain()
	SIGNAL_HANDLER
	refresh_looping_ambience()

/// When gaining [TRAIT_BASIC_HEALTH_HUD_VISIBLE], add to the basic health hud
/mob/living/proc/add_to_basic_health_hud(datum/source)
	SIGNAL_HANDLER
	var/datum/atom_hud/data/human/medical/basic/hud = GLOB.huds[DATA_HUD_MEDICAL_BASIC]
	hud.add_atom_to_hud(src)

/// When losing [TRAIT_BASIC_HEALTH_HUD_VISIBLE], remove from the basic health hud
/mob/living/proc/remove_from_basic_health_hud(datum/source)
	SIGNAL_HANDLER
	var/datum/atom_hud/data/human/medical/basic/hud = GLOB.huds[DATA_HUD_MEDICAL_BASIC]
	hud.remove_atom_from_hud(src)
