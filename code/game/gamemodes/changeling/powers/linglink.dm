/obj/effect/proc_holder/changeling/linglink
	name = "Hivemind Link"
	desc = "Link your victim's mind into the hivemind for personal interrogation"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1

/obj/effect/proc_holder/changeling/linglink/can_sting(mob/living/carbon/user)
	if(!..())
		return
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.islinking)
		to_chat(user, "<span class='warning'>We have already formed a link with the victim!</span>")
		return
	if(!user.pulling)
		to_chat(user, "<span class='warning'>We must be tightly grabbing a creature to link with them!</span>")
		return
	if(!iscarbon(user.pulling))
		to_chat(user, "<span class='warning'>We cannot link with this creature!</span>")
		return
	var/mob/living/carbon/target = user.pulling
	if(!target.mind)
		to_chat(user, "<span class='warning'>The victim has no mind to link to!</span>")
		return
	if(target.stat == DEAD)
		to_chat(user, "<span class='warning'>The victim is dead, you cannot link to a dead mind!</span>")
		return
	if(target.mind.changeling)
		to_chat(user, "<span class='warning'>The victim is already a part of the hivemind!</span>")
		return
	if(user.grab_state <= GRAB_AGGRESSIVE)
		to_chat(user, "<span class='warning'>We must have a tighter grip to link with this creature!</span>")
		return
	return changeling.can_absorb_dna(user,target)

/obj/effect/proc_holder/changeling/linglink/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/mob/living/carbon/human/target = user.pulling
	changeling.islinking = 1
	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(user, "<span class='notice'>We stealthily stab [target] with a minor proboscis...</span>")
				to_chat(target, "<span class='userdanger'>You experience a stabbing sensation and your ears begin to ring...</span>")
			if(3)
				to_chat(user, "<span class='notice'>We mold the [target]'s mind like clay, granting [target.p_them()] the ability to speak in the hivemind!</span>")
				to_chat(target, "<span class='userdanger'>A migraine throbs behind your eyes, you hear yourself screaming - but your mouth has not opened!</span>")
				for(var/mob/M in GLOB.mob_list)
					if(M.lingcheck() == 2)
						to_chat(M, "<i><font color=#800080>We can sense a foreign presence in the hivemind...</font></i>")
				target.mind.linglink = 1
				target.say(":g AAAAARRRRGGGGGHHHHH!!")
				to_chat(target, "<font color=#800040><span class='boldannounce'>You can now communicate in the changeling hivemind, say \":g message\" to communicate!</span>")
				target.reagents.add_reagent("salbutamol", 40) // So they don't choke to death while you interrogate them
				sleep(1800)
		SSblackbox.add_details("changeling_powers","Hivemind Link|[i]")
		if(!do_mob(user, target, 20))
			to_chat(user, "<span class='warning'>Our link with [target] has ended!</span>")
			changeling.islinking = 0
			target.mind.linglink = 0
			return

	changeling.islinking = 0
	target.mind.linglink = 0
	to_chat(user, "<span class='notice'>You cannot sustain the connection any longer, your victim fades from the hivemind</span>")
	to_chat(target, "<span class='userdanger'>The link cannot be sustained any longer, your connection to the hivemind has faded!</span>")
