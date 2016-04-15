/mob/living/carbon/monkey/rock
	name = "rock"
	voice_name = "rock"
	speak_emote = list("grinds")
	icon_state = "rock1"
	meat_type = /obj/item/weapon/ore/diamond
	species_type = /mob/living/carbon/monkey/rock

	mob_bump_flag = MONKEY
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL|ALIEN

	canWearClothes = 0
	canWearHats = 1
	canWearGlasses = 1
	greaterform = "Golem"

/mob/living/carbon/monkey/rock/New()
	..()
	add_language("Golem")
	default_language = all_languages["Golem"]
