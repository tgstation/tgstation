/* Hippie Neutral Traits */

/datum/trait/super_lungs
	name = "Super Lungs"
	desc = "Your extra powerful lungs allow you to scream much louder than normal."
	value = 0
	gain_text = "<span class='notice'>You feel like you can scream louder than normal.</span>"
	lose_text = "<span class='notice'>You feel unable to scream as loudly as before.</span>"

/datum/trait/super_lungs/add()
	var/mob/living/carbon/human/H = trait_holder
	H.scream_vol = 100
	H.scream_oxyloss = 10