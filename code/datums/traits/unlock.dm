/datum/quirk/death
	name = "Instant-Death"
	desc = "Tired of suiciding every round? Then this quirk is just for you! It kills you! And you'll never come back!"
	value = -2 //worth it
	mob_trait = TRAIT_DEATH
	unlock = UNLOCK_DEATH
	gain_text = "<span class='notice'>Mr. Stark, I don't feel so good...</span>"
	lose_text = "<span class='notice'>Not like it matters anymore.</span>"
	medical_record_text = "Patient suffers from spontanious, uncurable, death."

/datum/quirk/death/on_spawn()
	if(!isliving(quirk_holder))
		return
	var/mob/living/L = quirk_holder
	addtimer(CALLBACK(L, .proc/death), 100)