/datum/material_trait/weak_weapon
	name = "Weak Weapon"
	desc = "Multiplies the weapons force by 0.5 times."

/datum/material_trait/weak_weapon/on_trait_add(atom/movable/parent)
	. = ..()
	if(isobj(parent))
		var/obj/obj = parent
		obj.force *= 0.5
