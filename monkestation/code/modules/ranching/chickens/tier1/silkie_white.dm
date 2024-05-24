/mob/living/basic/chicken/silkie_white
	icon_suffix = "silkie_white"

	breed_name = "White Silkie"
	egg_type = /obj/item/food/egg/silkie_white
	mutation_list = list(/datum/mutation/ranching/chicken/snowy)

	book_desc = "Genetically modified as a gag, aside from being a terrible pun they have no other unique properties."

/obj/item/food/egg/silkie_white
	name = "White Selkie Egg"
	icon_state = "silkie_white"

	layer_hen_type = /mob/living/basic/chicken/silkie_white
	turf_requirements = list(/turf/open/floor/grass, /turf/open/floor/sandy_dirt)
