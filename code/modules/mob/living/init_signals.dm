/// Called on [/mob/living/Initialize(mapload)], for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_DEATHCOMA), PROC_REF(on_deathcoma_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA), PROC_REF(on_deathcoma_trait_loss))

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

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NEGATES_GRAVITY), SIGNAL_REMOVETRAIT(TRAIT_NEGATES_GRAVITY)), PROC_REF(on_negate_gravity))

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


/// Called when [TRAIT_IMMOBILIZED] is added to the mob.
/mob/living/proc/on_immobilized_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~MOBILITY_MOVE
	if(living_flags & MOVES_ON_ITS_OWN)
		SSmove_manager.stop_looping(src) //stop mid walk //This is also really dumb

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
	unset_machine()
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
	ADD_TRAIT(src, TRAIT_UI_BLOCKED, TRAIT_INCAPACITATED)
	ADD_TRAIT(src, TRAIT_PULL_BLOCKED, TRAIT_INCAPACITATED)
	update_appearance()

/// Called when [TRAIT_INCAPACITATED] is removed from the mob.
/mob/living/proc/on_incapacitated_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_UI_BLOCKED, TRAIT_INCAPACITATED)
	REMOVE_TRAIT(src, TRAIT_PULL_BLOCKED, TRAIT_INCAPACITATED)
	update_appearance()


/// Called when [TRAIT_RESTRAINED] is added to the mob.
/mob/living/proc/on_restrained_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)

/// Called when [TRAIT_RESTRAINED] is removed from the mob.
/mob/living/proc/on_restrained_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)


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

/// Called with [TRAIT_NEGATES_GRAVITY] is gained or lost
/mob/living/proc/on_negate_gravity(datum/source)
	SIGNAL_HANDLER
	update_gravity(has_gravity())
