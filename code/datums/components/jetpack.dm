// Welcome to the jetpack component
// Apply this to something when you want it to be "like a jetpack"
// So propulsion through space on move, that sort of thing
/datum/component/jetpack
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Checks to ensure if we can move & if we can activate
	var/datum/callback/check_on_move
	/// If we should stabilize ourselves when not drifting
	var/stabilize = FALSE
	/// The signal we listen for as an activation
	var/activation_signal
	/// The signal we listen for as a de-activation
	var/deactivation_signal
	/// The effect system for the jet pack trail
	var/datum/effect_system/trail_follow/trail
	/// The typepath to instansiate our trail as, when we need it
	var/effect_type

/**
 * Arguments:
 * * stabilize - If we should drift when we finish moving, or sit stable in space]
 * * activation_signal - Signal we activate on
 * * deactivation_signal - Signal we deactivate on
 * * check_on_move - Callback we call each time we attempt a move, we expect it to retun true if the move is ok, false otherwise. It expects an arg, TRUE if fuel should be consumed, FALSE othewise
 * * effect_type - Type of trail_follow to spawn
 */
/datum/component/jetpack/Initialize(activation_signal, deactivation_signal, datum/callback/check_on_move, datum/effect_system/trail_follow/effect_type)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(!activation_signal) // Can't activate? go away
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, activation_signal, PROC_REF(activate))
	if(deactivation_signal)
		RegisterSignal(parent, deactivation_signal, PROC_REF(deactivate))

	src.check_on_move = check_on_move
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.effect_type = effect_type

/datum/component/jetpack/Destroy()
	QDEL_NULL(trail)
	QDEL_NULL(check_on_move)
	return ..()

/datum/component/jetpack/proc/activate(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!check_on_move.Invoke(TRUE))
		return JETPACK_COMPONENT_ACTIVATION_FAILED

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_react))
	RegisterSignal(user, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(spacemove_react))
	RegisterSignal(user, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT, PROC_REF(block_starting_visuals))
	RegisterSignal(user, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT, PROC_REF(ignore_ending_block))

	if(trail && effect_type != trail.type)
		QDEL_NULL(trail)
	trail = new effect_type
	trail.auto_process = FALSE
	trail.set_up(user)
	trail.start()

/datum/component/jetpack/proc/deactivate(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(user, COMSIG_MOVABLE_SPACEMOVE)
	UnregisterSignal(user, COMSIG_MOVABLE_DRIFT_VISUAL_ATTEMPT)
	UnregisterSignal(user, COMSIG_MOVABLE_DRIFT_BLOCK_INPUT)

	QDEL_NULL(trail)

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
	if(!trail)
		return FALSE
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
