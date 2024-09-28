/// Returns the slot max of a slot. Returns 1 if not overriden, otherwise returns the count in slot_max var
/obj/vehicle/sealed/space_pod/proc/slot_max(slot)
	return !isnull(slot_max[slot]) ? slot_max[slot] : 1

/// Gets all attached parts
/obj/vehicle/sealed/space_pod/proc/get_all_parts()
	. = list()
	for(var/slot in equipped)
		. += equipped[slot] //byond works its magic im not sure whats the point of this proc actually

/// returns a list of parts that are this typepath
/obj/vehicle/sealed/space_pod/proc/get_parts_by_type(path)
	. = list()
	for(var/slot in equipped)
		for(var/datum/thing as anything in equipped[slot])
			if(!istype(thing, path))
				continue
			. += thing

/// returns the first part we are incompatible with
/obj/vehicle/sealed/space_pod/proc/is_part_exclusive(obj/item/pod_equipment/target)
	for(var/obj/item/pod_equipment/equipment as anything in get_all_parts())
		if((!target.allow_dupes || !equipment.allow_dupes) && istype(equipment, target.type))
			return equipment
		if(is_type_in_typecache(target, equipment.exclusive_with) || is_type_in_typecache(equipment, target.exclusive_with))
			return equipment

/// Uses the pods power cell if possible
/obj/vehicle/sealed/space_pod/proc/use_power(amount)
	return cell?.use(amount)

/// check if we have enough power
/obj/vehicle/sealed/space_pod/proc/has_enough_power(amount)
	var/obj/item/stock_parts/power_store/cell = get_cell()
	if(isnull(cell))
		return FALSE
	return cell.charge >= amount

/// Does our lock permit this user? If the user cant interact or the lock does not permit it, returns false. If there is no lock or permitted, true.
/obj/vehicle/sealed/space_pod/proc/does_lock_permit_it(mob/user)
	. = FALSE
	if(!user.can_interact_with(src))
		return
	var/list/locks = get_parts_by_type(/obj/item/pod_equipment/lock)
	if(!length(locks))
		return TRUE
	var/obj/item/pod_equipment/lock/lock = locks[1]
	return lock.request_permission(user)
