/**
 * ### Evolutionary Leap Component; set a time in the round for a mob to evolve into a more dangerous form!
 *
 * Used for bileworms, to turn into vileworms!
 */
/datum/component/evolutionary_leap
	/// how much time until the parent makes an evolutionary leap
	var/evolve_mark
	/// id for leap timer
	var/timer_id
	/// what this mob turns into
	var/evolve_path

/datum/component/evolutionary_leap/Initialize(evolve_mark, evolve_path)
	if(!isliving(parent))
		return ELEMENT_INCOMPATIBLE

	src.evolve_mark = evolve_mark

	//don't setup timer yet, timer calc requires the round to have started
	if(!SSticker.HasRoundStarted())
		RegisterSignal(src, COMSIG_TICKER_ROUND_STARTING, .proc/comp_on_round_start)
		return

	//if the round has already taken long enough, just leap right away
	if((world.time - SSticker.round_start_time) > evolve_mark)
		leap()
		return

	setup_timer()

/datum/component/evolutionary_leap/Destroy(force, silent)
	. = ..()
	deltimer(timer_id)

/datum/component/evolutionary_leap/UnregisterFromParent()
	UnregisterSignal(src, COMSIG_TICKER_ROUND_STARTING)

/// Proc ran when round starts.
/datum/component/evolutionary_leap/proc/comp_on_round_start()
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_TICKER_ROUND_STARTING)
	setup_timer()
	return

/datum/component/evolutionary_leap/proc/setup_timer()
	var/mark = evolve_mark - (world.time - SSticker.round_start_time)
	timer_id = addtimer(CALLBACK(src, .proc/leap, FALSE), mark, TIMER_STOPPABLE)

/datum/component/evolutionary_leap/proc/leap(silent)
	var/mob/living/old_mob = parent
	var/mob/living/new_mob = evolve_path
	var/new_mob_name = initial(new_mob.name)
	if(!silent)
		old_mob.visible_message(span_warning("[src] evolves into \a [new_mob_name]!"))
	old_mob.change_mob_type(evolve_path, old_mob.loc, delete_old_mob = TRUE)
