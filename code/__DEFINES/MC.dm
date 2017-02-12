#define MC_TICK_CHECK ( ( world.tick_usage > CURRENT_TICKLIMIT || src.state != SS_RUNNING ) ? pause() : 0 )
// Used to smooth out costs to try and avoid oscillation.
#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))
#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define START_PROCESSING(Processor, Datum) if (!Datum.isprocessing) {Datum.isprocessing = 1;Processor.processing += Datum}
#define STOP_PROCESSING(Processor, Datum) Datum.isprocessing = 0;Processor.processing -= Datum

//SubSystem flags (Please design any new flags so that the default is off, to make adding flags to subsystems easier)

//subsystem should fire during pre-game lobby.
#define SS_FIRE_IN_LOBBY 1

//subsystem does not initialize.
#define SS_NO_INIT 2

//subsystem does not fire.
//	(like can_fire = 0, but keeps it from getting added to the processing subsystems list)
//	(Requires a MC restart to change)
#define SS_NO_FIRE 4

//subsystem only runs on spare cpu (after all non-background subsystems have ran that tick)
//	SS_BACKGROUND has its own priority bracket
#define SS_BACKGROUND 8

//subsystem does not tick check, and should not run unless there is enough time (or its running behind (unless background))
#define SS_NO_TICK_CHECK 16

//Treat wait as a tick count, not DS, run every wait ticks.
//	(also forces it to run first in the tick, above even SS_NO_TICK_CHECK subsystems)
//	(implies SS_FIRE_IN_LOBBY because of how it works)
//	(overrides SS_BACKGROUND)
//	This is designed for basically anything that works as a mini-mc (like SStimer)
#define SS_TICKER 32

//keep the subsystem's timing on point by firing early if it fired late last fire because of lag
//	ie: if a 20ds subsystem fires say 5 ds late due to lag or what not, its next fire would be in 15ds, not 20ds.
#define SS_KEEP_TIMING 64

//Calculate its next fire after its fired.
//	(IE: if a 5ds wait SS takes 2ds to run, its next fire should be 5ds away, not 3ds like it normally would be)
//	This flag overrides SS_KEEP_TIMING
#define SS_POST_FIRE_TIMING 128

//SUBSYSTEM STATES
#define SS_IDLE 0		//aint doing shit.
#define SS_QUEUED 1		//queued to run
#define SS_RUNNING 2	//actively running
#define SS_PAUSED 3		//paused by mc_tick_check
#define SS_SLEEPING 4	//fire() slept.
#define SS_PAUSING 5 	//in the middle of pausing


//Timing subsystem
//Don't run if there is an identical unique timer active
#define TIMER_UNIQUE		0x1
//For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE		0x2
//Timing should be based on how timing progresses on clients, not the sever.
//	tracking this is more expensive,
//	should only be used in conjuction with things that have to progress client side, such as animate() or sound()
#define TIMER_CLIENT_TIME	0x4
//Timer can be stopped using deltimer()
#define TIMER_STOPPABLE		0x8
