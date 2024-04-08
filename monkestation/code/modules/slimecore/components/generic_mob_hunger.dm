/datum/component/generic_mob_hunger
	var/current_hunger
	var/max_hunger
	///this is the rate at which our hunger passively drains
	var/hunger_drain
	var/hunger_paused = FALSE
	var/feed_pause_time
	var/feed_pause_end

/datum/component/generic_mob_hunger/Initialize(max_hunger = 250, hunger_drain = 0.1, feed_pause_time = 1 MINUTE, starting_hunger)
	. = ..()
	src.hunger_drain = hunger_drain
	src.max_hunger = max_hunger
	src.feed_pause_time = feed_pause_time
	if(!starting_hunger)
		src.current_hunger = max_hunger
	else
		src.current_hunger = starting_hunger

	START_PROCESSING(SSobj, src)

/datum/component/generic_mob_hunger/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_STOP_HUNGER, PROC_REF(stop_hunger))
	RegisterSignal(parent, COMSIG_MOB_START_HUNGER, PROC_REF(start_hunger))
	RegisterSignal(parent, COMSIG_MOB_FEED, PROC_REF(on_feed))
	RegisterSignal(parent, COMSIG_MOB_RETURN_HUNGER, PROC_REF(return_hunger))
	RegisterSignal(parent, COMSIG_MOB_ADJUST_HUNGER, PROC_REF(adjust_hunger))

/datum/component/generic_mob_hunger/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_STOP_HUNGER)
	UnregisterSignal(parent, COMSIG_MOB_START_HUNGER)
	UnregisterSignal(parent, COMSIG_MOB_FEED)
	UnregisterSignal(parent, COMSIG_MOB_RETURN_HUNGER)
	UnregisterSignal(parent, COMSIG_MOB_ADJUST_HUNGER)

/datum/component/generic_mob_hunger/proc/stop_hunger()
	hunger_paused = TRUE

/datum/component/generic_mob_hunger/proc/start_hunger()
	hunger_paused = FALSE

/datum/component/generic_mob_hunger/proc/on_feed(datum/source, atom/target, feed_amount)
	SIGNAL_HANDLER
	if(current_hunger > max_hunger)
		SEND_SIGNAL(parent, COMSIG_MOB_REFUSED_EAT)
		return

	SEND_SIGNAL(parent, COMSIG_HUNGER_UPDATED, current_hunger + feed_amount, max_hunger)
	if(current_hunger + feed_amount > max_hunger)
		var/temp = (current_hunger + feed_amount) / max_hunger
		SEND_SIGNAL(parent, COMSIG_MOB_OVERATE, temp)
		ADD_TRAIT(parent, TRAIT_OVERFED, "hunger_trait")
		addtimer(CALLBACK(src, PROC_REF(remove_hunger_trait), TRAIT_OVERFED), 5 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		current_hunger += feed_amount
		if(feed_pause_time)
			feed_pause_end = world.time + feed_pause_time
		return

	current_hunger += feed_amount
	SEND_SIGNAL(parent, COMSIG_MOB_EAT_NORMAL, current_hunger)
	if(feed_pause_time)
		feed_pause_end = world.time + feed_pause_time

/datum/component/generic_mob_hunger/proc/return_hunger()
	SIGNAL_HANDLER
	return current_hunger / max_hunger

/datum/component/generic_mob_hunger/process(seconds_per_tick)
	if(hunger_paused || !hunger_drain || (feed_pause_end > world.time))
		return

	if(isliving(parent))
		var/mob/living/living = parent
		if(living.stat == DEAD)
			return

	if(current_hunger >= hunger_drain)
		current_hunger -= hunger_drain
		SEND_SIGNAL(parent, COMSIG_HUNGER_UPDATED, current_hunger, max_hunger)

		var/hunger_precent = current_hunger / max_hunger

		if(hunger_precent <= 0.25)
			SEND_SIGNAL(parent, COMSIG_MOB_STARVING, hunger_precent)
	else
		current_hunger = 0
		SEND_SIGNAL(parent, COMSIG_HUNGER_UPDATED, current_hunger, max_hunger)
		SEND_SIGNAL(parent, COMSIG_MOB_FULLY_STARVING)

/datum/component/generic_mob_hunger/proc/adjust_hunger(datum/source, amount)
	current_hunger += amount

/datum/component/generic_mob_hunger/proc/remove_hunger_trait(trait)
	REMOVE_TRAIT(parent, trait, "hunger_trait")
