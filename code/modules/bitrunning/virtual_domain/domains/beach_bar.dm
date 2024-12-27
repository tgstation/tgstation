/datum/lazy_template/virtual_domain/beach_bar
	name = "Beach Bar"
	desc = "A cheerful seaside haven where friendly skeletons serve up drinks. Say, how'd you guys get so dead?"
	completion_loot = list(/obj/item/toy/beach_ball = 1)
	help_text = "This place is running on a skeleton crew, and they don't seem to be too keen to share details. \
	Maybe a few drinks of liquid charm will get the spirits up. As the saying goes, if you can't beat 'em, join 'em."
	key = "beach_bar"
	map_name = "beach_bar"

/datum/lazy_template/virtual_domain/beach_bar/setup_domain(list/created_atoms)
	. = ..()

	for(var/obj/item/reagent_containers/cup/glass/drink in created_atoms)
		RegisterSignal(drink, COMSIG_GLASS_DRANK, PROC_REF(on_drink_drank))

/// Eventually reveal the cache
/datum/lazy_template/virtual_domain/beach_bar/proc/on_drink_drank(datum/source)
	SIGNAL_HANDLER

	add_points(0.5)
