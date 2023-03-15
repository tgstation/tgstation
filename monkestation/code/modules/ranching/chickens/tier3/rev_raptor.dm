/mob/living/simple_animal/chicken/rev_raptor
	icon_suffix = "rev_raptor"

	breed_name = "Revolutionary Raptor"
	breed_name_male = "Revolutionary Tiercel"
	egg_type = /obj/item/food/egg/raptor

	ai_controller = /datum/ai_controller/chicken/hostile
	health = 150
	maxHealth = 100
	melee_damage = 6
	obj_damage = 10

	unique_ability = CHICKEN_REV
	ability_prob = 5

	book_desc = "This is what happens when we let the raptors learn from the stations crew."

/obj/item/food/egg/rev_raptor
	name = "Revolutionary Egg"
	icon_state = "rev_raptor"

	layer_hen_type = /mob/living/simple_animal/chicken/rev_raptor
