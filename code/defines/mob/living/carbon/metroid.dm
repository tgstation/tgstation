
///mob/living/carbon/alien/larva/metroid

/mob/living/carbon/metroid
	name = "baby metroid"
	icon = 'mob.dmi'
	icon_state = "baby metroid"
	pass_flags = PASSTABLE
	voice_message = "skrees!"
	say_message = "says"

	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 800 // 1000 = max

	see_in_dark = 8

	var/amount_grown = 0// controls how long the metroid has been overfed, if 10, grows into an adult
		// if adult: if 10: reproduces
	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating

	var/mob/living/Victim = null // the person the metroid is currently feeding on

	var/mob/living/Target = null // AI variable - tells the Metroid to hunt this down

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable

/mob/living/carbon/metroid/adult
	name = "adult metroid"
	icon = 'mob.dmi'
	icon_state = "adult metroid"

	health = 200
	gender = NEUTER

	update_icon = 0
	nutrition = 1000 // 1200 = max

