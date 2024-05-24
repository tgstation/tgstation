/mob/living/basic/chicken/turkey
	name = "\improper turkey"
	desc = "it's that time again."
	breed_name = null
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	speak_emote = list("clucks","gobbles")
	density = FALSE
	health = 15
	maxHealth = 15
	response_harm_continuous = "pecks"
	feedMessages = list("It gobbles up the food voraciously.","It clucks happily.")
	chat_color = "#FFDC9B"
	breed_name_male = "Turkey"
	breed_name_female = "Turkey"

	mutation_list = list()


/mob/living/basic/chicken/turkey/LateInitialize() //reset this as regular chickens override
	. = ..()
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"

/mob/living/basic/chicken/hen/LateInitialize()
	.=..()
	gender = FEMALE
