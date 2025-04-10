//! Defines for subsystems and overlays
//!
//! Lots of important stuff in here, make sure you have your brain switched on
//! when editing this file

//! ## DB defines
/**
 * DB major schema version
 *
 * Update this whenever the db schema changes
 *
 * make sure you add an update to the schema_version stable in the db changelog
 */
#define DB_MAJOR_VERSION 5

/**
 * DB minor schema version
 *
 * Update this whenever the db schema changes
 *
 * make sure you add an update to the schema_version stable in the db changelog
 */
#define DB_MINOR_VERSION 29


//! ## Timing subsystem
/**
 * Don't run if there is an identical unique timer active
 *
 * if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer,
 * and returns the id of the existing timer
 */
#define TIMER_UNIQUE (1<<0)

///For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE (1<<1)

/**
 * Timing should be based on how timing progresses on clients, not the server.
 *
 * Tracking this is more expensive,
 * should only be used in conjunction with things that have to progress client side, such as
 * animate() or sound()
 */
#define TIMER_CLIENT_TIME (1<<2)

///Timer can be stopped using deltimer()
#define TIMER_STOPPABLE (1<<3)

///prevents distinguishing identical timers with the wait variable
///
///To be used with TIMER_UNIQUE
#define TIMER_NO_HASH_WAIT (1<<4)

///Loops the timer repeatedly until qdeleted
///
///In most cases you want a subsystem instead, so don't use this unless you have a good reason
#define TIMER_LOOP (1<<5)

///Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME (1<<6)

///Empty ID define
#define TIMER_ID_NULL -1

/// Used to trigger object removal from a processing list
#define PROCESS_KILL 26


//! ## Initialization subsystem

///New should not call Initialize
#define INITIALIZATION_INSSATOMS 0
///New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_MAPLOAD 2
///New should call Initialize(FALSE)
#define INITIALIZATION_INNEW_REGULAR 1

//! ### Initialization hints

///Nothing happens
#define INITIALIZE_HINT_NORMAL 0
/**
 * call LateInitialize at the end of all atom Initialization
 *
 * The item will be added to the late_loaders list, this is iterated over after
 * initialization of subsystems is complete and calls LateInitalize on the atom
 * see [this file for the LateIntialize proc](atom.html#proc/LateInitialize)
 */
#define INITIALIZE_HINT_LATELOAD 1

///Call qdel on the atom after initialization
#define INITIALIZE_HINT_QDEL 2

///type and all subtypes should always immediately call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(flags_1 & INITIALIZED_1)) {\
		var/previous_initialized_value = SSatoms.initialized;\
		SSatoms.initialized = INITIALIZATION_INNEW_MAPLOAD;\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, FALSE, args);\
		SSatoms.initialized = previous_initialized_value;\
	}\
}

//! ### SS initialization hints
/**
 * Negative values indicate a failure or warning of some kind, positive are good.
 * 0 and 1 are unused so that TRUE and FALSE are guaranteed to be invalid values.
 */

/// Subsystem failed to initialize entirely. Print a warning, log, and disable firing.
#define SS_INIT_FAILURE -2

/// The default return value which must be overridden. Will succeed with a warning.
#define SS_INIT_NONE -1

/// Subsystem initialized successfully.
#define SS_INIT_SUCCESS 2

/// If your system doesn't need to be initialized (by being disabled or something)
#define SS_INIT_NO_NEED 3

/// Successfully initialized, BUT do not announce it to players (generally to hide game mechanics it would otherwise spoil)
#define SS_INIT_NO_MESSAGE 4

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)
#define FIRE_PRIORITY_UNPLANNED_NPC 3
#define FIRE_PRIORITY_IDLE_NPC 5
#define FIRE_PRIORITY_PING 10
#define FIRE_PRIORITY_SERVER_MAINT 10
#define FIRE_PRIORITY_RESEARCH 10
#define FIRE_PRIORITY_VIS 10
#define FIRE_PRIORITY_AMBIENCE 10
#define FIRE_PRIORITY_GARBAGE 15
#define FIRE_PRIORITY_DATABASE 16
#define FIRE_PRIORITY_WET_FLOORS 20
#define FIRE_PRIORITY_AIR 20
#define FIRE_PRIORITY_NPC 20
#define FIRE_PRIORITY_ASSETS 20
#define FIRE_PRIORITY_HYPERSPACE_DRIFT 20
#define FIRE_PRIORITY_NPC_MOVEMENT 21
#define FIRE_PRIORITY_NPC_ACTIONS 22
#define FIRE_PRIORITY_PATHFINDING 23
#define FIRE_PRIORITY_CLIFF_FALLING 24
#define FIRE_PRIORITY_PROCESS 25
#define FIRE_PRIORITY_THROWING 25
#define FIRE_PRIORITY_REAGENTS 26
#define FIRE_PRIORITY_SPACEDRIFT 30
#define FIRE_PRIORITY_SMOOTHING 35
#define FIRE_PRIORITY_OBJ 40
#define FIRE_PRIORITY_ACID 40
#define FIRE_PRIORITY_BURNING 40
#define FIRE_PRIORITY_DEFAULT 50
#define FIRE_PRIORITY_PARALLAX 65
#define FIRE_PRIORITY_INSTRUMENTS 80
#define FIRE_PRIORITY_FLUIDS 80
#define FIRE_PRIORITY_PRIORITY_EFFECTS 90
#define FIRE_PRIORITY_MOBS 100
#define FIRE_PRIORITY_TGUI 110
#define FIRE_PRIORITY_TICKER 200
#define FIRE_PRIORITY_SINGULO 350
#define FIRE_PRIORITY_STATPANEL 390
#define FIRE_PRIORITY_CHAT 400
#define FIRE_PRIORITY_RUNECHAT 410
#define FIRE_PRIORITY_TTS 425
#define FIRE_PRIORITY_MOUSE_ENTERED 450
#define FIRE_PRIORITY_OVERLAYS 500
#define FIRE_PRIORITY_EXPLOSIONS 666
#define FIRE_PRIORITY_TIMER 700
#define FIRE_PRIORITY_SOUND_LOOPS 800
#define FIRE_PRIORITY_SPEECH_CONTROLLER 900
#define FIRE_PRIORITY_DELAYED_VERBS 950
#define FIRE_PRIORITY_INPUT 1000 // This must always always be the max highest priority. Player input must never be lost.


// SS runlevels

#define RUNLEVEL_LOBBY (1<<0)
#define RUNLEVEL_SETUP (1<<1)
#define RUNLEVEL_GAME (1<<2)
#define RUNLEVEL_POSTGAME (1<<3)

#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)

//SSticker.current_state values
/// Game is loading
#define GAME_STATE_STARTUP 0
/// Game is loaded and in pregame lobby
#define GAME_STATE_PREGAME 1
/// Game is attempting to start the round
#define GAME_STATE_SETTING_UP 2
/// Game has round in progress
#define GAME_STATE_PLAYING 3
/// Game has round finished
#define GAME_STATE_FINISHED 4

// Used for SSticker.force_ending
/// Default, round is not being forced to end.
#define END_ROUND_AS_NORMAL 0
/// End the round now as normal
#define FORCE_END_ROUND 1
/// For admin forcing roundend, can be used to distinguish the two
#define ADMIN_FORCE_END_ROUND 2

/**
	Create a new timer and add it to the queue.
	* Arguments:
	* * callback the callback to call on timer finish
	* * wait deciseconds to run the timer for
	* * flags flags for this timer, see: code\__DEFINES\subsystems.dm
	* * timer_subsystem the subsystem to insert this timer into
*/
#define addtimer(args...) _addtimer(args, file = __FILE__, line = __LINE__)

// Air subsystem subtasks
#define SSAIR_PIPENETS 1
#define SSAIR_ATMOSMACHINERY 2
#define SSAIR_ACTIVETURFS 3
#define SSAIR_HOTSPOTS 4
#define SSAIR_EXCITEDGROUPS 5
#define SSAIR_HIGHPRESSURE 6
#define SSAIR_SUPERCONDUCTIVITY 7
#define SSAIR_PROCESS_ATOMS 8

// Pipeline rebuild helper defines, these suck but it'll do for now //Fools you actually merged it
#define SSAIR_REBUILD_PIPELINE 1
#define SSAIR_REBUILD_QUEUE 2

// Explosion Subsystem subtasks
#define SSEXPLOSIONS_TURFS 1
#define SSEXPLOSIONS_MOVABLES 2
#define SSEXPLOSIONS_THROWS 3

// Machines subsystem subtasks.
#define SSMACHINES_MACHINES_EARLY 1
#define SSMACHINES_APCS_EARLY 2
#define SSMACHINES_APCS_ENVIRONMENT 3
#define SSMACHINES_APCS_LIGHTS 4
#define SSMACHINES_APCS_EQUIPMENT 5
#define SSMACHINES_APCS_LATE 6
#define SSMACHINES_MACHINES 7
#define SSMACHINES_MACHINES_LATE 8

// Weather susbsytem tasks
#define SSWEATHER_MOBS 1
#define SSWEATHER_TURFS 2
#define SSWEATHER_THUNDER 3

// Wardrobe subsystem tasks
#define SSWARDROBE_STOCK 1
#define SSWARDROBE_INSPECT 2

// Wardrobe cache metadata indexes
#define WARDROBE_CACHE_COUNT 1
#define WARDROBE_CACHE_LAST_INSPECT 2
#define WARDROBE_CACHE_CALL_INSERT 3
#define WARDROBE_CACHE_CALL_REMOVAL 4

// Wardrobe preloaded stock indexes
#define WARDROBE_STOCK_CONTENTS 1
#define WARDROBE_STOCK_CALL_INSERT 2
#define WARDROBE_STOCK_CALL_REMOVAL 3

// Wardrobe callback master list indexes
#define WARDROBE_CALLBACK_INSERT 1
#define WARDROBE_CALLBACK_REMOVE 2

// Subsystem delta times or tickrates, in seconds. I.e, how many seconds in between each process() call for objects being processed by that subsystem.
// Only use these defines if you want to access some other objects processing seconds_per_tick, otherwise use the seconds_per_tick that is sent as a parameter to process()
#define SSFLUIDS_DT (SSplumbing.wait/10)
#define SSMACHINES_DT (SSmachines.wait/10)
#define SSMOBS_DT (SSmobs.wait/10)
#define SSOBJ_DT (SSobj.wait/10)

// The change in the world's time from the subsystem's last fire in seconds.
#define DELTA_WORLD_TIME(ss) ((world.time - ss.last_fire) * 0.1)

/// The timer key used to know how long subsystem initialization takes
#define SS_INIT_TIMER_KEY "ss_init"

// Vote subsystem counting methods
/// First past the post. One selection per person, and the selection with the most votes wins.
#define VOTE_COUNT_METHOD_SINGLE 1
/// Approval voting. Any number of selections per person, and the selection with the most votes wins.
#define VOTE_COUNT_METHOD_MULTI 2

/// The choice with the most votes wins. Ties are broken by the first choice to reach that number of votes.
#define VOTE_WINNER_METHOD_SIMPLE "Simple"
/// The winning choice is selected randomly based on the number of votes each choice has.
#define VOTE_WINNER_METHOD_WEIGHTED_RANDOM "Weighted Random"
/// There is no winner for this vote.
#define VOTE_WINNER_METHOD_NONE "None"

/// Returned by [/datum/vote/proc/can_be_initiated] to denote the vote is valid and can be initiated.
#define VOTE_AVAILABLE "Vote Available"
