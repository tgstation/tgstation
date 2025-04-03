//#define TESTING //By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

//#define DATUMVAR_DEBUGGING_MODE //Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

// Comment this out if you are debugging problems that might be obscured by custom error handling in world/Error
#ifdef DEBUG
#define USE_CUSTOM_ERROR_HANDLER
#endif

#if defined(OPENDREAM) && !defined(SPACEMAN_DMM) && !defined(CIBUILDING)
// The code is being compiled for OpenDream, and not just for the CI linting.
#define OPENDREAM_REAL
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

/// Enables update_appearance "relevence" tracking
/// This allows us to check which update_appearance procs are actually doing anything. Good thing to look in on once a year or so
/// You'll need to run a two regexes/search and replaces to make it work
/// First, one to convert type refs (PROC_REF.*)(update_appearance\)) -> $1_$2
/// Second, one to convert definitions /update_appearance\( -> /_update_appearance(
/// We'll use another define to convert uses of the proc over. That'll be all
// #define APPEARANCE_SUCCESS_TRACKING

///Used to find the sources of harddels, quite laggy, don't be surprised if it freezes your client for a good while
//#define REFERENCE_TRACKING
#ifdef REFERENCE_TRACKING

///Used for doing dry runs of the reference finder, to test for feature completeness
///Slightly slower, higher in memory. Just not optimal
//#define REFERENCE_TRACKING_DEBUG

///Run a lookup on things hard deleting by default.
//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
///Don't stop when searching, go till you're totally done
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

// Log references in their own file, rather then in runtimes.log
//#define REFERENCE_TRACKING_LOG_APART
#endif //ifdef REFERENCE_TRACKING

/*
* Enables debug messages for every single reaction step. This is 1 message per 0.5s for a SINGLE reaction. Useful for tracking down bugs/asking me for help in the main reaction handiler (equilibrium.dm).
*
* * Requires TESTING to be defined to work.
*/
//#define REAGENTS_TESTING

// Displays static object lighting updates
// Also enables some debug vars on sslighting that can be used to modify
// How extensively we prune lighting corners to update
#define VISUALIZE_LIGHT_UPDATES

#define VISUALIZE_ACTIVE_TURFS //Highlights atmos active turfs in green
#define TRACK_MAX_SHARE //Allows max share tracking, for use in the atmos debugging ui
#endif //ifdef TESTING

/// If this is uncommented, we set up the ref tracker to be used in a live environment
/// And to log events to [log_dir]/harddels.log
//#define REFERENCE_DOING_IT_LIVE
#ifdef REFERENCE_DOING_IT_LIVE
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
// Log references in their own file
#define REFERENCE_TRACKING_LOG_APART
#endif // REFERENCE_DOING_IT_LIVE

/// Sets up the reftracker to be used locally, to hunt for hard deletions
/// Errors are logged to [log_dir]/harddels.log
//#define REFERENCE_TRACKING_STANDARD
#ifdef REFERENCE_TRACKING_STANDARD
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
// spend ALL our time searching, not just part of it
#define FIND_REF_NO_CHECK_TICK
// Log references in their own file
#define REFERENCE_TRACKING_LOG_APART
#endif // REFERENCE_TRACKING_STANDARD

// If this is uncommented, we do a single run though of the game setup and tear down process with unit tests in between
//#define UNIT_TESTS

// If this is uncommented, will attempt to load and initialize prof.dll/libprof.so by default.
// Even if it's not defined, you can pass "tracy" via -params in order to try to load it.
// We do not ship byond-tracy. Build it yourself here: https://github.com/mafemergency/byond-tracy,
// or the fork which writes profiling data to a file: https://github.com/ParadiseSS13/byond-tracy
// #define USE_BYOND_TRACY

// If uncommented, will display info about byond-tracy's status in the MC tab.
// #define MC_TAB_TRACY_INFO

// If defined, we will compile with FULL timer debug info, rather then a limited scope
// Be warned, this increases timer creation cost by 5x
// #define TIMER_DEBUG

// If defined, we will NOT defer asset generation till later in the game, and will instead do it all at once, during initiialize
//#define DO_NOT_DEFER_ASSETS

/// If this is uncommented, Autowiki will generate edits and shut down the server.
/// Prefer the autowiki build target instead.
// #define AUTOWIKI

/// If this is uncommented, will profile mapload atom initializations
// #define PROFILE_MAPLOAD_INIT_ATOM

/// If uncommented, Dreamluau will be fully disabled.
// #define DISABLE_DREAMLUAU

// OpenDream currently doesn't support byondapi, so automatically disable it on OD,
// unless CIBUILDING is defined - we still want to lint dreamluau-related code.
// Get rid of this whenever it does have support.
#ifdef OPENDREAM_REAL
#define DISABLE_DREAMLUAU
#endif

/// If this is uncommented, force our verb processing into just the 2% of a tick
/// We normally reserve for it
/// NEVER run this on live, it's for simulating highpop only
// #define VERB_STRESS_TEST

#ifdef VERB_STRESS_TEST
/// Uncomment this to force all verbs to run into overtime all of the time
/// Essentially negating the reserve 2%

// #define FORCE_VERB_OVERTIME
#warn Hey brother, you're running in LAG MODE.
#warn IF YOU PUT THIS ON LIVE I WILL FIND YOU AND MAKE YOU WISH YOU WERE NEVE-
#endif

#ifndef PRELOAD_RSC //set to:
#define PRELOAD_RSC 1 // 0 to allow using external resources or on-demand behaviour;
#endif // 1 to use the default behaviour;
								// 2 for preloading absolutely everything;

#ifdef LOWMEMORYMODE
#define FORCE_MAP "runtimestation"
#define FORCE_MAP_DIRECTORY "_maps"
#endif

//Additional code for the above flags.
#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.
#endif

#if defined(CIBUILDING) && !defined(OPENDREAM)
#define UNIT_TESTS
#endif

#ifdef CITESTING
#define TESTING
#endif

#if defined(UNIT_TESTS)
//Hard del testing defines
#define REFERENCE_TRACKING
#define REFERENCE_TRACKING_DEBUG
#define FIND_REF_NO_CHECK_TICK
#define GC_FAILURE_HARD_LOOKUP
//Ensures all early assets can actually load early
#define DO_NOT_DEFER_ASSETS
//Test at full capacity, the extra cost doesn't matter
#define TIMER_DEBUG
#endif

#ifdef TGS
// TGS performs its own build of dm.exe, but includes a prepended TGS define.
#define CBT
#endif

#if defined(OPENDREAM)
	#if !defined(CIBUILDING)
		#warn You are building with OpenDream. Remember to build TGUI manually.
		#warn You can do this by running tgui-build.cmd from the bin directory.
	#endif
#else
	#if !defined(CBT) && !defined(SPACEMAN_DMM)
		#warn Building with Dream Maker is no longer supported and will result in errors.
		#warn In order to build, run BUILD.cmd in the root directory.
		#warn Consider switching to VSCode editor instead, where you can press Ctrl+Shift+B to build.
	#endif
#endif

/// Runs the game in "map test mode"
/// Map test mode prevents common annoyances, such as rats from spawning and random light fixture breakage,
/// so mappers can test important facets of their map (working powernet, atmos, good light coverage) without these interfering.
// #define MAP_TEST

#ifdef MAP_TEST
#warn Compiling in MAP_TEST mode. Certain game mechanics will be disabled.
#endif
