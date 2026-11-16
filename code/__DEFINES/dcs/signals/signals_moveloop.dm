///from [/datum/move_loop/start_loop] ():
#define COMSIG_MOVELOOP_START "moveloop_start"
///from [/datum/move_loop/stop_loop] ():
#define COMSIG_MOVELOOP_STOP "moveloop_stop"
///from [/datum/move_loop/process] ():
#define COMSIG_MOVELOOP_PREPROCESS_CHECK "moveloop_preprocess_check"
	#define MOVELOOP_SKIP_STEP (1<<0)
///from [/datum/move_loop/process] (result, visual_delay): //Result is an enum value. Enums defined in __DEFINES/movement.dm
#define COMSIG_MOVELOOP_POSTPROCESS "moveloop_postprocess"
///from [/datum/move_loop/has_target/navmap_astar/recalculate_path] ():
#define COMSIG_MOVELOOP_NAVMAP_REPATH "moveloop_navmap_repath"
///from [/datum/move_loop/has_target/navmap_astar/on_finish_pathing]
#define COMSIG_MOVELOOP_NAVMAP_FINISHED_PATHING "moveloop_navmap_finished_pathing"
///from [/datum/move_loop/has_target/navmap_astar/frustrations/handle_move_attempt_failure]
#define COMSIG_MOVELOOP_NAVMAP_FRUSTRATION_INCREMENTED "moveloop_navmap_frustration_incremented"
