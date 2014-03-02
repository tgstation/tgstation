/obj/effect/proc_holder/changeling/fakedeath
	name = "Regenerative Stasis"
	desc = "We fall into a stasis, allowing us to regenerate."
	chemical_cost = 10
	dna_cost = 0
	req_stat = DEAD
	max_genetic_damage = 100


//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/obj/effect/proc_holder/changeling/fakedeath/sting_action(var/mob/living/user)

	user << "<span class='notice'>We begin our stasis, preparing energy to arise once more.</span>"

	user.status_flags |= FAKEDEATH		//play dead
	user.update_canmove()

	if(user.stat != DEAD)
		user.emote("deathgasp")
		user.tod = worldtime2text()

	spawn(800)
		if(user && user.mind && user.mind.changeling && user.mind.changeling.purchasedpowers)
			user << "<span class='notice'>We are ready to regenerate.</span>"
			user.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/revive(null)

	feedback_add_details("changeling_powers","FD")
	return 1

/obj/effect/proc_holder/changeling/fakedeath/can_sting(var/mob/user)
	if(user.status_flags & FAKEDEATH)
		return
	if(!user.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changelings if they want to fake their death
		return
	return ..()