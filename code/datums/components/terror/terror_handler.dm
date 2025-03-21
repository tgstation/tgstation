/// Terror handlers, aka datums which determine current fear behaviors.
/// Separated into two groups, fear sources and fear effects, latter processing after all former are finished

/datum/fear_handler
	/// Owner of this fear handler
	var/mob/living/owner
