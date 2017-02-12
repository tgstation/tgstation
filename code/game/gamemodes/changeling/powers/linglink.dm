/obj/effect/proc_holder/changeling/linglink
	name = "Hivemind Link"
	desc = "Link your victim's mind into the hivemind for personal interrogation"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/linglink/can_sting(mob/living/carbon/user)
	if(!..())
		return
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.islinking)
		user << "<span class='warning'>We have already formed a link with the victim!</span>"
		return
	if(!user.pulling)
		user << "<span class='warning'>We must be tightly grabbing a creature to link with them!</span>"
		return
	if(!iscarbon(user.pulling))
		user << "<span class='warning'>We cannot link with this creature!</span>"
		return
	var/mob/living/carbon/target = user.pulling
	if(!target.mind)
		user << "<span class='warning'>The victim has no mind to link to!</span>"
		return
	if(target.stat == DEAD)
		user << "<span class='warning'>The victim is dead, you cannot link to a dead mind!</span>"
		return
	if(target.mind.changeling)
		user << "<span class='warning'>The victim is already a part of the hivemind!</span>"
		return
	if(user.grab_state <= GRAB_AGGRESSIVE)
		user << "<span class='warning'>We must have a tighter grip to link with this creature!</span>"
		return
	return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/linglink/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/mob/living/carbon/human/target = user.pulling
	changeling.islinking = 1
	for(var/i in 1 to 3)
		switch(i)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user << "<span class='notice'>We stealthily stab [target] with a minor proboscis...</span>"
				target << "<span class='userdanger'>You experience a stabbing sensation and your ears begin to ring...</span>"
			if(3)
				user << "<span class='notice'>We mold the [target]'s mind like clay, granting [target.p_them()] the ability to speak in the hivemind!</span>"
				target << "<span class='userdanger'>A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!</span>"
				for(var/mob/M in mob_list)
					if(M.lingcheck() == 2)
						M << "<i><font color=#800080>We can sense a foreign presence in the hivemind...</font></i>"
				target.mind.linglink = 1
				target.say(":g AAAAARRRRGGGGGHHHHH!!")
				target << "<font color=#800040><span class='boldannounce'>You can now communicate in the changeling hivemind, say \":g message\" to communicate!</span>"
				target.reagents.add_reagent("salbutamol", 40) // So they don't choke to death while you interrogate them
				sleep(1800)
		feedback_add_details("changeling_powers","A [i]")
		if(!do_mob(user, target, 20))
			user << "<span class='warning'>Our link with [target] has ended!</span>"
			changeling.islinking = 0
			target.mind.linglink = 0
			return

	changeling.islinking = 0
	target.mind.linglink = 0
	user << "<span class='notice'>You cannot sustain the connection any longer, your victim fades from the hivemind</span>"
	target << "<span class='userdanger'>The link cannot be sustained any longer, your connection to the hivemind has faded!</span>"
