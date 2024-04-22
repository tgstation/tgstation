/datum/material_trait/stamina_draining
	name = "Cumbersome"
	desc = "Multiplies the stamina cost by 1.5 times."
	reforges = 6

/datum/material_trait/stamina_draining/on_trait_add(atom/movable/parent)
	. = ..()
	if(isitem(parent))
		var/obj/item/item = parent
		item.stamina_cost *= 1.5
		item.stamina_cost = round(item.stamina_cost)

/datum/material_trait/stamina_draining/on_remove(atom/movable/parent)
	if(isitem(parent))
		var/obj/item/item = parent
		item.stamina_cost /= 1.5
		item.stamina_cost = round(item.stamina_cost)
