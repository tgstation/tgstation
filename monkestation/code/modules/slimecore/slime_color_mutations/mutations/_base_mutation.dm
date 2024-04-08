/datum/slime_mutation_data
	var/mob/living/basic/slime/host
	///mutation weight
	var/weight = 10
	///our probability of being mutated after weight
	var/mutate_probability = 100
	///are we blocked from color mutation syringes
	var/syringe_blocked = FALSE
	///can we mutate
	var/can_mutate = FALSE
	///The slime mutation we pass on if we succeed
	var/datum/slime_color/output
	///Items to feed the slime in order to mutate
	var/list/needed_items = list()
	///the liquids we need to consume in order to mutate
	var/list/needed_reagents = list()
	///the mobs needed to be latch fed in order to mutate - stored in type = amount
	var/list/latch_needed = list()

/datum/slime_mutation_data/Destroy(force, ...)
	. = ..()
	host = null

/datum/slime_mutation_data/proc/on_add_to_slime(mob/living/basic/slime/host)
	src.host = host
	if(length(needed_items))
		RegisterSignal(host, COMSIG_LIVING_ATE, PROC_REF(check_ate))

	/*
	if(length(needed_reagents))
	*/

	if(length(latch_needed))
		RegisterSignal(host, COMSIG_MOB_FEED, PROC_REF(check_latch))

/datum/slime_mutation_data/proc/recheck_mutation()
	if(length(latch_needed) || length(needed_reagents) || length(needed_items))
		return
	can_mutate = TRUE
	UnregisterSignal(host, COMSIG_LIVING_ATE)
	UnregisterSignal(host, COMSIG_MOB_FEED)

/datum/slime_mutation_data/proc/check_latch(datum/source, mob/living/target, amount)
	if(!(target.type in latch_needed))
		return

	latch_needed[target.type] -= amount
	if(latch_needed[target.type] <= 0)
		latch_needed -= target.type
	recheck_mutation()

/datum/slime_mutation_data/proc/check_ate(datum/source, atom/target)
	for(var/item in needed_items)
		if(!istype(target, item))
			continue
		needed_items -= item

	recheck_mutation()

