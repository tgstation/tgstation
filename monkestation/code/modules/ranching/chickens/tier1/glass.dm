/mob/living/basic/chicken/glass
	icon_suffix = "glass"

	breed_name = "Glass"
	egg_type = /obj/item/food/egg/glass
	mutation_list = list(/datum/mutation/ranching/chicken/wiznerd, /datum/mutation/ranching/chicken/stone)

	book_desc = "Fragile as glass, but produces the chemical injected into its egg overtime."
/obj/item/food/egg/glass
	name = "Glass Egg"
	food_reagents = list()
	max_volume = 5
	icon_state = "glass"

	layer_hen_type = /mob/living/basic/chicken/glass
