/datum/experiment/physical/meat_wall_explosion
	name = "Экстремальная кулинария"
	description = "Мы заинтересованы в использовании нашего инженерного оборудования, чтобы увидеть, какие новые кухонные приборы мы можем создать."

/datum/experiment/physical/meat_wall_explosion/register_events()
	if(!iswallturf(currently_scanned_atom))
		linked_experiment_handler.announce_message("Неподходящий объект для эксперимента.")
		return FALSE

	if(!currently_scanned_atom.has_material_type(/datum/material/meat))
		linked_experiment_handler.announce_message("Предмет изготовлен не из тех материалов.")
		return FALSE

	RegisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT, PROC_REF(check_experiment))
	linked_experiment_handler.announce_message("Эксперимент готов к началу.")
	return TRUE

/datum/experiment/physical/meat_wall_explosion/unregister_events()
	UnregisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT)

/datum/experiment/physical/meat_wall_explosion/check_progress()
	. += EXPERIMENT_PROG_BOOL("Выстрелите в отслеживаемую мясную стену", is_complete())

/datum/experiment/physical/meat_wall_explosion/proc/check_experiment(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	if(istype(proj, /obj/projectile/beam/emitter))
		UnregisterSignal(currently_scanned_atom, COMSIG_ATOM_BULLET_ACT)
		finish_experiment(linked_experiment_handler)

/datum/experiment/physical/meat_wall_explosion/finish_experiment(datum/component/experiment_handler/experiment_handler, datum/techweb/linked_web_override)
	. = ..()
	new /obj/effect/gibspawner/generic(currently_scanned_atom)
	var/turf/meat_wall = currently_scanned_atom
	var/turf/new_turf = meat_wall.ScrapeAway()
	new /obj/effect/gibspawner/generic(new_turf)
	new /obj/item/food/meat/steak/plain(new_turf)

/datum/experiment/physical/arcade_winner
	name = "Опыты игровых тестов"
	description = "Как им удается делать эти аркадные игры такими увлекательными? Давайте сыграем в одну из них и выиграем, чтобы узнать это."

/datum/experiment/physical/arcade_winner/register_events()
	if(!istype(currently_scanned_atom, /obj/machinery/computer/arcade))
		linked_experiment_handler.announce_message("Неподходящий объект для эксперимента.")
		return FALSE

	RegisterSignal(currently_scanned_atom, COMSIG_ARCADE_VICTORY, PROC_REF(win_arcade))
	linked_experiment_handler.announce_message("Эксперимент готов к началу.")
	return TRUE

/datum/experiment/physical/arcade_winner/unregister_events()
	UnregisterSignal(currently_scanned_atom, COMSIG_ARCADE_VICTORY)

/datum/experiment/physical/arcade_winner/check_progress()
	. += EXPERIMENT_PROG_BOOL("Выиграйте аркадную игру в отслеживаемом игровом зале.", is_complete())

/datum/experiment/physical/arcade_winner/proc/win_arcade(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(currently_scanned_atom, COMSIG_ARCADE_VICTORY)
	finish_experiment(linked_experiment_handler)
