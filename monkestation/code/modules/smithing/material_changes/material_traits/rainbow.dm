/datum/material_trait/rainbow
	name = "Rainbow"
	desc = "Makes the material have a cool RGB effect."

/datum/material_trait/rainbow/on_trait_add(atom/movable/parent)
	parent.rainbow_effect()

/datum/material_trait/rainbow/on_remove(atom/movable/parent)
	parent.remove_rainbow_effect()
