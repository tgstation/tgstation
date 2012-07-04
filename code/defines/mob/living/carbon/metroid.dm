
///mob/living/carbon/alien/larva/metroid

/mob/living/carbon/metroid
	name = "baby metroid"
	icon = 'mob.dmi'
	icon_state = "baby metroid"
	pass_flags = PASSTABLE
	voice_message = "skree!"
	say_message = "hums"

	layer = 5

	maxHealth = 150
	health = 150
	gender = NEUTER

	update_icon = 0
	nutrition = 700 // 1000 = max

	see_in_dark = 8

	// canstun and canweaken don't affect metroids because they ignore stun and weakened variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE

	var/amount_grown = 0// controls how long the metroid has been overfed, if 10, grows into an adult
		// if adult: if 10: reproduces
	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating

	var/mob/living/Victim = null // the person the metroid is currently feeding on

	var/mob/living/Target = null // AI variable - tells the Metroid to hunt this down

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable

	var/cores = 3 // the number of /obj/item/metroid_core's the metroid has left inside

	var/tame = 0 // if set to 1, the Metroid will not eat humans ever, or attack them

	var/rabid = 0 // if set to 1, the Metroid will attack and eat anything it comes in contact with

	var/list/Friends = list() // A list of potential friends
	var/list/FriendsWeight = list() // A list containing values respective to Friends. This determines how many times a Metroid "likes" something. If the Metroid likes it more than 2 times, it becomes a friend

	// Metroids pass on genetic data, so all their offspring have the same "Friends",

/mob/living/carbon/metroid/adult
	name = "adult metroid"
	icon = 'mob.dmi'
	icon_state = "adult metroid"

	health = 200
	gender = NEUTER

	update_icon = 0
	nutrition = 800 // 1200 = max

