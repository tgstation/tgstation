/**
 *Storage component used for RPEDs. Rather than manually setting everything with a get_part_rating() value, we just check if it has the variable required for insertion.
 */
/datum/storage/rped
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	max_slots = 50
	max_total_storage = 100
	max_specific_storage = WEIGHT_CLASS_NORMAL
	numerical_stacking = TRUE

/datum/storage/rped/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	. = ..()
	if(!to_insert.get_part_rating())
		return FALSE
