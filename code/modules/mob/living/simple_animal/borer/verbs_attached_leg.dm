/obj/item/verbs/borer/attached_leg/verb/borer_speak(var/message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your bretheren"

	if(!message)
		return

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.borer_speak(message)

/obj/item/verbs/borer/attached_leg/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.evolve()

/obj/item/verbs/borer/attached_leg/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_leg/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.abandon_host()

/obj/item/verbs/borer/attached_leg/speed_increase/verb/speed_increase()
	set category = "Alien"
	set name = "Speed Increase"
	set desc = "Expend chemicals constantly in order to elevate the performance of the limb in which you reside."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.speed_increase()

/mob/living/simple_animal/borer/proc/speed_increase()
	set category = "Alien"
	set name = "Speed Increase"
	set desc = "Expend chemicals constantly in order to elevate the performance of the limb in which you reside."

	var/speed_increase = 0.1

	if(!check_can_do(0))
		return

	if(channeling && !channeling_speed_increase)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to elevate the performance of your host's [limb_to_name(hostlimb)].")
		channeling = 0
		channeling_speed_increase = 0
	else if(chemicals < 5)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		to_chat(host, "<span class='notice'>You feel the muscles in your [hostlimb == LIMB_RIGHT_LEG ? "right" : "left"] leg pulse.</span>")
		to_chat(src, "You begin to focus your efforts on elevating the performance of your host's [limb_to_name(hostlimb)].")
		channeling = 1
		channeling_speed_increase = 1
		host.movement_speed_modifier += speed_increase
		spawn()
			var/time_spent_channeling = 0
			while(chemicals >=5 && channeling && channeling_speed_increase)
				chemicals -= 5
				time_spent_channeling++
				sleep(10)
			to_chat(host, "<span class='notice'>It feels like the muscles in your [hostlimb == LIMB_RIGHT_LEG ? "right" : "left"] leg have returned to normal.</span>")
			host.movement_speed_modifier -= speed_increase
			channeling = 0
			channeling_speed_increase = 0
			var/showmessage = 0
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			passout(time_spent_channeling, showmessage)

/obj/item/verbs/borer/attached_leg/bone_talons/verb/bone_talons()
	set category = "Alien"
	set name = "Bone Talons"
	set desc = "Expend chemicals constantly in order to support the growth of strong bony talons on your host's foot."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B)) return
	B.bone_talons()

/mob/living/simple_animal/borer/proc/bone_talons()
	set category = "Alien"
	set name = "Bone Talons"
	set desc = "Expend chemicals constantly in order to support the growth of strong bony talons on your host's foot."

	var/synergy = 0 //Bone talons decrease the host's speed unless two borers are channeling it simultaneously.
	var/speed_penalty = 0.2

	if(!istype(host, /mob/living/carbon))
		to_chat(src, "<span class='warning'>You can't seem to alter your host's strange biology.</span>")
		return

	if(!check_can_do(0))
		return

	if(channeling && !channeling_bone_talons)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to elevate the performance of your host's [limb_to_name(hostlimb)].")
		channeling = 0
		channeling_bone_talons = 0
	else if(chemicals < 3)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		to_chat(host, "<span class='notice'>Bony talons have grown out of your [hostlimb == LIMB_RIGHT_LEG ? "right" : "left"] foot.</span>")
		to_chat(src, "You begin to focus your efforts on elevating the performance of your host's [limb_to_name(hostlimb)].")
		channeling = 1
		channeling_bone_talons = 1
		var/mob/living/simple_animal/borer/B = null
		host.unslippable = 1
		spawn()
			var/time_spent_channeling = 0
			while(chemicals >=3 && channeling && channeling_bone_talons)
				if(hostlimb == LIMB_RIGHT_LEG)
					if(host.has_brain_worms(LIMB_LEFT_LEG))
						B = host.has_brain_worms(LIMB_LEFT_LEG)
						if(B.channeling && B.channeling_bone_talons)
							synergy = 1
						else
							synergy = 0
				else
					if(host.has_brain_worms(LIMB_RIGHT_LEG))
						B = host.has_brain_worms(LIMB_RIGHT_LEG)
						if(B.channeling && B.channeling_bone_talons)
							synergy = 1
						else
							synergy = 0
				if(synergy)
					if(host.has_penalized_speed)
						host.movement_speed_modifier += speed_penalty
						host.has_penalized_speed = 0
				else
					if(!host.has_penalized_speed)
						host.movement_speed_modifier -= speed_penalty
						host.has_penalized_speed = 1

				chemicals -= 3
				time_spent_channeling++
				sleep(10)
			if(host.has_penalized_speed)
				if(!(B && B.channeling && B.channeling_bone_talons))
					host.movement_speed_modifier += speed_penalty
			to_chat(host, "<span class='notice'>The bony talons on your [hostlimb == LIMB_RIGHT_LEG ? "right" : "left"] foot crumble into nothing.</span>")
			if(!(B && B.channeling && B.channeling_bone_talons))
				host.unslippable = 0
			channeling = 0
			channeling_bone_talons = 0
			var/showmessage = 0
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
			else
				showmessage = 1
			time_spent_channeling = min(time_spent_channeling, 30)
			passout(time_spent_channeling, showmessage)