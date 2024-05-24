/mob/living/basic/chicken/brown
	icon_suffix = "brown"

	breed_name = "Brown"
	egg_type = /obj/item/food/egg/brown
	chicken_path = /mob/living/basic/chicken/brown
	mutation_list = list(/datum/mutation/ranching/chicken/spicy, /datum/mutation/ranching/chicken/raptor, /datum/mutation/ranching/chicken/gold, /datum/mutation/ranching/chicken/robot) //when i get a better chicken robot will be moved

	book_desc = "These chickens behave the same as White Chickens."
/obj/item/food/egg/brown
	name = "Brown Egg"
	icon_state = "chocolateegg"

	layer_hen_type = /mob/living/basic/chicken/brown
	turf_requirements = list(/turf/open/floor/grass, /turf/open/floor/sandy_dirt)
