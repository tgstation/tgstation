/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))

		message = sanitize(message)
		if (!message)
			return
		log_say("[key_name(src)] : [message]")
		if (stat == 2)
			return say_dead(message)

		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.victim << "The captive mind of [src] whispers, \"[message]\""

		for (var/mob/M in player_list)
			if (istype(M, /mob/new_player))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				M << "The captive mind of [src] whispers, \"[message]\""

/mob/living/captive_brain/emote(var/message)
	return

/mob/living/captive_brain/verb/resist_control()
	set name = "Resist Control"
	set desc = "Attempt to break free of your borer's control!"
	set category = "Borer"

	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		H << "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately 10 seconds).</span>"
		B.victim << "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>"

		spawn(150)
			if(!B || !B.controlling) return

			B.victim.adjustBrainLoss(rand(5,10))
			H << "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>"
			B.victim << "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>"
			B.detatch()
			verbs -= /mob/living/carbon/proc/release_control
			verbs -= /mob/living/carbon/proc/spawn_larvae

		return

	..()
