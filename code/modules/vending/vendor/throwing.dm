
/**
 * Throw an item from our internal inventory out in front of us
 *
 * This is called when we are hacked, it selects a random product from the records that has an amount > 0
 * This item is then created and tossed out in front of us with a visible message
 */
/obj/machinery/vending/proc/throw_item()
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return FALSE

	var/obj/thrown_item
	for(var/datum/data/vending_product/record in shuffle(product_records))
		if(record.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = record.product_path
		if(!dump_path)
			continue
		// Always throw new stuff that costs before free returned stuff, because of the hacking effort and time between throws involved
		var/only_returned_left = (record.amount <= LAZYLEN(record.returned_products))
		thrown_item = dispense(record, get_turf(src), silent = TRUE, dispense_returned = only_returned_left)
		break
	if(isnull(thrown_item))
		return FALSE

	pre_throw(thrown_item)

	thrown_item.throw_at(target, 16, 3)
	visible_message(span_danger("[src] launches [thrown_item] at [target]!"))
	return TRUE

/**
 * A callback called before an item is tossed out
 *
 * Override this if you need to do any special case handling
 *
 * Arguments:
 * * thrown_item - obj/item being thrown
 */
/obj/machinery/vending/proc/pre_throw(obj/item/thrown_item)
	return


///Crush the mob that the vending machine got thrown at
/obj/machinery/vending/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))
		tilt(fatty=hit_atom)
	return ..()

/obj/machinery/vending/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	var/mob/living/living_mob = hitting_atom
	if(tilted || !istype(living_mob) || !prob(20 * (throwingdatum.speed - living_mob.throw_speed))) // hulk throw = +20%, neckgrab throw = +20%
		return

	tilt(living_mob)
