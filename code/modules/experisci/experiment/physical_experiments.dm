/datum/experiment/physical/meat_wall_explosion
	name = "Extreme Cooking Experiment"
	description = "There has been interest in using our engineering equipment to see what kind of new cooking appliances we can create"

/datum/experiment/physical/meat_wall_explosion/register_events()
	if(!istype(currently_scanned_atom, /turf/closed/wall))
		linked_experiment_handler.announce_message("Incorrect object for experiment.")
		return FALSE

	if(!currently_scanned_atom.custom_materials[SSmaterials.GetMaterialRef(/datum/material/meat)])
		linked_experiment_handler.announce_message("Object is not made out of the correct materials.")
		return FALSE

	RegisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT, .proc/check_experiment)
	linked_experiment_handler.announce_message("Experiment ready to start.")
	return TRUE

/datum/experiment/physical/meat_wall_explosion/unregister_events()
	UnregisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT)

/datum/experiment/physical/meat_wall_explosion/proc/check_experiment(datum/source, obj/projectile/Proj)
	message_admins("test")
	if(istype(Proj, /obj/projectile/beam/emitter))
		finish_experiment(linked_experiment_handler)

/datum/experiment/physical/meat_wall_explosion/finish_experiment(datum/component/experiment_handler/experiment_handler)
	. = ..()
	new /obj/effect/gibspawner/generic(currently_scanned_atom)
	var/turf/meat_wall = currently_scanned_atom
	var/turf/new_turf = meat_wall.ScrapeAway()
	new /obj/effect/gibspawner/generic(new_turf)
	new /obj/item/food/meat/steak/plain(new_turf)
