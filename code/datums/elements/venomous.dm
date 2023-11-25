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
	///How much of the reagent added. if it's a list, it'll pick a range with the range being list(lower_value, upper_value)
	var/list/amount_added

/datum/element/venomous/Attach(datum/target, poison_type, amount_added)
	. = ..()
	src.poison_type = poison_type
	src.amount_added = amount_added
	target.AddComponent(/datum/component/on_hit_effect, CALLBACK(src, PROC_REF(do_venom)))

/datum/element/venomous/Detach(datum/target)
	qdel(target.GetComponent(/datum/component/on_hit_effect))
	return ..()

/datum/element/venomous/proc/do_venom(datum/element_owner, atom/venom_source, atom/target, hit_zone)
	if(!iscarbon(target) && !ismecha(target) && !isvehicle(target))
		return

	var/mob/living/carbon/victim

	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/mech = target
		if(mech.enclosed || !LAZYLEN(mech.occupants) || (LAZYLEN(mech.occupants) == 1 && mech.mecha_flags & SILICON_PILOT))
			return

		for(var/mob/living/carbon/target_victim as anything in mech.occupants)
			victim = target_victim
			break // only get the 1st occupant
	else if(isvehicle(target))
		var/obj/vehicle/ridden_vehicle = target
		for(var/mob/living/carbon/target_victim as anything in ridden_vehicle.occupants)
			victim = target_victim
			break // only get the 1st occupant
	else if(iscarbon(target))
		victim = target

	if(victim.stat == DEAD)
		return

	var/final_amount_added
	if(islist(amount_added))
		final_amount_added = rand(amount_added[1], amount_added[2])
	else
		final_amount_added = amount_added
	victim.reagents?.add_reagent(poison_type, final_amount_added)
