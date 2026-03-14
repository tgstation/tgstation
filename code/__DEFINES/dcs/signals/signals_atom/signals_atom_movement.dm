// Atom movement signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///signal sent out by an atom when it checks if it can be pulled, for additional checks
#define COMSIG_ATOM_CAN_BE_PULLED "movable_can_be_pulled"
	#define COMSIG_ATOM_CANT_PULL (1 << 0)
///signal sent out by an atom when it is no longer being pulled by something else : (atom/puller)
#define COMSIG_ATOM_NO_LONGER_PULLED "movable_no_longer_pulled"
///signal sent out by an atom when it is no longer pulling something : (atom/pulling)
#define COMSIG_ATOM_NO_LONGER_PULLING "movable_no_longer_pulling"
///called for each movable in a turf contents on /turf/zImpact(): (atom/movable/A, levels)
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"
///signal sent out by an atom upon onZImpact : (turf/impacted_turf, levels)
#define COMSIG_ATOM_ON_Z_IMPACT "movable_on_z_impact"
/// From base of /atom/movable/beforeShuttleMove (turf/newT, direction, move_mode, /obj/docking_port/mobile/moving_dock)
#define COMSIG_ATOM_BEFORE_SHUTTLE_MOVE "movable_before_shuttle_move"
	// Docking turf movement return values - return a combination of these to override the move_mode for the turf containing the atom
	#define COMPONENT_MOVE_TURF MOVE_TURF
	#define COMPONENT_MOVE_AREA MOVE_AREA
	#define COMPONENT_MOVE_CONTENTS MOVE_CONTENTS
/// From base of /atom/movable/afterShuttleMove (turf/oldT)
#define COMSIG_ATOM_AFTER_SHUTTLE_MOVE "movable_after_shuttle_move"
///called on a movable (NOT living) when it starts pulling (atom/movable/pulled, state, force)
#define COMSIG_ATOM_START_PULL "movable_start_pull"
/// called on /atom when something attempts to pass through it (atom/movable/source, atom/movable/passing, dir)
#define COMSIG_ATOM_TRIED_PASS "atom_tried_pass"
/// called on /movable when something attempts to pass through it (atom/movable/source, atom/movable/passing, dir) AND WHEN general_movement = FALSE for some fucking reason
#define COMSIG_MOVABLE_CAN_PASS_THROUGH "movable_can_pass_through"
/// If given, we permit passage through
#define COMSIG_COMPONENT_PERMIT_PASSAGE (1 << 0)
/// If given, we DONT permit passage through
#define COMSIG_COMPONENT_REFUSE_PASSAGE (1 << 1)
///called on /living when someone starts pulling (atom/movable/pulled, state, force)
#define COMSIG_LIVING_START_PULL "living_start_pull"
///called on /living when someone is pulled (mob/living/puller)
#define COMSIG_LIVING_GET_PULLED "living_start_pulled"
///called on /living, when pull is attempted, but before it completes, from base of [/mob/living/start_pulling]: (atom/movable/thing, force)
#define COMSIG_LIVING_TRY_PULL "living_try_pull"
	#define COMSIG_LIVING_CANCEL_PULL (1 << 0)
#define COMSIG_LIVING_TRYING_TO_PULL "living_tried_pulling"
/// Called from /mob/living/update_pull_movespeed
#define COMSIG_LIVING_UPDATING_PULL_MOVESPEED "living_updating_pull_movespeed"
/// Called from /mob/living/PushAM -- Called when this mob is about to push a movable, but before it moves
/// (aotm/movable/being_pushed)
#define COMSIG_LIVING_PUSHING_MOVABLE "living_pushing_movable"
///from base of [/atom/proc/interact]: (mob/user)
#define COMSIG_ATOM_UI_INTERACT "atom_ui_interact"
///from base of atom/relaymove(): (mob/living/user, direction)
#define COMSIG_ATOM_RELAYMOVE "atom_relaymove"
	///prevents the "you cannot move while buckled! message"
	#define COMSIG_BLOCK_RELAYMOVE (1<<0)

/// From base of atom/setDir(): (old_dir, new_dir). Called before the direction changes
#define COMSIG_ATOM_PRE_DIR_CHANGE "atom_pre_face_atom"
	#define COMPONENT_ATOM_BLOCK_DIR_CHANGE (1<<0)
///from base of atom/setDir(): (old_dir, new_dir). Called before the direction changes.
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
///from base of atom/setDir(): (old_dir, new_dir). Called after the direction changes.
#define COMSIG_ATOM_POST_DIR_CHANGE "atom_post_dir_change"
///from base of atom/movable/keybind_face_direction(): (dir). Called before turning with the movement lock key.
#define COMSIG_MOVABLE_KEYBIND_FACE_DIR "keybind_face_dir"
	///ignores the movement lock key, used for turning while strafing in a mech
	#define COMSIG_IGNORE_MOVEMENT_LOCK (1<<0)

/// from /datum/component/singularity/proc/can_move(), as well as /obj/energy_ball/proc/can_move()
/// if a callback returns `SINGULARITY_TRY_MOVE_BLOCK`, then the singularity will not move to that turf
#define COMSIG_ATOM_SINGULARITY_TRY_MOVE "atom_singularity_try_move"
	/// When returned from `COMSIG_ATOM_SINGULARITY_TRY_MOVE`, the singularity will move to that turf
	#define SINGULARITY_TRY_MOVE_BLOCK (1 << 0)
///from base of atom/experience_pressure_difference(): (pressure_difference, direction, pressure_resistance_prob_delta)
#define COMSIG_ATOM_PRE_PRESSURE_PUSH "atom_pre_pressure_push"
	///prevents pressure movement
	#define COMSIG_ATOM_BLOCKS_PRESSURE (1<<0)
///From base of /datum/move_loop/process() after attempting to move a movable: (datum/move_loop/loop, old_dir)
#define COMSIG_MOVABLE_MOVED_FROM_LOOP "movable_moved_from_loop"
