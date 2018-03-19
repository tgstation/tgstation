/obj/effect/proc_holder/changeling/fakedeath
	name = "Fake Death"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
	chemical_cost = 35
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD

//Fake our own death and fully heal, assuming we're not on fire. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(mob/living/user)
	if(user.stat == DEAD || user.on_fire)
		to_chat(user, "<span class='notice'>We cannot regenerate while dead, or on fire.</span>")
		return
	to_chat(user, "<span class='notice'>We fake our death, preparing energy to arise once more.</span>")
	user.emote("deathgasp")
	user.tod = station_time_timestamp()
	user.fakedeath("changeling") //play dead
	user.update_stat()
	user.update_canmove()

	addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKEDEATH_TIME, TIMER_UNIQUE)
	return TRUE
