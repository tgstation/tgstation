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
		return COMPONENT_INCOMPATIBLE

	src.evolve_mark = evolve_mark
	src.evolve_path = evolve_path

	//don't setup timer yet, timer calc requires the round to have started
	if(!SSticker.HasRoundStarted())
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(comp_on_round_start))
		return

	//if the round has already taken long enough, just leap right away.
	if((world.time - SSticker.round_start_time) > evolve_mark)
		leap(silent = TRUE)
		return

	setup_timer()

/datum/component/evolutionary_leap/Destroy(force, silent)
	. = ..()
	deltimer(timer_id)

/datum/component/evolutionary_leap/UnregisterFromParent()
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/// Proc ran when round starts.
/datum/component/evolutionary_leap/proc/comp_on_round_start()
	SIGNAL_HANDLER
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)
	setup_timer()

/datum/component/evolutionary_leap/proc/setup_timer()
	//in cases where this is calculating roundstart, world.time - SSticker.round_start_time should equal 0
	var/sum = (world.time - SSticker.round_start_time)
	var/mark = evolve_mark - sum
	timer_id = addtimer(CALLBACK(src, PROC_REF(leap), FALSE), mark, TIMER_STOPPABLE)

/datum/component/evolutionary_leap/proc/leap(silent)
	var/mob/living/old_mob = parent
	if (old_mob.stat == DEAD)
		return
	var/mob/living/new_mob = evolve_path
	var/new_mob_name = initial(new_mob.name)
	if(!silent)
		old_mob.visible_message(span_warning("[old_mob] evolves into \a [new_mob_name]!"))
	old_mob.change_mob_type(evolve_path, old_mob.loc, new_name = new_mob_name, delete_old_mob = TRUE)
