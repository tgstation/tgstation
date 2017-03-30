/obj/effect/proc_holder/changeling/fakedeath
	name = "Reviving Stasis"
	desc = "We fall into a stasis, allowing us to regenerate and trick our enemies."
	chemical_cost = 15
	dna_cost = 0
	req_dna = 1
	req_stat = DEAD
	max_genetic_damage = 100


//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(mob/living/user)
	to_chat(user, "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>")
	if(user.stat != DEAD)
		user.emote("deathgasp")
		user.tod = worldtime2text()
	user.status_flags |= FAKEDEATH //play dead
	user.update_stat()
	user.update_canmove()

	addtimer(CALLBACK(src, .proc/ready_to_regenerate, user), LING_FAKEDEATH_TIME, TIMER_UNIQUE)

	feedback_add_details("changeling_powers","FD")
	return 1

/obj/effect/proc_holder/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(user && user.mind && user.mind.changeling && user.mind.changeling.purchasedpowers)
		to_chat(user, "<span class='notice'>We are ready to revive.</span>")
		user.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/revive(null)

/obj/effect/proc_holder/changeling/fakedeath/can_sting(mob/user)
	if(user.status_flags & FAKEDEATH)
		to_chat(user, "<span class='warning'>We are already reviving.</span>")
		return
	if(!user.stat) //Confirmation for living changelings if they want to fake their death
		switch(alert("Are we sure we wish to fake our own death?",,"Yes", "No"))
			if("No")
				return
	return ..()
