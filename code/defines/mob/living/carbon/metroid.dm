
///mob/living/carbon/alien/larva/metroid

/mob/living/carbon/metroid
	name = "baby metroid"
	icon = 'mob.dmi'
	icon_state = "baby metroid"
	pass_flags = PASSTABLE
	voice_message = "chatters"
	say_message = "says"

	health = 250
	gender = NEUTER

	update_icon = 0
	nutrition = 100

	var/amount_grown = 0// controls how long the metroid has been overfed, if 10, grows into an adult
		// if adult: if 10: reproduces
	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating

	var/mob/living/Victim = null // the person the metroid is currently feeding on

/mob/living/carbon/metroid/adult
	name = "adult metroid"
	icon = 'mob.dmi'
	icon_state = "adult metroid"

	health = 300
	gender = NEUTER

	update_icon = 0
	nutrition = 100

