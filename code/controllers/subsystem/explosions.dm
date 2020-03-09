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
	var/check_tick_for_turfs = TRUE


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
		process_explosions(SSEX_TURF, SSEX_LOW, resumed)
		cost_lowturf = MC_AVERAGE(cost_lowturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		process_explosions(SSEX_TURF, SSEX_MED, resumed)
		cost_medturf = MC_AVERAGE(cost_medturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		process_explosions(SSEX_TURF, SSEX_HIGH, resumed)
		cost_highturf = MC_AVERAGE(cost_highturf, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSEXPLOSIONS_OBJECTS

	if(currentpart == SSEXPLOSIONS_OBJECTS)
		process_explosions(SSEX_OBJ, SSEX_HIGH, resumed)
		cost_highobj = MC_AVERAGE(cost_highobj, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		process_explosions(SSEX_OBJ, SSEX_MED, resumed)
		cost_medobj = MC_AVERAGE(cost_medobj, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
		process_explosions(SSEX_OBJ, SSEX_LOW, resumed)
		cost_lowobj = MC_AVERAGE(cost_lowobj, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))


		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSEXPLOSIONS_TURFS
	currentpart = SSEXPLOSIONS_TURFS

/datum/controller/subsystem/explosions/proc/remove_from_lists(atom_to_remove, type_of_atom, level)
	switch(type_of_atom)
		if(SSEX_TURF)
			switch(level)
				if(SSEX_LOW)
					lowturf.Remove(atom_to_remove)
				if(SSEX_MED)
					medturf.Remove(atom_to_remove)
				if(SSEX_HIGH)
					highturf.Remove(atom_to_remove)
		if(SSEX_OBJ)
			switch(level)
				if(SSEX_LOW)
					lowobj.Remove(atom_to_remove)
				if(SSEX_MED)
					medobj.Remove(atom_to_remove)
				if(SSEX_HIGH)
					highobj.Remove(atom_to_remove)


/datum/controller/subsystem/explosions/proc/process_explosions(ex_type, level, resumed = 0)
	if (!resumed)
		switch(ex_type)
			if(SSEX_TURF)
				switch(level)
					if(SSEX_LOW)
						src.currentrun = lowturf.Copy()
					if(SSEX_MED)
						src.currentrun = medturf.Copy()
					if(SSEX_HIGH)
						src.currentrun = highturf.Copy()
			if(SSEX_OBJ)
				switch(level)
					if(SSEX_LOW)
						src.currentrun = lowobj.Copy()
					if(SSEX_MED)
						src.currentrun = medobj.Copy()
					if(SSEX_HIGH)
						src.currentrun = highobj.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/turf/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			explode_thing(thing, ex_type, level)
			remove_from_lists(thing, ex_type, level)
		else
			remove_from_lists(thing, ex_type, level)
		if(check_tick_for_turfs && ex_type == SSEX_TURF)
			if(MC_TICK_CHECK)
				return
		else if(ex_type == SSEX_OBJ)
			if(MC_TICK_CHECK)
				return


/datum/controller/subsystem/explosions/proc/explode_thing(atom_to_explode, ex_type, level)
	switch(ex_type)
		if(SSEX_TURF)
			var/turf/T = atom_to_explode
			switch(level)
				if(SSEX_LOW)
					T.explosion_level = max(T.explosion_level, EXPLODE_LIGHT)
					T.ex_act(EXPLODE_LIGHT)
				if(SSEX_MED)
					T.explosion_level = max(T.explosion_level, EXPLODE_HEAVY)
					T.ex_act(EXPLODE_HEAVY)
				if(SSEX_HIGH)
					T.explosion_level = max(T.explosion_level, EXPLODE_DEVASTATE)
					T.ex_act(EXPLODE_DEVASTATE)
		if(SSEX_OBJ)
			var/obj/O = atom_to_explode
			switch(level)
				if(SSEX_LOW)
					O.ex_act(EXPLODE_LIGHT)
				if(SSEX_MED)
					O.ex_act(EXPLODE_HEAVY)
				if(SSEX_HIGH)
					O.ex_act(EXPLODE_DEVASTATE)
