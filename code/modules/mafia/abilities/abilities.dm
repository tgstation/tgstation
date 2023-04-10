/datum/mafia_ability
	var/name = "Mafia Ability"
	var/ability_action = "brutally murder"

	///The priority level this action must be sent at.
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
		RegisterSignal(game, action_priority, PROC_REF(perform_action))

/datum/mafia_ability/Destroy(force, ...)
	. = ..()
	host_role = null
	target_role = null

/**
 * Called when attempting to use the ability.
 * All abilities are called at the end of each phase, and this is called when performing the action.
 * Args:
 * game - The Mafia controller that holds reference to the game.
 * potential_target - Used to see if the player can be targeted, this does not make them the target. You should probably not be touching this.
 * silent - Won't tell the player why it failed.
 */
/datum/mafia_ability/proc/validate_action_target(datum/mafia_controller/game, datum/mafia_role/potential_target, silent = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(game.phase != valid_use_period)
		return FALSE
	if(host_role.role_flags & ROLE_ROLEBLOCKED)
		if(!silent)
			to_chat(host_role.body, span_warning("You were roleblocked!"))
		return FALSE
	if(potential_target)
		if((use_flags & CAN_USE_ON_DEAD) && (potential_target.game_status == MAFIA_DEAD))
			return TRUE
		if(!(use_flags & CAN_USE_ON_SELF) && (potential_target == host_role))
			return FALSE
		if(!(use_flags & CAN_USE_ON_OTHERS) && (potential_target != host_role))
			return FALSE
	if(target_role)
		if(SEND_SIGNAL(target_role, COMSIG_MAFIA_ON_VISIT, game, host_role) & MAFIA_VISIT_INTERRUPTED) //visited a warden. something that prevents you by visiting that person
			if(!silent)
				to_chat(host_role.body, span_danger("Your [name] was interrupted!"))
			return FALSE
	return TRUE

/**
 * Called when using the ability
 * Unsets the target, so it's meant to be called at the end.
 * Args:
 * game - The Mafia controller that holds reference to the game.
 * day_target - Only set on Day abilities, this is the role the action is being performed on.
 */
/datum/mafia_ability/proc/perform_action(datum/mafia_controller/game, datum/mafia_role/day_target)
	SHOULD_CALL_PARENT(TRUE)
	target_role = null
	using_ability = initial(using_ability)

/**
 * set_target
 *
 * Used for Night abilities ONLY
 * Sets the ability's target, which will cause the action to be performed on them at the end of the night.
 * Subtypes can override this for things like self-abilities (such as shooting visitors).
 */
/datum/mafia_ability/proc/set_target(datum/mafia_controller/game, datum/mafia_role/new_target)
	if(!(use_flags & CAN_USE_ON_DEAD))
		if(!(use_flags & CAN_USE_ON_SELF) && (target_role == host_role))
			to_chat(host_role.body, span_notice("This can only be used on others."))
			return FALSE
		if(!(use_flags & CAN_USE_ON_OTHERS) && (target_role != host_role))
			to_chat(host_role.body, span_notice("This can only be used on yourself."))
			return FALSE
	if(target_role == new_target)
		target_role = null
		using_ability = FALSE
		to_chat(host_role.body, span_notice("You will not [ability_action] [new_target.body]."))
		return
	using_ability = TRUE
	target_role = new_target
	to_chat(host_role.body, span_notice("You will now [ability_action] [target_role.body]."))
