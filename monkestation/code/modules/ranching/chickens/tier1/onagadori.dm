
/mob/living/simple_animal/chicken/onagadori
	icon_suffix = "onagadori"

	breed_name = "Onagadori"
	egg_type = /obj/item/food/egg/onagadori
	mutation_list = list(/datum/mutation/ranching/chicken/sword)

	book_desc = "Japanese long-tailed chickens, with no unique features aside from its plumage."

/obj/item/food/egg/onagadori
	name = "Onagadori Egg"
	icon_state = "onagadori"

	layer_hen_type = /mob/living/simple_animal/chicken/onagadori
