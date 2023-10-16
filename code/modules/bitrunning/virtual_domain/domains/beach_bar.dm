/datum/lazy_template/virtual_domain/beach_bar
	name = "Beach Bar"
	desc = "A cheerful seaside haven where friendly skeletons serve up drinks. Say, how'd you guys get so dead?"
	extra_loot = list(/obj/item/toy/beach_ball = 1)
	help_text = "This place is running on a skeleton crew, and they don't seem to be too keen to share details. \
	Maybe a few drinks of liquid charm will get the spirits up. As the saying goes, if you can't beat 'em, join 'em."
	key = "beach_bar"
	map_name = "beach_bar"
	safehouse_path = /datum/map_template/safehouse/mine

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/virtual_domain
	name = "pina colada"
	desc = "Whose drink is this? Not yours, that's for sure. Well, it's not like they're going to miss it."
	list_reagents = list(/datum/reagent/consumable/ethanol/pina_colada = 30)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/virtual_domain/Initialize(mapload, vol)
	. = ..()

	AddComponent(/datum/component/bitrunning_points, \
		signal_type = COMSIG_GLASS_DRANK, \
		points_per_signal = 0.5, \
	)
