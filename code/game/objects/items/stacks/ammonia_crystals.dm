/obj/item/stack/ammonia_crystals
	name = "ammonia crystals"
	singular_name = "ammonia crystal"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "ammonia_crystal"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_amount = 50
	merge_type = /obj/item/stack/ammonia_crystals

/obj/item/stack/ammonia_crystals/grind_results()
	return list(/datum/reagent/ammonia = 10)
