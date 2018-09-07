//Update this whenever the db schema changes
//make sure you add an update to the schema_version stable in the db changelog
#define DB_MAJOR_VERSION 4
#define DB_MINOR_VERSION 7

//Timing subsystem
//Don't run if there is an identical unique timer active
//if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer, and returns the id of the existing timer
#define TIMER_UNIQUE			(1<<0)
//For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE			(1<<1)
//Timing should be based on how timing progresses on clients, not the sever.
//	tracking this is more expensive,
//	should only be used in conjuction with things that have to progress client side, such as animate() or sound()
#define TIMER_CLIENT_TIME		(1<<2)
//Timer can be stopped using deltimer()
#define TIMER_STOPPABLE			(1<<3)
//To be used with TIMER_UNIQUE
//prevents distinguishing identical timers with the wait variable
#define TIMER_NO_HASH_WAIT		(1<<4)
//Loops the timer repeatedly until qdeleted
//In most cases you want a subsystem instead
#define TIMER_LOOP				(1<<5)

#define TIMER_NO_INVOKE_WARNING 600 //number of byond ticks that are allowed to pass before the timer subsystem thinks it hung on something

#define TIMER_ID_NULL -1

//For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define INITIALIZATION_INSSATOMS 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 2	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 1	//New should call Initialize(FALSE)

#define INITIALIZE_HINT_NORMAL 0    //Nothing happens
#define INITIALIZE_HINT_LATELOAD 1  //Call LateInitialize
#define INITIALIZE_HINT_QDEL 2  //Call qdel on the atom

//type and all subtypes should always call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
    ..();\
    if(!(flags_1 & INITIALIZED_1)) {\
        args[1] = TRUE;\
        SSatoms.InitAtom(src, args);\
    }\
}

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define INIT_ORDER_GARBAGE			19
#define INIT_ORDER_DBCORE			18
#define INIT_ORDER_BLACKBOX			17
#define INIT_ORDER_SERVER_MAINT		16
#define INIT_ORDER_INPUT			15
#define INIT_ORDER_VIS				14
#define INIT_ORDER_RESEARCH			13
#define INIT_ORDER_EVENTS			12
#define INIT_ORDER_JOBS				11
#define INIT_ORDER_QUIRKS			10
#define INIT_ORDER_TICKER			9
#define INIT_ORDER_MAPPING			8
#define INIT_ORDER_NETWORKS			7
#define INIT_ORDER_ATOMS			6
#define INIT_ORDER_LANGUAGE			5
#define INIT_ORDER_MACHINES			4
#define INIT_ORDER_CIRCUIT			3
#define INIT_ORDER_TIMER			1
#define INIT_ORDER_DEFAULT			0
#define INIT_ORDER_AIR				-1
#define INIT_ORDER_ASSETS			-4
#define INIT_ORDER_ICON_SMOOTHING	-5
#define INIT_ORDER_OVERLAY			-6
#define INIT_ORDER_XKEYSCORE		-10
#define INIT_ORDER_STICKY_BAN		-10
#define INIT_ORDER_LIGHTING			-20
#define INIT_ORDER_SHUTTLE			-21
#define INIT_ORDER_SQUEAK			-40
#define INIT_ORDER_PATH				-50
#define INIT_ORDER_PERSISTENCE		-100

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)

#define FIRE_PRIORITY_PING			10
#define FIRE_PRIORITY_IDLE_NPC		10
#define FIRE_PRIORITY_SERVER_MAINT	10
#define FIRE_PRIORITY_RESEARCH		10
#define FIRE_PRIORITY_VIS			10
#define FIRE_PRIORITY_GARBAGE		15
#define FIRE_PRIORITY_WET_FLOORS	20
#define FIRE_PRIORITY_AIR			20
#define FIRE_PRIORITY_NPC			20
#define FIRE_PRIORITY_PROCESS		25
#define FIRE_PRIORITY_THROWING		25
#define FIRE_PRIORITY_SPACEDRIFT	30
#define FIRE_PRIORITY_FIELDS		30
#define FIRE_PRIOTITY_SMOOTHING		35
#define FIRE_PRIORITY_ORBIT			35
#define FIRE_PRIORITY_NETWORKS		40
#define FIRE_PRIORITY_OBJ			40
#define FIRE_PRIORITY_ACID			40
#define FIRE_PRIOTITY_BURNING		40
#define FIRE_PRIORITY_DEFAULT		50
#define FIRE_PRIORITY_PARALLAX		65
#define FIRE_PRIORITY_FLIGHTPACKS	80
#define FIRE_PRIORITY_MOBS			100
#define FIRE_PRIORITY_TGUI			110
#define FIRE_PRIORITY_TICKER		200
#define FIRE_PRIORITY_OVERLAYS		500
#define FIRE_PRIORITY_INPUT			1000 // This must always always be the max highest priority. Player input must never be lost.

// SS runlevels

#define RUNLEVEL_INIT 0
#define RUNLEVEL_LOBBY 1
#define RUNLEVEL_SETUP 2
#define RUNLEVEL_GAME 4
#define RUNLEVEL_POSTGAME 8

#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)




#define COMPILE_OVERLAYS(A)\
	if (TRUE) {\
		var/list/ad = A.add_overlays;\
		var/list/rm = A.remove_overlays;\
		var/list/po = A.priority_overlays;\
		if(LAZYLEN(rm)){\
			A.overlays -= rm;\
			rm.Cut();\
		}\
		if(LAZYLEN(ad)){\
			A.overlays |= ad;\
			ad.Cut();\
		}\
		if(LAZYLEN(po)){\
			A.overlays |= po;\
		}\
		A.flags_1 &= ~OVERLAY_QUEUED_1;\
	}
