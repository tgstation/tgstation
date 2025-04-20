/// The threshold in which all of our movements are fully randomized.
#define CONFUSION_FULL_STRENGTH 100
///How much we lower the misstep chacne by crawling.
#define CRAWL_MISSTEP_MULT 0.50
/// A status effect used for adding confusion to a mob.
/datum/status_effect/confusion
	id = "confusion"
	alert_type = null
	remove_on_fullheal = TRUE
	strength = 50

/datum/status_effect/confusion/on_creation(mob/living/new_owner, new_duration, new_strength, ...)
	strength = new_strength
	return ..()

/datum/status_effect/confusion/on_apply()
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_move))
	return TRUE

/datum/status_effect/confusion/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

/// Signal proc for [COMSIG_MOB_CLIENT_PRE_MOVE]. We have a chance to mix up our movement pre-move with confusion.
/datum/status_effect/confusion/proc/on_move(datum/source, list/move_args)
	SIGNAL_HANDLER

	var/direction = move_args[MOVE_ARG_DIRECTION]
	var/new_dir

	///We first calculate if we are going to misstep, crawlings helps reduce the risk.
	if(prob(min(CONFUSION_FULL_STRENGTH * (owner.resting ? CRAWL_MISSTEP_MULT : 1)), strength * (owner.resting ? CRAWL_MISSTEP_MULT : 1)))
		if(CONFUSION_FULL_STRENGTH >= strength)
			new_dir = pick(GLOB.alldirs)

		//if the confusion is serious we get more severe missteps and less light diagonal missteps
		else if(prob(strength))
			new_dir = angle2dir(dir2angle(direction) + pick(90, -90))

		else
			new_dir = angle2dir(dir2angle(direction) + pick(45, -45))

	if(!isnull(new_dir))
		move_args[MOVE_ARG_NEW_LOC] = get_step(owner, new_dir)
		move_args[MOVE_ARG_DIRECTION] = new_dir

/datum/status_effect/confusion/tick(seconds_between_ticks)
	strength = strength * CONFUSION_DECAY_MULT ** seconds_between_ticks - CONFUSION_DECAY_FLAT * seconds_between_ticks

	if(strength <= 0)
		qdel(src)

#undef CONFUSION_FULL_STRENGTH
#undef CONFUSION_MISSTEP_MULT
