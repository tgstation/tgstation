/**
 * ### Growth and Differentiation Component: Used to randomly "grow" a creature into a new entity over its lifespan.
 *
 * If we are passed a typepath, we will 100% grow into that type. However, if we are not passed a typepath, we will pick one from a subtype of the parent we were applied to!
 *
 * Used for spiderlings to turn them into giant spiders.
 */

/datum/component/growth_and_differentiation
	/// What this mob turns into when fully grown.
	var/growth_path
	/// Failover for how much time we have until we fully grow. If passed as null, we eschew setting up the timer.
	/// Remember: We can grow earlier than this if the randomness rolls turn out to be in our favor though!
	var/growth_time
	/// Integer - Probability we grow per SPT_PROB
	var/growth_probability
	/// Integer - The lower bound for the percentage we have to grow before we can differentiate.
	var/lower_growth_value
	/// Integer - The upper bound for the percentage we have to grow before we can differentiate.
	var/upper_growth_value
	/// Optional callback for checks to see if we're okay to grow.
	var/datum/callback/optional_checks
	/// Optional callback in case we wish to override the default grow() behavior. Assume we supersede the change_mob_type() call if we have this set.
	var/datum/callback/optional_grow_behavior

	/// ID for the failover timer.
	var/timer_id
	/// Percentage we have grown.
	var/percent_grown = 0
	/// Are we ready to grow? This is just in case we fail our checks and need to wait until the next tick.
	/// We only really need this because we have two competing systems, the timer and the probability-based growth. When one succeeds, this component is considered successful in growth,
	/// and will actively try to grow the mob (only barred by optional checks).
	var/ready_to_grow = FALSE

/datum/component/growth_and_differentiation/Initialize(growth_time, growth_path, growth_probability, lower_growth_value, upper_growth_value, optional_checks, optional_grow_behavior)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.growth_path = growth_path
	src.growth_time = growth_time
	src.growth_probability = growth_probability
	src.lower_growth_value = lower_growth_value
	src.upper_growth_value = upper_growth_value
	src.optional_checks = optional_checks
	src.optional_grow_behavior = optional_grow_behavior

	// If we haven't started the round, we can't do timer stuff. Let's wait in case we're mapped in or something.
	if(!SSticker.HasRoundStarted() && !isnull(growth_time))
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(comp_on_round_start))
		return

	return setup_growth_tracking()

/datum/component/growth_and_differentiation/Destroy(force, silent)
	. = ..()
	deltimer(timer_id)

/datum/component/growth_and_differentiation/UnregisterFromParent()
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/// What we invoke when the round starts so we can set up our timer.
/datum/component/growth_and_differentiation/proc/comp_on_round_start()
	SIGNAL_HANDLER
	setup_growth_tracking()
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/// Sets up the failover timer for certain growth.
/datum/component/growth_and_differentiation/proc/setup_growth_tracking()
	var/did_we_add_at_least_one_thing = FALSE

	if(!isnull(growth_time))
		timer_id = addtimer(CALLBACK(src, PROC_REF(grow), FALSE), growth_time, TIMER_STOPPABLE)
		if(!isnull(timer_id)) // realistically shouldn't happen considering how hardy addtimer() is but you can never be too sure
			did_we_add_at_least_one_thing = TRUE

	if(!isnull(growth_probability))
		START_PROCESSING(SSdcs, src)
		did_we_add_at_least_one_thing = TRUE

	if(!did_we_add_at_least_one_thing)
		stack_trace("Growth and Differentiation Component: Neither growth time nor probability were set! This component is useless!")
		return COMPONENT_INCOMPATIBLE // if we're invoked via COMSIG_TICKER_ROUND_STARTING this won't do anything (and shouldn't be invoked since we nullcheck growth_time before adding that signal anyways)

	return null // just for explicitness's sake, if they ever change Component's Initialize to have more return values make sure this is the one for "Success!"

/datum/component/growth_and_differentiation/process(seconds_per_tick) // check the prob we were passed in, and if we're lucky, grow!
	if(ready_to_grow)
		INVOKE_ASYNC(src, PROC_REF(grow), FALSE)
		return

	if(percent_grown >= 100)
		ready_to_grow = TRUE
		INVOKE_ASYNC(src, PROC_REF(grow), FALSE) // lets not waste any more of SSmobs time this tick.
		return

	if(SPT_PROB(growth_probability, seconds_per_tick))
		percent_grown += rand(lower_growth_value, upper_growth_value)

/// Grows the mob into its new form.
/datum/component/growth_and_differentiation/proc/grow(silent)
	if(!isnull(optional_checks) && !optional_checks.Invoke()) // we failed our checks somehow, but we're still ready to grow. Let's wait until next tick to see if our circumstances have changed.
		ready_to_grow = TRUE
		return

	var/mob/living/old_mob = parent
	if (old_mob.stat == DEAD)
		qdel(src) // assume that we are priced out of growth once dead
		return

	STOP_PROCESSING(SSdcs, src)

	if(!isnull(optional_grow_behavior)) // basically growth_path is OK to be null but only if we have an optional grow behavior.
		optional_grow_behavior.Invoke()
		return

	var/mob/living/new_mob = growth_path
	if(!istype(new_mob))
		CRASH("Growth and Differentiation Component: Growth path was not a mob type! If you wanted to do something special, please put it in the optional_grow_behavior callback instead!")

	var/new_mob_name = initial(new_mob.name)

	if(!silent)
		old_mob.visible_message(span_warning("[old_mob] grows into \a [new_mob_name]!"))

	old_mob.change_mob_type(growth_path, old_mob.loc, new_name = new_mob_name, delete_old_mob = TRUE)
