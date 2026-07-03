/datum/lazy_template/virtual_domain/grasslands_hunt
	name = "Луговая охота"
	desc = "Мирная охота в дикой местности."
	help_text = "Как охотник, вы должны уметь выслеживать и убивать свою добычу. Проявите себя."
	is_modular = TRUE
	key = "grasslands_hunt"
	map_name = "grasslands_hunt"
	mob_modules = list(/datum/modular_mob_segment/deer)
	domain_flags = DOMAIN_NO_NOHIT_BONUS


/datum/lazy_template/virtual_domain/grasslands_hunt/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in created_atoms)
		RegisterSignal(landmark, COMSIG_BITRUNNING_MOB_SEGMENT_SPAWNED, PROC_REF(on_spawned))


/// The mob segment has concluded spawning
/datum/lazy_template/virtual_domain/grasslands_hunt/proc/on_spawned(datum/source, list/mobs)
	SIGNAL_HANDLER

	for(var/mob/living/fauna as anything in mobs)
		RegisterSignal(fauna, COMSIG_LIVING_DEATH, PROC_REF(on_death))


/// Handles deer being slain
/datum/lazy_template/virtual_domain/grasslands_hunt/proc/on_death(datum/source)
	SIGNAL_HANDLER

	add_points(3.5)
