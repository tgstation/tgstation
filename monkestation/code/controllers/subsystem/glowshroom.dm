#define SSGLOWSHROOMS_RUN_TYPE_SPREAD	1
#define SSGLOWSHROOMS_RUN_TYPE_DECAY	2
//#define SSGLOWSHROOMS_RUN_TYPE_INIT		3

SUBSYSTEM_DEF(glowshrooms)
	name = "Glowshroom Processing"
	priority = 10
	wait = 1 SECONDS
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/run_type = SSGLOWSHROOMS_RUN_TYPE_SPREAD
	var/enable_spreading = TRUE
	var/list/obj/structure/glowshroom/glowshrooms = list()
	// var/list/obj/structure/glowshroom/new_glowshrooms = list()
	var/list/obj/structure/glowshroom/currentrun_spread = list()
	var/list/obj/structure/glowshroom/currentrun_decay = list()
	// var/list/obj/structure/glowshroom/currentrun_new = list()

/datum/controller/subsystem/glowshrooms/fire(resumed)
	// just... trust me, this makes COMPLETE sense
	if(!length(currentrun_spread) && !length(currentrun_decay))
		list_clear_nulls(glowshrooms)
		if(length(glowshrooms))
			// turns out sorting results in a lot of overtime
			// maybe aneri can fix this in the future idk
			// sortTim(glowshrooms, GLOBAL_PROC_REF(cmp_glowshroom_spread))
			if(enable_spreading)
				currentrun_spread = glowshrooms.Copy()
			currentrun_decay = glowshrooms.Copy()
	/*if(!length(currentrun_new))
		list_clear_nulls(new_glowshrooms)
		currentrun_new = new_glowshrooms.Copy()*/

	if(run_type == SSGLOWSHROOMS_RUN_TYPE_SPREAD)
		if(enable_spreading)
			var/list/current_run_spread = currentrun_spread
			while(length(current_run_spread))
				var/obj/structure/glowshroom/glowshroom = current_run_spread[length(current_run_spread)]
				current_run_spread.len--
				if(QDELETED(glowshroom))
					glowshrooms -= glowshroom
				else if(COOLDOWN_FINISHED(glowshroom, spread_cooldown))
					COOLDOWN_START(glowshroom, spread_cooldown, rand(glowshroom.min_delay_spread, glowshroom.max_delay_spread))
					glowshroom.Spread(wait * 0.1)
				if(MC_TICK_CHECK)
					return
		run_type = SSGLOWSHROOMS_RUN_TYPE_DECAY

	if(run_type == SSGLOWSHROOMS_RUN_TYPE_DECAY)
		var/list/current_run_decay = currentrun_decay
		while(length(current_run_decay))
			var/obj/structure/glowshroom/glowshroom = current_run_decay[length(current_run_decay)]
			current_run_decay.len--
			if(QDELETED(glowshroom))
				glowshrooms -= glowshroom
			else
				glowshroom.Decay(wait * 0.1)
			if(MC_TICK_CHECK)
				return
		run_type = SSGLOWSHROOMS_RUN_TYPE_SPREAD

/*
	if(run_type == SSGLOWSHROOMS_RUN_TYPE_INIT)
		var/list/current_run_new = currentrun_new
		while(length(current_run_new))
			var/obj/structure/glowshroom/glowshroom = current_run_new[length(current_run_new)]
			current_run_new.len--
			if(!QDELETED(glowshroom))
				glowshroom.update_light()
				glowshrooms += glowshroom
			new_glowshrooms -= glowshroom
			if(MC_TICK_CHECK)
				return
		run_type = SSGLOWSHROOMS_RUN_TYPE_SPREAD
*/

/datum/controller/subsystem/glowshrooms/stat_entry(msg)
	//msg = "P:[length(glowshrooms)] | NEW:[length(new_glowshrooms)]"
	msg = "P:[length(glowshrooms)]"
	return ..()

/datum/controller/subsystem/glowshrooms/Recover()
	glowshrooms = SSglowshrooms.glowshrooms
	//new_glowshrooms = SSglowshrooms.new_glowshrooms
	..()

/datum/controller/subsystem/glowshrooms/proc/deploy_the_rabbits()
	enable_spreading = FALSE
	currentrun_spread.Cut()
	log_admin("Glowshroom spreading has been disabled!")
	message_admins("Glowshroom spreading has been disabled!")

/*/proc/cmp_glowshroom_spread(obj/structure/glowshroom/a, obj/structure/glowshroom/b)
	return b.last_successful_spread - a.last_successful_spread*/

// #undef SSGLOWSHROOMS_RUN_TYPE_INIT
#undef SSGLOWSHROOMS_RUN_TYPE_DECAY
#undef SSGLOWSHROOMS_RUN_TYPE_SPREAD
