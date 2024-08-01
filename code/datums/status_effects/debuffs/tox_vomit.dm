/// Simple status effect applied when a mob has high toxins and starts to vomit regularly
/datum/status_effect/tox_vomit
	id = "vomitting_from_toxins"
	tick_interval = 2 SECONDS
	alert_type = null
	/// Has a chance to count up every tick, until it reaches a threshold, which causes the mob to vomit and resets
	VAR_PRIVATE/puke_counter = 0

/datum/status_effect/tox_vomit/tick(seconds_between_ticks)
	if(!AT_TOXIN_VOMIT_THRESHOLD(owner))
		qdel(src)
		return

	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_STASIS))
		return

	puke_counter += SPT_PROB(30, seconds_between_ticks)
	if(puke_counter < 50) // This is like 150 seconds apparently according to old comments
		return

	var/mob/living/carbon/human/sick_guy = owner
	sick_guy.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 20)
	puke_counter = 0
