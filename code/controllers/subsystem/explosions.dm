SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = INIT_ORDER_EXPLOSIONS
	priority = FIRE_PRIORITY_EXPLOSIONS
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait_for_explosions = FALSE


	var/cost_lowturf = 0
	var/cost_medturf = 0
	var/cost_highturf = 0

	var/cost_lowmob = 0
	var/cost_medmob = 0
	var/cost_highmob = 0

	var/cost_lowobj = 0
	var/cost_medobj = 0
	var/cost_highobj = 0

	var/list/lowturf = list()
	var/list/medturf = list()
	var/list/highturf = list()

	var/list/lowobj = list()
	var/list/medobj = list()
	var/list/highobj = list()

	var/list/explosions = list()

	var/list/currentrun = list()
	var/currentpart = SSAIR_PIPENETS


/datum/controller/subsystem/explosions/stat_entry(msg)
	msg += "C:{"
	msg += "LT:[round(cost_lowturf,1)]|"
	msg += "MT:[round(cost_medturf,1)]|"
	msg += "HT:[round(cost_highturf,1)]|"

	msg += "LO:[round(cost_lowobj,1)]|"
	msg += "MO:[round(cost_medobj,1)]|"
	msg += "HO:[round(cost_highobj,1)]|"

	msg += "} "

	msg += "AMT:{"
	msg += "LT:[lowturf.len]|"
	msg += "MT:[medturf.len]|"
	msg += "HT:[highturf.len]|"

	msg += "LO:[lowobj.len]|"
	msg += "MO:[medobj.len]|"
	msg += "HO:[highobj.len]|"

	msg += "} "
	..(msg)

#define SSEX_LOW 1
#define SSEX_MED 2
#define SSEX_HIGH 3
#define SSEX_TURF "turf"
#define SSEX_OBJ "obj"

/datum/controller/subsystem/explosions/proc/is_exploding()
	. = FALSE
	if(lowturf.len || medturf.len || highturf.len || lowobj.len || medobj.len || highobj.len)
		. = TRUE


/datum/controller/subsystem/explosions/fire(resumed = 0)
	var/timer = TICK_USAGE_REAL
	if(currentpart == SSEXPLOSIONS_TURFS)
		src.currentrun = lowturf.Copy()
		//cache for sanic speed (lists are references anyways)
		var/list/currentrun = src.currentrun
		while(currentrun.len)
			var/atom/thing = currentrun[currentrun.len]
			currentrun.len--
			if(thing)
				var/turf/T = thing
				T.explosion_level = max(T.explosion_level, EXPLODE_LIGHT)
				T.ex_act(EXPLODE_LIGHT)
				lowturf.Remove(thing)
			else
				lowturf.Remove(thing)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		src.currentrun = medturf.Copy()
		//cache for sanic speed (lists are references anyways)
		currentrun = src.currentrun
		while(currentrun.len)
			var/atom/thing = currentrun[currentrun.len]
			currentrun.len--
			if(thing)
				var/turf/T = thing
				T.explosion_level = max(T.explosion_level, EXPLODE_HEAVY)
				T.ex_act(EXPLODE_HEAVY)
				medturf.Remove(thing)
			else
				medturf.Remove(thing)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		src.currentrun = highturf.Copy()
		//cache for sanic speed (lists are references anyways)
		currentrun = src.currentrun
		while(currentrun.len)
			var/atom/thing = currentrun[currentrun.len]
			currentrun.len--
			if(thing)
				var/turf/T = thing
				T.explosion_level = max(T.explosion_level, EXPLODE_DEVASTATE)
				T.ex_act(EXPLODE_DEVASTATE)
				highturf.Remove(thing)
			else
				highturf.Remove(thing)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSEXPLOSIONS_OBJECTS

	if(currentpart == SSEXPLOSIONS_OBJECTS)
		src.currentrun = highobj.Copy()
		//cache for sanic speed (lists are references anyways)
		var/list/currentrun = src.currentrun
		while(currentrun.len)
			var/atom/thing = currentrun[currentrun.len]
			currentrun.len--
			if(thing)
				var/obj/O = thing
				O.ex_act(EXPLODE_DEVASTATE)
				highobj.Remove(thing)
			else
				highobj.Remove(thing)
		cost_highobj = MC_AVERAGE(cost_highobj, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		src.currentrun = medobj.Copy()
		//cache for sanic speed (lists are references anyways)
		currentrun = src.currentrun
		while(currentrun.len)
			var/atom/thing = currentrun[currentrun.len]
			currentrun.len--
			if(thing)
				var/obj/O = thing
				O.ex_act(EXPLODE_HEAVY)
				medobj.Remove(thing)
			else
				medobj.Remove(thing)
		cost_medobj = MC_AVERAGE(cost_medobj, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		src.currentrun = lowobj.Copy()
		//cache for sanic speed (lists are references anyways)
		currentrun = src.currentrun
		while(currentrun.len)
			var/atom/thing = currentrun[currentrun.len]
			currentrun.len--
			if(thing)
				var/obj/O = thing
				O.ex_act(EXPLODE_LIGHT)
				lowobj.Remove(thing)
			else
				lowobj.Remove(thing)
		cost_lowobj = MC_AVERAGE(cost_lowobj, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSEXPLOSIONS_TURFS
	currentpart = SSEXPLOSIONS_TURFS