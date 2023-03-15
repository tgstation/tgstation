/mob/living/simple_animal/chicken/silkie_black
	icon_suffix = "silkie_black"

	breed_name = "Black Selkie"
	egg_type = /obj/item/food/egg/silkie_black
	mutation_list = list()

	book_desc = "Besides being incredibly cute, these chickens act the same as White Chickens do."

/mob/living/simple_animal/chicken/silkie_black/death(gibbed)
	. = ..()
	if(age >= max_age)
		new /mob/living/simple_animal/chicken/dream(get_turf(src))


/obj/item/food/egg/silkie_black
	name = "Black Selkie Egg"
	icon_state = "silkie_black"

	layer_hen_type = /mob/living/simple_animal/chicken/silkie_black
