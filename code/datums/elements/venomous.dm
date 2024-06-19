/**
 * Venomous element; which makes the attacks of the simplemob attached poison the enemy.
 *
 * Used for spiders, frogs, and bees!
 */
/datum/element/venomous
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///Path of the reagent added
	var/poison_type
	///Details of how we inject our venom
	var/injection_flags
	///How much of the reagent added. if it's a list, it'll pick a range with the range being list(lower_value, upper_value)
	var/list/amount_added

/datum/element/venomous/Attach(datum/target, poison_type, amount_added, injection_flags = NONE, thrown_effect = FALSE)
	. = ..()
	src.poison_type = poison_type
	src.amount_added = amount_added
	src.injection_flags = injection_flags
	target.AddComponent(\
		/datum/component/on_hit_effect,\
		on_hit_callback = CALLBACK(src, PROC_REF(do_venom)),\
		thrown_effect = thrown_effect,\
	)

/datum/element/venomous/Detach(datum/target)
	qdel(target.GetComponent(/datum/component/on_hit_effect))
	return ..()

/datum/element/venomous/proc/do_venom(datum/element_owner, atom/venom_source, mob/living/target, hit_zone)
	if(!istype(target))
		return
	if(target.stat == DEAD)
		return
	if(isliving(element_owner) && !target.try_inject(element_owner, hit_zone, injection_flags))
		return
	var/final_amount_added
	if(islist(amount_added))
		final_amount_added = rand(amount_added[1], amount_added[2])
	else
		final_amount_added = amount_added
	target.reagents?.add_reagent(poison_type, final_amount_added)
