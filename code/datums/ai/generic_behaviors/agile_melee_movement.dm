/// Not moving under our own direction yet.
#define AGILE_MELEE_MODE_NONE 0
/// Beelining into melee range, min distance 1.
#define AGILE_MELEE_MODE_CLOSING 1
/// Backstepping out of melee range, min distance 0.
#define AGILE_MELEE_MODE_RETREATING 2
/// Shuffling around inside the standoff band, min distance 0.
#define AGILE_MELEE_MODE_JITTERING 3
/// Standing still for a beat after landing a hit.
#define AGILE_MELEE_MODE_HOLDING 4

///Yakety sax type melee movement; If you can attack (next_move off cooldown), then get in range, otherwise, move inbetween standdoff_min and max, if within the band; randomly jitter in the band.
/datum/bt_node/ai_behavior/agile_melee_movement
	/// Blackboard key holding the atom to fight.
	var/target_key
	/// Distance we back off to once we've swung.
	var/standoff_min = 2
	/// Distance past which we close in again even while on cooldown, so we never lose the target.
	var/standoff_max = 3
	/// Percent chance per tick to take another step while loitering inside the standoff band.
	var/jitter_chance = 100
	/// time to stay planted until after a hit. Makes it a bit more fair to fight against.
	var/wait_after_attack = 0.3 SECONDS
	/// Set by on_movement_failed() when the movement system gives up pathing.
	VAR_FINAL/movement_failed = FALSE
	/// Which AGILE_MELEE_MODE_ we drove movement with last tick, so we only tear the moveloop down when it flips.
	VAR_PRIVATE/current_mode = AGILE_MELEE_MODE_NONE
	/// Last next_move we saw on the pawn. A jump means a hit landed, which is what starts the post attack pause.
	VAR_PRIVATE/last_next_move = 0
	/// When we can move post attack
	VAR_PRIVATE/hold_until = 0

/datum/bt_node/ai_behavior/agile_melee_movement/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(isliving(controller.pawn))
		var/mob/living/living_pawn = controller.pawn
		last_next_move = living_pawn.next_move
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	return TRUE

/datum/bt_node/ai_behavior/agile_melee_movement/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/agile_melee_movement/perform(seconds_per_tick, datum/ai_controller/controller)
	if(movement_failed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/pawn = controller.pawn
	var/distance = get_dist(pawn, target)

	if(wait_after_attack && isliving(pawn))
		var/mob/living/living_pawn = pawn
		if(living_pawn.next_move > last_next_move)
			hold_until = world.time + wait_after_attack
		last_next_move = living_pawn.next_move

	if(hold_until > world.time)
		set_movement_mode(controller, AGILE_MELEE_MODE_HOLDING, initial(controller.ai_movement))
		return AI_BEHAVIOR_INSTANT

	if(can_swing(pawn) || distance > standoff_max)
		close_in(controller, target)
		return AI_BEHAVIOR_INSTANT

	if(distance < standoff_min)
		retreat(controller, target)
		return AI_BEHAVIOR_INSTANT

	jitter(controller, target)
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/agile_melee_movement/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	current_mode = AGILE_MELEE_MODE_NONE
	last_next_move = 0
	hold_until = 0
	controller.ai_movement.stop_moving_towards(controller)
	controller.change_ai_movement_type(initial(controller.ai_movement))
	return ..()

/// Whether our melee attack is off cooldown, meaning it's worth being adjacent right now.
/datum/bt_node/ai_behavior/agile_melee_movement/proc/can_swing(mob/pawn)
	if(!isliving(pawn))
		return TRUE
	var/mob/living/living_pawn = pawn
	return world.time >= living_pawn.next_move


///Switches which mode is driving our movement, tearing the current moveloop down first.
/datum/bt_node/ai_behavior/agile_melee_movement/proc/set_movement_mode(datum/ai_controller/controller, mode, datum/ai_movement/movement_type)
	if(mode == current_mode)
		return
	controller.ai_movement.stop_moving_towards(controller)
	controller.change_ai_movement_type(movement_type)
	current_mode = mode

/// Beelines into melee range. Retargeting to a new target is handled inside start_moving_towards().
/datum/bt_node/ai_behavior/agile_melee_movement/proc/close_in(datum/ai_controller/controller, atom/target)
	set_movement_mode(controller, AGILE_MELEE_MODE_CLOSING, initial(controller.ai_movement))
	controller.ai_movement.start_moving_towards(controller, target, 1)

/// Steps one tile away from target using backstep avoidance, falling back to shuffled directions if blocked.
/datum/bt_node/ai_behavior/agile_melee_movement/proc/retreat(datum/ai_controller/controller, atom/target)
	set_movement_mode(controller, AGILE_MELEE_MODE_RETREATING, /datum/ai_movement/basic_avoidance/backstep)
	var/mob/pawn = controller.pawn
	pawn.face_atom(target)
	var/turf/next_step = get_step_away(pawn, target)
	if(!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
		controller.ai_movement.start_moving_towards(controller, next_step, 0, controller.movement_delay)
		return TRUE
	var/list/all_dirs = GLOB.alldirs.Copy()
	all_dirs -= get_dir(pawn, next_step)
	all_dirs -= get_dir(pawn, target)
	shuffle_inplace(all_dirs)
	for(var/dir in all_dirs)
		next_step = get_step(pawn, dir)
		if(!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
			controller.ai_movement.start_moving_towards(controller, next_step, 0, controller.movement_delay)
			return TRUE
	return FALSE

/// Takes one step to a random adjacent turf, anywhere that keeps us inside the standoff band.
/datum/bt_node/ai_behavior/agile_melee_movement/proc/jitter(datum/ai_controller/controller, atom/target)
	if(!prob(jitter_chance))
		return

	var/mob/pawn = controller.pawn
	var/list/candidates = list()
	for(var/direction in GLOB.alldirs)
		var/turf/step_turf = get_step(pawn, direction)
		if(isnull(step_turf) || step_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		var/step_distance = get_dist(step_turf, target)
		if(step_distance < standoff_min || step_distance > standoff_max)
			continue
		candidates += step_turf

	if(!length(candidates))
		return

	set_movement_mode(controller, AGILE_MELEE_MODE_JITTERING, initial(controller.ai_movement))
	pawn.face_atom(target)
	controller.ai_movement.start_moving_towards(controller, pick(candidates), 0, controller.movement_delay)

#undef AGILE_MELEE_MODE_NONE
#undef AGILE_MELEE_MODE_CLOSING
#undef AGILE_MELEE_MODE_RETREATING
#undef AGILE_MELEE_MODE_JITTERING
#undef AGILE_MELEE_MODE_HOLDING
