/mob/living/basic/chicken/silkie_black
	icon_suffix = "silkie_black"

	breed_name = "Black Selkie"
	egg_type = /obj/item/food/egg/silkie_black
	mutation_list = list()

	book_desc = "Besides being incredibly cute, these chickens act the same as White Chickens do."

/mob/living/basic/chicken/silkie_black/old_age_death()
	new /mob/living/basic/chicken/dream(get_turf(src))
	. = ..()

/obj/item/food/egg/silkie_black
	name = "Black Selkie Egg"
	icon_state = "silkie_black"

	layer_hen_type = /mob/living/basic/chicken/silkie_black
	turf_requirements = list(/turf/open/floor/grass, /turf/open/floor/sandy_dirt)
