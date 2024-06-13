/mob/living/basic/chicken/ixworth
	icon_suffix = "ixworth"

	breed_name = "Ixworth"
	egg_type = /obj/item/food/egg/ixworth
	mutation_list = list()
	liked_foods = list(/obj/item/food/grown/tomato = 2)

	book_desc = "A very stylish breed."
/obj/item/food/egg/ixworth
	name = "Ixworth Egg"
	icon_state = "ixworth"

	layer_hen_type = /mob/living/basic/chicken/ixworth
	turf_requirements = list(/turf/open/floor/grass, /turf/open/floor/sandy_dirt)
