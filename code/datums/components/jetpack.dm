// Welcome to the jetpack component
// Apply this to something when you want it to be "like a jetpack"
// So propulsion through space on move, that sort of thing
/datum/component/jetpack
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/datum/callback/check_on_move
	var/datum/callback/get_mover
	/// If we should stabilize ourselves when not drifting
	var/stabilize = FALSE
	/// The signal we listen for as an activation
	var/activation_signal
	/// The signal we listen for as a de-activation
	var/deactivation_signal
	/// The return flag our parent expects for a failed activation
	var/return_flag
	var/datum/effect_system/trail_follow/trail
	/// The typepath to instansiate our trail as, when we need it
	var/effect_type

/**
 * Arguments:
 * * stabilize - If we should drift when we finish moving, or sit stable in space]
 * * activation_signal - Signal we activate on
 * * deactivation_signal - Signal we deactivate on
 * * return_flag - Flag to return if activation fails
 * * get_mover - Callback we use to get the "moving" thing, for trail purposes, alongside signal registration
 * * check_on_move - Callback we call each time we attempt a move, we expect it to retun true if the move is ok, false otherwise. It expects an arg, TRUE if fuel should be consumed, FALSE othewise
 * * effect_type - Type of trail_follow to spawn
 */
/datum/component/jetpack/Initialize(stabilize, activation_signal, deactivation_signal, return_flag, datum/callback/get_mover, datum/callback/check_on_move, datum/effect_system/trail_follow/effect_type)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(!activation_signal) // Can't activate? go away
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, activation_signal, PROC_REF(activate))
	if(deactivation_signal)
		RegisterSignal(parent, deactivation_signal, PROC_REF(deactivate))

	src.check_on_move = check_on_move
	src.get_mover = get_mover
	src.stabilize = stabilize
	src.return_flag = return_flag
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.effect_type = effect_type

/datum/component/jetpack/InheritComponent(datum/component/component, original, stabilize, activation_signal, deactivation_signal, return_flag, datum/callback/get_mover, datum/callback/check_on_move, datum/effect_system/trail_follow/effect_type)
	UnregisterSignal(parent, src.activation_signal)
	if(src.deactivation_signal)
		UnregisterSignal(parent, src.deactivation_signal)
	RegisterSignal(parent, activation_signal, PROC_REF(activate))
	if(deactivation_signal)
		RegisterSignal(parent, deactivation_signal, PROC_REF(deactivate))

	src.check_on_move = check_on_move
	src.get_mover = get_mover
	src.stabilize = stabilize
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.effect_type = effect_type

	if(trail && effect_type != trail.type)
		QDEL_NULL(trail)
		setup_trail()

/datum/component/jetpack/Destroy()
	QDEL_NULL(trail)
	QDEL_NULL(check_on_move)
	return ..()

/datum/component/jetpack/proc/setup_trail()
	var/mob/moving = get_mover.Invoke()
	if(!moving || trail)
		return
	trail = new effect_type
	trail.auto_process = FALSE
	trail.set_up(moving)

/datum/component/jetpack/proc/activate(datum/source)
	SIGNAL_HANDLER
	var/mob/moving = get_mover.Invoke()
	if(!thrust(moving))
		return return_flag
	trail.start()
	RegisterSignal(moving, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
	RegisterSignal(moving, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_react))
	RegisterSignal(moving, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(spacemove_react))
	RegisterSignal(moving, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT, PROC_REF(block_starting_visuals))
	RegisterSignal(moving, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT, PROC_REF(ignore_ending_block))

/datum/component/jetpack/proc/deactivate(datum/source)
	SIGNAL_HANDLER
	QDEL_NULL(trail)
	var/mob/moving = get_mover.Invoke()
	if(moving)
		UnregisterSignal(moving, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(moving, COMSIG_MOVABLE_PRE_MOVE)
		UnregisterSignal(moving, COMSIG_MOVABLE_SPACEMOVE)
		UnregisterSignal(moving, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT)
		UnregisterSignal(moving, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT)

/datum/component/jetpack/proc/move_react(mob/user)
	SIGNAL_HANDLER
	if(!user || !user.client)//Don't allow jet self using
		return
	if(!isturf(user.loc))//You can't use jet in nowhere or from mecha/closet
		return
	if(!(user.movement_type & FLOATING) || user.buckled)//You don't want use jet in gravity or while buckled.
		return
	if(user.pulledby)//You don't must use jet if someone pull you
		return
	if(user.throwing)//You don't must use jet if you thrown
		return
	if(length(user.client.keys_held & user.client.movement_keys))//You use jet when press keys. yes.
		thrust()

/datum/component/jetpack/proc/pre_move_react(mob/user)
	SIGNAL_HANDLER
	trail.oldposition = get_turf(user)

/datum/component/jetpack/proc/spacemove_react(mob/user, movement_dir, continuous_move)
	SIGNAL_HANDLER
	if(!continuous_move && movement_dir)
		return COMSIG_MOVABLE_STOP_SPACEMOVE
	// Check if we have the fuel to stop this. Do NOT cosume any fuel, just check
	// This is done because things other then us can use our fuel
	if(stabilize && check_on_move.Invoke(FALSE))
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/// Returns true if the thrust went well, false otherwise
/datum/component/jetpack/proc/thrust()
	if(!check_on_move.Invoke(TRUE))
		return FALSE
	if(!trail)
		setup_trail()
	trail.generate_effect()
	return TRUE

/// Basically, tell the drift component not to do its starting visuals, because they look dumb for us
/datum/component/jetpack/proc/block_starting_visuals(datum/source)
	SIGNAL_HANDLER
	return DRIFT_VISUAL_FAILED

/// If we're on, don't let the drift component block movements at the end since we can speed
/datum/component/jetpack/proc/ignore_ending_block(datum/source)
	SIGNAL_HANDLER
	return DRIFT_ALLOW_INPUT
