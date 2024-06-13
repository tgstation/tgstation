/datum/material_trait/magical
	name = "Magical"
	desc = "Makes this item magical."
	trait_flags = MATERIAL_NO_STACK_ADD

/datum/material_trait/magical/on_trait_add(atom/movable/parent)
	. = ..()
	parent.AddComponent(/datum/component/fantasy)
	ADD_TRAIT(parent, TRAIT_INNATELY_FANTASTICAL_ITEM, REF(src)) // DO THIS LAST OR WE WILL NEVER GET OUR BONUSES!!!

/datum/material_trait/magical/on_remove(atom/movable/parent)
	REMOVE_TRAIT(parent, TRAIT_INNATELY_FANTASTICAL_ITEM, REF(src)) // DO THIS FIRST OR WE WILL NEVER GET OUR BONUSES DELETED!!!
	qdel(parent.GetComponent(/datum/component/fantasy))
