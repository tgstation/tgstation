/mob/living/simple_animal/chicken/clown_sad
	icon_suffix = "sad_clown"

	breed_name_male = "huOnkHoNkHoeNK"
	breed_name_female = "huOnkHoNkHoeNK"
	minbodytemp = 0

	ai_controller = /datum/ai_controller/chicken/clown/sad

	egg_type = /obj/item/food/egg/clown_sad
	mutation_list = list()

	unique_ability = CHICKEN_HONK
	cooldown_time = 30 SECONDS
	ability_prob = 25

	book_desc = "These are the product of being incredibly cruel to your Henks. Space PETA would be furious."
/obj/item/food/egg/clown_sad
	name = "Clown? Egg"
	icon_state = "clown"

	layer_hen_type = /mob/living/simple_animal/chicken/clown_sad

/datum/status_effect/ranching/angry_honk
	id = "pissed_sad_clown"
	duration = 5 SECONDS

/datum/status_effect/ranching/angry_honk/on_apply()
	owner.pass_flags |= PASSMOB
	owner.pass_flags |= PASSDOORS
	owner.pass_flags |= PASSGRILLE
	owner.pass_flags |= PASSGLASS
	owner.pass_flags |= PASSCLOSEDTURF
	return ..()

/datum/status_effect/ranching/angry_honk/on_remove()
	owner.pass_flags -= PASSMOB
	owner.pass_flags -= PASSDOORS
	owner.pass_flags -= PASSGRILLE
	owner.pass_flags -= PASSGLASS
	owner.pass_flags -= PASSCLOSEDTURF
