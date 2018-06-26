/*Same as normal quirks, but requires a special event to be unlocked. Still costs or takes points. Shouldn't be too powerful, just unique to a spe-
ific event.

To add: Change the unlock variable to something like UNLOCK_ASS, and then add that define to /DEFINES/traits.dm
		Then call client.grant_quirk(UNLOCK_ASS,"you being an ass") on the mob. The first parameter can also just be the quirk datum


Please remove the example quirk (instant death) when adding an unlockable quirk, or don't.
*/
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
	addtimer(CALLBACK(L, /mob/proc/death), 100)
	L.hellbound = TRUE