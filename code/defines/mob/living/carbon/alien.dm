/mob/living/carbon/alien
	name = "alien"
	voice_name = "alien"
	voice_message = "hisses"
	say_message = "hisses"
	icon = 'alien.dmi'
	gender = NEUTER
	flags = 258.0

	toxloss = 250
	var/alien_invis = 0.0
	var/max_plasma = 500

	alien_talk_understand = 1

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0