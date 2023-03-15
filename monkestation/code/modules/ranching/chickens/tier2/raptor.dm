/mob/living/simple_animal/chicken/raptor
	icon_suffix = "raptor"

	breed_name = "Raptor"
	breed_name_male = "Tiercel"
	egg_type = /obj/item/food/egg/raptor
	mutation_list = list(/datum/mutation/ranching/chicken/rev_raptor)
	ai_controller = /datum/ai_controller/chicken/hostile
	health = 100
	maxHealth = 100
	melee_damage = 8
	obj_damage = 10

	book_desc = "These creatures are bloodthirsty and will attack everything they are not friends with on site, this includes other chickens."

/obj/item/food/egg/raptor
	name = "Raptor Egg"
	icon_state = "raptor"

	layer_hen_type = /mob/living/simple_animal/chicken/raptor
