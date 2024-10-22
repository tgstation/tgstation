/datum/storage/portable_chem_mixer
	max_total_storage = 200
	max_slots = 50

/datum/storage/portable_chem_mixer/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	var/static/list/obj/item/reagent_containers/containers = list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/condiment,
	)

	set_holdable(containers)
