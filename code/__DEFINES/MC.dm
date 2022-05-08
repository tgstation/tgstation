#define MC_TICK_CHECK ( ( TICK_USAGE > Master.current_ticklimit || src.state != SS_RUNNING ) ? pause() : 0 )

#define MC_SPLIT_TICK_INIT(phase_count) var/original_tick_limit = Master.current_ticklimit; var/split_tick_phases = ##phase_count
#define MC_SPLIT_TICK \
	if(split_tick_phases > 1){\
		Master.current_ticklimit = ((original_tick_limit - TICK_USAGE) / split_tick_phases) + TICK_USAGE;\
		--split_tick_phases;\
	} else {\
		Master.current_ticklimit = original_tick_limit;\
	}

// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))

#define MC_AVG_FAST_UP_SLOW_DOWN(average, current) (average > current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))
#define MC_AVG_SLOW_UP_FAST_DOWN(average, current) (average < current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))

#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define START_PROCESSING(Processor, Datum) if (!(Datum.datum_flags & DF_ISPROCESSING)) {Datum.datum_flags |= DF_ISPROCESSING;Processor.processing += Datum}
#define STOP_PROCESSING(Processor, Datum) Datum.datum_flags &= ~DF_ISPROCESSING;Processor.processing -= Datum;Processor.currentrun -= Datum

/// Returns true if the MC is initialized and running.
/// Optional argument init_stage controls what stage the mc must have initializted to count as initialized. Defaults to INITSTAGE_MAX if not specified.
#define MC_RUNNING(INIT_STAGE...) (Master && Master.processing > 0 && Master.current_runlevel && Master.init_stage_completed == (max(min(INITSTAGE_MAX, ##INIT_STAGE), 1)))

#define MC_LOOP_RTN_NEWSTAGES 1
#define MC_LOOP_RTN_GRACEFUL_EXIT 2

//! SubSystem flags (Please design any new flags so that the default is off, to make adding flags to subsystems easier)

/// subsystem does not initialize.
#define SS_NO_INIT 1

/** subsystem does not fire. */
/// (like can_fire = 0, but keeps it from getting added to the processing subsystems list)
/// (Requires a MC restart to change)
#define SS_NO_FIRE 2

/** Subsystem only runs on spare cpu (after all non-background subsystems have ran that tick) */
/// SS_BACKGROUND has its own priority bracket, this overrides SS_TICKER's priority bump
#define SS_BACKGROUND 4

/** Treat wait as a tick count, not DS, run every wait ticks. */
/// (also forces it to run first in the tick (unless SS_BACKGROUND))
/// (We don't want to be choked out by other subsystems queuing into us)
/// (implies all runlevels because of how it works)
/// This is designed for basically anything that works as a mini-mc (like SStimer)
#define SS_TICKER 8

/** keep the subsystem's timing on point by firing early if it fired late last fire because of lag */
/// ie: if a 20ds subsystem fires say 5 ds late due to lag or what not, its next fire would be in 15ds, not 20ds.
#define SS_KEEP_TIMING 16

/** Calculate its next fire after its fired. */
/// (IE: if a 5ds wait SS takes 2ds to run, its next fire should be 5ds away, not 3ds like it normally would be)
/// This flag overrides SS_KEEP_TIMING
#define SS_POST_FIRE_TIMING 32

//! SUBSYSTEM STATES
#define SS_IDLE 0 /// ain't doing shit.
#define SS_QUEUED 1 /// queued to run
#define SS_RUNNING 2 /// actively running
#define SS_PAUSED 3 /// paused by mc_tick_check
#define SS_SLEEPING 4 /// fire() slept.
#define SS_PAUSING 5 /// in the middle of pausing

// Subsystem init stages
#define INITSTAGE_EARLY 1 //! Early init stuff that doesn't need to wait for mapload
#define INITSTAGE_MAIN 2 //! Main init stage
#define INITSTAGE_MAX 2 //! Highest initstage.

#define SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/##X);\
/datum/controller/subsystem/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/##X

#define TIMER_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/timer/##X);\
/datum/controller/subsystem/timer/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/timer/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/timer/##X

#define MOVEMENT_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/movement/##X);\
/datum/controller/subsystem/movement/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/movement/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/movement/##X

#define PROCESSING_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/processing/##X);\
/datum/controller/subsystem/processing/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/processing/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/processing/##X

#define FLUID_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/fluids/##X);\
/datum/controller/subsystem/fluids/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInit();\
}\
/datum/controller/subsystem/fluids/##X/fire() {..() /*just so it shows up on the profiler*/} \
/datum/controller/subsystem/fluids/##X
