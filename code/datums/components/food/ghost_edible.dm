/**
 * Allows ghosts to eat this by orbiting it
 * They do this by consuming the reagents in the object, so if it doesn't have any then it won't work
 */
/datum/component/ghost_edible
	/// Amount of reagents which will be consumed by each bite
	var/bite_consumption
	/// Chance per ghost that a bite will be taken
	var/bite_chance
	/// Minimum size the food will display as before being deleted
	var/minimum_scale
	/// How many reagents this had on initialisation, used to figure out how eaten we are
	var/initial_reagent_volume = 0

/datum/component/ghost_edible/Initialize(bite_consumption = 3, bite_chance = 20, minimum_scale = 0.6)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	if (isnull(atom_parent.reagents) || atom_parent.reagents.total_volume == 0)
		return COMPONENT_INCOMPATIBLE
	src.bite_consumption = bite_consumption
	src.bite_chance = bite_chance
	src.minimum_scale = minimum_scale
	initial_reagent_volume = atom_parent.reagents.total_volume
	notify_ghosts(
		"[parent] is edible by ghosts!",
		source = parent,
		header = "Something Tasty!",
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
	)

/datum/component/ghost_edible/RegisterWithParent()
	START_PROCESSING(SSdcs, src)

/datum/component/ghost_edible/UnregisterFromParent()
	STOP_PROCESSING(SSdcs, src)

/datum/component/ghost_edible/Destroy(force)
	STOP_PROCESSING(SSdcs, src)
	return ..()

/datum/component/ghost_edible/process(seconds_per_tick)
	var/atom/atom_parent = parent
	// Ghosts can eat this burger
	var/munch_chance = 0
	for(var/mob/dead/observer/ghost in atom_parent.orbiters?.orbiter_list)
		munch_chance += bite_chance
		if (munch_chance >= 100)
			break
	if (!prob(munch_chance))
		return
	playsound(atom_parent.loc,'sound/items/eatfood.ogg', vol = rand(10,50), vary = TRUE)
	atom_parent.reagents.remove_all(bite_consumption)
	if (atom_parent.reagents.total_volume <= 0)
		atom_parent.visible_message(span_notice("[atom_parent] disappears completely!"))
		new /obj/item/ectoplasm(atom_parent.loc)
		qdel(parent)
		return

	var/final_transform = matrix().Scale(LERP(minimum_scale, 1, atom_parent.reagents.total_volume / initial_reagent_volume))
	var/animate_transform = matrix(final_transform).Scale(0.8)
	animate(parent, transform = animate_transform, time = 0.1 SECONDS)
	animate(transform = final_transform, time = 0.1 SECONDS)
