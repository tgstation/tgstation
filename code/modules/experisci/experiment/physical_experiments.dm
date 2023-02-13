/datum/experiment/physical/meat_wall_explosion
	name = "Extreme Cooking Experiment"
	description = "There has been interest in using our engineering equipment to see what kind of new cooking appliances we can create"

/datum/experiment/physical/meat_wall_explosion/register_events()
	if(!iswallturf(currently_scanned_atom))
		linked_experiment_handler.announce_message("Incorrect object for experiment.")
		return FALSE

	if(!currently_scanned_atom.has_material_type(/datum/material/meat))
		linked_experiment_handler.announce_message("Object is not made out of the correct materials.")
		return FALSE

	RegisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT, PROC_REF(check_experiment))
	linked_experiment_handler.announce_message("Experiment ready to start.")
	return TRUE

/datum/experiment/physical/meat_wall_explosion/unregister_events()
	UnregisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT)

/datum/experiment/physical/meat_wall_explosion/check_progress()
	. += EXPERIMENT_PROG_BOOL("Fire an emitter at a tracked meat wall", is_complete())

/datum/experiment/physical/meat_wall_explosion/proc/check_experiment(datum/source, obj/projectile/Proj)
	SIGNAL_HANDLER
	if(istype(Proj, /obj/projectile/beam/emitter))
		finish_experiment(linked_experiment_handler)

/datum/experiment/physical/meat_wall_explosion/finish_experiment(datum/component/experiment_handler/experiment_handler)
	. = ..()
	new /obj/effect/gibspawner/generic(currently_scanned_atom)
	var/turf/meat_wall = currently_scanned_atom
	var/turf/new_turf = meat_wall.ScrapeAway()
	new /obj/effect/gibspawner/generic(new_turf)
	new /obj/item/food/meat/steak/plain(new_turf)

/datum/experiment/physical/arcade_winner
	name = "Playtesting Experiences"
	description = "How do they make these arcade games so fun? Let's play one and win it to find out."

/datum/experiment/physical/arcade_winner/register_events()
	if(!istype(currently_scanned_atom, /obj/machinery/computer/arcade))
		linked_experiment_handler.announce_message("Incorrect object for experiment.")
		return FALSE

	RegisterSignal(currently_scanned_atom, COMSIG_ARCADE_PRIZEVEND, PROC_REF(win_arcade))
	linked_experiment_handler.announce_message("Experiment ready to start.")
	return TRUE

/datum/experiment/physical/arcade_winner/unregister_events()
	UnregisterSignal(currently_scanned_atom, COMSIG_ARCADE_PRIZEVEND)

/datum/experiment/physical/arcade_winner/check_progress()
	. += EXPERIMENT_PROG_BOOL("Win an arcade game at a tracked arcade cabinet.", is_complete())

/datum/experiment/physical/arcade_winner/proc/win_arcade(datum/source)
	SIGNAL_HANDLER
	finish_experiment(linked_experiment_handler)
