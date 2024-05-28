/datum/mafia_ability
	var/name = "Mafia Ability"
	var/ability_action = "brutally murder"

	///The priority level this action must be sent at. Setting this to null will prevent it from being triggered automatically.
	///(COMSIG_MAFIA_NIGHT_PRE_ACTION_PHASE|COMSIG_MAFIA_NIGHT_ACTION_PHASE|COMSIG_MAFIA_NIGHT_KILL_PHASE)
	var/action_priority = COMSIG_MAFIA_NIGHT_ACTION_PHASE
	///When the ability can be used: (MAFIA_PHASE_DAY | MAFIA_PHASE_VOTING | MAFIA_PHASE_NIGHT)
	var/valid_use_period = MAFIA_PHASE_NIGHT
	///Whether this ability can be used on yourself. Selections: (CAN_USE_ON_OTHERS | CAN_USE_ON_SELF | CAN_USE_ON_DEAD)
	var/use_flags = CAN_USE_ON_OTHERS

	///Boolean on whether the ability was selected to be used during the proper period.
	var/using_ability = FALSE
	///The mafia role that holds this ability.
	var/datum/mafia_role/host_role
	///The mafia role this ability is targeting, if necessary.
	var/datum/mafia_role/target_role

/datum/mafia_ability/New(datum/mafia_controller/game, datum/mafia_role/host_role)
	. = ..()
	src.host_role = host_role
	if(action_priority)
		RegisterSignal(game, action_priority, PROC_REF(perform_action_target))
		RegisterSignal(game, COMSIG_MAFIA_NIGHT_END, PROC_REF(clean_action_refs))

/datum/mafia_ability/Destroy(force)
	host_role = null
	target_role = null
	return ..()

///Handles special messagese sent by ability-specific stuff (such as changeling chat).
/datum/mafia_ability/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	return FALSE

/**
 * Called when refs need to be cleared, when the target is no longer set.
 */
/datum/mafia_ability/proc/clean_action_refs(datum/mafia_controller/game)
	SIGNAL_HANDLER

	SHOULD_CALL_PARENT(TRUE)
	target_role = null
	using_ability = initial(using_ability)

/**
 * Used to check if this ability can be used on a potential target.
 * Args:
 * game - The Mafia controller that holds reference to the game.
 * potential_target - The player we are attempting to validate the action on.
 * silent - Whether to give feedback to the player about why the action cannot be used.
 */
/datum/mafia_ability/proc/validate_action_target(datum/mafia_controller/game, datum/mafia_role/potential_target, silent = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(game.phase != valid_use_period)
		return FALSE
	if(host_role.role_flags & ROLE_ROLEBLOCKED)
		host_role.send_message_to_player(span_warning("You were roleblocked!"))
		return FALSE
	if(host_role.game_status == MAFIA_DEAD)
		return FALSE

	if(potential_target)
		if(use_flags & CAN_USE_ON_DEAD)
			if(potential_target.game_status != MAFIA_DEAD)
				if(!silent)
					host_role.send_message_to_player(span_notice("This can only be used on dead players."))
				return FALSE
		else if(potential_target.game_status == MAFIA_DEAD)
			if(!silent)
				host_role.send_message_to_player(span_notice("This can only be used on living players."))
			return FALSE
		if(!(use_flags & CAN_USE_ON_SELF) && (potential_target == host_role))
			if(!silent)
				host_role.send_message_to_player(span_notice("This can only be used on others."))
			return FALSE
		if(!(use_flags & CAN_USE_ON_OTHERS) && (potential_target != host_role))
			if(!silent)
				host_role.send_message_to_player(span_notice("This can only be used on yourself."))
			return FALSE
	return TRUE

/**
 * Called when using the ability.
 * Will first check if you are using the ability, then whether you can use it.
 * Finally it will check if you are interrupted, then will pass that you've performed it.
 * Args:
 * game - The Mafia controller that holds reference to the game.
 * day_target - Set when using actions during the day, this is the person that is the target during this phase.
 */
/datum/mafia_ability/proc/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	SHOULD_CALL_PARENT(TRUE)

	if(!using_ability)
		return FALSE
	if(host_role.game_status == MAFIA_DEAD)
		return FALSE
	if(!validate_action_target(game, target_role))
		return FALSE

	if(target_role)
		if(SEND_SIGNAL(target_role, COMSIG_MAFIA_ON_VISIT, game, host_role) & MAFIA_VISIT_INTERRUPTED) //visited a warden. something that prevents you by visiting that person
			host_role.send_message_to_player(span_danger("Your [name] was interrupted!"))
			return FALSE

	return TRUE

/**
 * ##set_target
 *
 * Used for Night abilities ONLY
 * Sets the ability's target, which will cause the action to be performed on them at the end of the night.
 * Subtypes can override this for things like self-abilities (such as shooting visitors).
 */
/datum/mafia_ability/proc/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(!validate_action_target(game, new_target))
		return FALSE

	var/feedback_text = "You will %WILL_PERFORM% [ability_action]%SELF%"
	if(use_flags & CAN_USE_ON_SELF)
		feedback_text = replacetext(feedback_text, "%SELF%", ".")
	else
		feedback_text = replacetext(feedback_text, "%SELF%", " [new_target.body].")

	if(target_role == new_target)
		using_ability = FALSE
		target_role = null
		feedback_text = replacetext(feedback_text, "%WILL_PERFORM%", "not")
	else
		using_ability = TRUE
		target_role = new_target
		feedback_text = replacetext(feedback_text, "%WILL_PERFORM%", "now")

	host_role.send_message_to_player(span_notice(feedback_text))
	return TRUE
