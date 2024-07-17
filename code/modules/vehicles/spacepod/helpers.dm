/// Returns how much is equipped in this slot. Returns 0 if null, or empty list. Returns 1 if not list and not null. Otherwise returns length
/obj/vehicle/sealed/space_pod/proc/equipment_count_in_slot(slot)
	return islist(equipped[slot]) ? length(equipped[slot]) : !isnull(equipped[slot])
/// Returns the slot max of a slot. Returns 1 if not overriden, otherwise returns the count in slot_max var
/obj/vehicle/sealed/space_pod/proc/slot_max(slot)
	return !isnull(slot_max[slot]) ? slot_max[slot] : 1
/// Gets all attached parts
/obj/vehicle/sealed/space_pod/proc/get_all_parts()
	. = list()
	for(var/slot in equipped)
		. += equipped[slot] //byond works its magic im not sure whats the point of this proc actually
