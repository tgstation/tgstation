// Welcome to the jetpack component
// Apply this to something when you want it to be "like a jetpack"
// So propulsion through space on move, that sort of thing
/datum/component/jetpack
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Checks to ensure if we can move
	var/datum/callback/check_on_move
	/// Checks to ensure we can activate
	var/datum/callback/check_on_activation
	/// If we should stabilize ourselves when not drifting
	var/stabilize = FALSE
	/// The signal we listen for as an activation
	var/activation_signal
	/// The signal we listen for as a de-activation
	var/deactivation_signal
	/// The return flag our parent expects for a failed activation
	var/return_flag
	/// The effect system for the jet pack trail
	var/datum/effect_system/trail_follow/trail
	/// The typepath to instansiate our trail as, when we need it
	var/effect_type
	/// Drift force applied each movement tick
	var/drift_force

	VAR_PRIVATE/active = FALSE

/**
 * Arguments:
 * * stabilize - If we should drift when we finish moving, or sit stable in space]
 * * drift_force - How much force is applied whenever the user tries to move, applied as a multiplier to the user's inertia_move_multiplier.
 * * activation_signal - Signal we activate on
 * * deactivation_signal - Signal we deactivate on
 * * return_flag - Flag to return if activation fails
 * * check_on_move - Callback we call each time we attempt a move, we expect it to retun true if the move is ok, false otherwise. It expects an arg, TRUE if fuel should be consumed, FALSE othewise
 * * effect_type - Type of trail_follow to spawn
 */
/datum/component/jetpack/Initialize(
	stabilize = FALSE,
	drift_force = 1 NEWTONS,
	activation_signal,
	deactivation_signal,
	return_flag,
	datum/callback/check_on_move,
	datum/callback/check_on_activation,
	datum/effect_system/trail_follow/effect_type,
)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(!activation_signal) // Can't activate? go away
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, activation_signal, PROC_REF(activate))
	if(deactivation_signal)
		RegisterSignal(parent, deactivation_signal, PROC_REF(deactivate))

	src.stabilize = stabilize
	src.check_on_move = check_on_move
	src.check_on_activation = check_on_activation
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.return_flag = return_flag
	src.effect_type = effect_type
	src.drift_force = drift_force

/datum/component/jetpack/InheritComponent(datum/component/component, original, stabilize, drift_force = 1 NEWTONS, activation_signal, deactivation_signal, return_flag, datum/callback/check_on_move, datum/callback/check_on_activation, datum/effect_system/trail_follow/effect_type)
	UnregisterSignal(parent, src.activation_signal)
	if(src.deactivation_signal)
		UnregisterSignal(parent, src.deactivation_signal)
	RegisterSignal(parent, activation_signal, PROC_REF(activate))
	if(deactivation_signal)
		RegisterSignal(parent, deactivation_signal, PROC_REF(deactivate))

	src.stabilize = stabilize
	src.check_on_move = check_on_move
	src.check_on_activation = check_on_activation
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.return_flag = return_flag
	src.effect_type = effect_type
	src.drift_force = drift_force

	if(trail && trail.effect_type != effect_type)
		setup_trail(trail.holder)

/datum/component/jetpack/Destroy(force)
	QDEL_NULL(trail)
	check_on_move = null
	check_on_activation = null
	return ..()

/datum/component/jetpack/proc/setup_trail(mob/user)
	QDEL_NULL(trail)
	trail = new effect_type(user)
	trail.auto_process = FALSE
	trail.start()

/datum/component/jetpack/proc/activate(datum/source, mob/new_user)
	SIGNAL_HANDLER

	if(!isnull(check_on_activation) && !check_on_activation.Invoke())
		return return_flag

	active = TRUE
	RegisterSignal(new_user, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
	RegisterSignal(new_user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_react))
	RegisterSignal(new_user, COMSIG_MOB_ATTEMPT_HALT_SPACEMOVE, PROC_REF(on_pushoff))
	RegisterSignal(new_user, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT, PROC_REF(on_input_block))
	RegisterSignal(new_user, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(stabilize))
	if (effect_type)
		setup_trail(new_user)
	new_user.inertia_move_multiplier /= drift_force // lower multiplier = faster drifting

/datum/component/jetpack/proc/deactivate(datum/source, mob/old_user)
	SIGNAL_HANDLER

	if(!active)
		return

	active = FALSE
	UnregisterSignal(old_user, list(
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_ATTEMPT_HALT_SPACEMOVE,
		COMSIG_MOVABLE_DRIFT_BLOCK_INPUT,
		COMSIG_MOVABLE_SPACEMOVE,
	))
	QDEL_NULL(trail)
	old_user.inertia_move_multiplier *= drift_force

/datum/component/jetpack/proc/move_react(mob/source)
	SIGNAL_HANDLER
	if (!should_trigger(source))
		return

	if(source.client.intended_direction && check_on_move.Invoke(TRUE)) //You use jet when press keys. yes.
		trail?.generate_effect()

/datum/component/jetpack/proc/stabilize(mob/source, movement_dir, continuous_move, backup)
	SIGNAL_HANDLER
	if(!continuous_move && movement_dir)
		return COMSIG_MOVABLE_STOP_SPACEMOVE
	// Check if we have the fuel to stop this. Do NOT consume any fuel, just check
	// This is done because things other then us can use our fuel
	if(stabilize && check_on_move.Invoke(FALSE))
		return COMSIG_MOVABLE_STOP_SPACEMOVE
	return NONE

/datum/component/jetpack/proc/should_trigger(mob/source)
	if(!source || !source.client)//Don't allow jet self using
		return FALSE
	if(!isturf(source.loc))//You can't use jet in nowhere or from mecha/closet
		return FALSE
	if(!(source.movement_type & FLOATING) || source.buckled)//You don't want use jet in gravity or while buckled.
		return FALSE
	if(source.pulledby)//You don't must use jet if someone pull you
		return FALSE
	if(source.throwing)//You don't must use jet if you thrown
		return FALSE
	return TRUE

/datum/component/jetpack/proc/pre_move_react(mob/source)
	SIGNAL_HANDLER
	trail?.oldposition = get_turf(source)

/datum/component/jetpack/proc/on_input_block(mob/source)
	SIGNAL_HANDLER

	if (!should_trigger(source))
		return NONE

	if (!check_on_move.Invoke(TRUE))
		return NONE

	return DRIFT_ALLOW_INPUT

/datum/component/jetpack/proc/on_pushoff(mob/source, movement_dir, continuous_move, atom/backup)
	SIGNAL_HANDLER

	if (get_dir(source, backup) == movement_dir || source.loc == backup.loc)
		return NONE

	if (!source.client?.intended_direction || source.client.intended_direction == get_dir(source, backup))
		return NONE

	if (isnull(source.drift_handler))
		return NONE

	if (!should_trigger(source) || !check_on_move.Invoke(FALSE))
		return NONE

	return COMPONENT_PREVENT_SPACEMOVE_HALT
