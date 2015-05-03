/obj/effect/proc_holder/changeling/spike_puff
	name = "Spine Burst"
	desc = "Our pores fire a spine containing the contents of our chemical sacks in every direction, injecting those in range."
	helptext = "Fires a burst of spines that stun anyone in melee range."
	chemical_cost = 40 //Tentative attempt at balance
	dna_cost = 2
	req_human = 1

obj/effect/proc_holder/changeling/spike_puff/sting_action(var/mob/user)
	user << "<span class='notice'>We empty our chemical sack into spines, and fire them.</span>"
	playsound(user.loc, "sound/weapons/slash.ogg" , 50)
	for(var/mob/living/M in range(2, user))
		if(iscarbon(M))
			user.visible_message("<span class='warning'>[M] has been sprayed with toxic spines!</span>")
			if(M.mind || (!M.mind.changeling))
				M.Weaken(5)
		if(issilicon(M))
			user.visible_message("span class='warning'>Toxic spines bounce harmlessly off of [M]'s hard casing!</span>")