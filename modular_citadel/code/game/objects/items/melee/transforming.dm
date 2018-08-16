/obj/item/melee/transforming
	var/total_mass_on //Total mass in ounces when transformed. Primarily for balance purposes. Don't think about it too hard.

/obj/item/melee/transforming/getweight()
	if(total_mass && total_mass_on)
		if(active)
			return max(total_mass_on,MIN_MELEE_STAMCOST)
		else
			return max(total_mass,MIN_MELEE_STAMCOST)
	else
		return initial(w_class)*1.25

/obj/item/melee/transforming/cleaving_saw
	total_mass = 2.75
	total_mass_on = 5
