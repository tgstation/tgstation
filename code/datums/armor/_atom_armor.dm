/// Get the atom's armor reference
/atom/proc/get_armor()
	RETURN_TYPE(/datum/armor)
	return (armor ||= get_armor_by_type(armor_type))

/// Helper to get a specific rating for the atom's armor
/atom/proc/get_armor_rating(damage_type)
	var/datum/armor/armor = get_armor()
	return armor.get_rating(damage_type)

/// Sets the armor of this atom to the specified armor
/atom/proc/set_armor(datum/armor/armor)
	if(src.armor == armor)
		return
	if(!(src.armor?.type in GLOB.armor_by_type))
		qdel(src.armor)
	src.armor = ispath(armor) ? get_armor_by_type(armor) : armor

/// Helper to update the atom's armor to a new armor with the specified rating
/atom/proc/set_armor_rating(damage_type, rating)
	var/datum/armor/armor = get_armor()
	set_armor(armor.generate_new_with_specific(list("[damage_type]" = rating)))
