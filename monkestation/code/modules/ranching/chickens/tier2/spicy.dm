/mob/living/basic/chicken/spicy
	icon_suffix = "spicy"

	breed_name = "Spicy"
	egg_type = /obj/item/food/egg/spicy
	mutation_list = list(/datum/mutation/ranching/chicken/phoenix)

	book_desc = "Ever since Space Wendy's discontinued Nano-Transen has been working on genetically modified chickens that can produce spicy nuggets, this is the results of their labor."
/obj/item/food/egg/spicy
	name = "Spicy Egg"
	icon_state = "spicy"

	layer_hen_type = /mob/living/basic/chicken/spicy
	low_temp = 350
	high_temp = 450
