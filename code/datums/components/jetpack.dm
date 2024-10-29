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
	/// The return flag our parent expects for a failed activation
	var/return_flag
	/// The effect system for the jet pack trail
	var/datum/effect_system/trail_follow/trail
	/// The typepath to instansiate our trail as, when we need it
	var/effect_type
	/// Drift force applied each movement tick
	var/drift_force
	/// Force that applied when stabiliziation is active and the player isn't moving in the same direction as the jetpack
	var/stabilization_force
	/// Our current user
	var/mob/user

/**
 * Arguments:
 * * stabilize - If we should drift when we finish moving, or sit stable in space]
 * * drift_force - How much force is applied whenever the user tries to move
 * * stabilization_force - How much force is applied per tick when we try to stabilize the user
 * * activation_signal - Signal we activate on
 * * deactivation_signal - Signal we deactivate on
 * * return_flag - Flag to return if activation fails
 * * check_on_move - Callback we call each time we attempt a move, we expect it to retun true if the move is ok, false otherwise. It expects an arg, TRUE if fuel should be consumed, FALSE othewise
 * * effect_type - Type of trail_follow to spawn
 */
/datum/component/jetpack/Initialize(stabilize, drift_force = 1 NEWTONS, stabilization_force = 1 NEWTONS, activation_signal, deactivation_signal, return_flag, datum/callback/check_on_move, datum/effect_system/trail_follow/effect_type)
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
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.return_flag = return_flag
	src.effect_type = effect_type
	src.drift_force = drift_force
	src.stabilization_force = stabilization_force

/datum/component/jetpack/InheritComponent(datum/component/component, original, stabilize, drift_force = 1 NEWTONS, stabilization_force = 1 NEWTONS, activation_signal, deactivation_signal, return_flag, datum/callback/check_on_move, datum/effect_system/trail_follow/effect_type)
	UnregisterSignal(parent, src.activation_signal)
	if(src.deactivation_signal)
		UnregisterSignal(parent, src.deactivation_signal)
	RegisterSignal(parent, activation_signal, PROC_REF(activate))
	if(deactivation_signal)
		RegisterSignal(parent, deactivation_signal, PROC_REF(deactivate))

	src.stabilize = stabilize
	src.check_on_move = check_on_move
	src.activation_signal = activation_signal
	src.deactivation_signal = deactivation_signal
	src.return_flag = return_flag
	src.effect_type = effect_type
	src.drift_force = drift_force
	src.stabilization_force = stabilization_force

	if(trail && trail.effect_type != effect_type)
		setup_trail(trail.holder)

/datum/component/jetpack/Destroy(force)
	if(trail)
		QDEL_NULL(trail)
	user = null
	check_on_move = null
	return ..()

/datum/component/jetpack/proc/setup_trail(mob/user)
	if(trail)
		QDEL_NULL(trail)
	trail = new effect_type
	trail.auto_process = FALSE
	trail.set_up(user)
	trail.start()

/datum/component/jetpack/proc/activate(datum/source, mob/new_user)
	SIGNAL_HANDLER

	if(!check_on_move.Invoke(TRUE))
		return return_flag

	user = new_user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move_react))
	RegisterSignal(user, COMSIG_MOB_CLIENT_MOVE_NOGRAV, PROC_REF(on_client_move))
	RegisterSignal(user, COMSIG_MOB_ATTEMPT_HALT_SPACEMOVE, PROC_REF(on_pushoff))
	START_PROCESSING(SSnewtonian_movement, src)
	setup_trail(user)

/datum/component/jetpack/proc/deactivate(datum/source, mob/old_user)
	SIGNAL_HANDLER

	UnregisterSignal(old_user, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_MOB_CLIENT_MOVE_NOGRAV, COMSIG_MOB_ATTEMPT_HALT_SPACEMOVE))
	STOP_PROCESSING(SSnewtonian_movement, src)
	user = null

	if(trail)
		QDEL_NULL(trail)

/datum/component/jetpack/proc/move_react(mob/source)
	SIGNAL_HANDLER
	if (!should_trigger(source))
		return

	if(source.client.intended_direction && check_on_move.Invoke(FALSE))//You use jet when press keys. yes.
		trail.generate_effect()

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
	if(!trail)
		return FALSE
	trail.oldposition = get_turf(source)

/datum/component/jetpack/process(seconds_per_tick)
	if (!should_trigger(user) || !stabilize || isnull(user.drift_handler))
		return

	var/max_drift_force = (DEFAULT_INERTIA_SPEED / user.cached_multiplicative_slowdown - 1) / INERTIA_SPEED_COEF + 1
	user.drift_handler.stabilize_drift(user.client.intended_direction ? dir2angle(user.client.intended_direction) : null, user.client.intended_direction ? max_drift_force : 0, stabilization_force * (seconds_per_tick * 1 SECONDS))

/datum/component/jetpack/proc/on_client_move(mob/source, list/move_args)
	SIGNAL_HANDLER

	if (!should_trigger(source))
		return

	if (!check_on_move.Invoke(TRUE))
		return

	var/max_drift_force = (DEFAULT_INERTIA_SPEED / source.cached_multiplicative_slowdown - 1) / INERTIA_SPEED_COEF + 1
	source.newtonian_move(dir2angle(source.client.intended_direction), instant = TRUE, drift_force = drift_force, controlled_cap = max_drift_force)
	source.setDir(source.client.intended_direction)

/datum/component/jetpack/proc/on_pushoff(mob/source, movement_dir, continuous_move, atom/backup)
	SIGNAL_HANDLER

	if (!should_trigger(source) || !check_on_move.Invoke(FALSE))
		return

	return COMPONENT_PREVENT_SPACEMOVE_HALT
