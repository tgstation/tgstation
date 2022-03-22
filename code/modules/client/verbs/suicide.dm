/mob/proc/set_suicide(suicide_state)
	suiciding = suicide_state
	if(suicide_state)
		add_to_mob_suicide_list()
	else
		remove_from_mob_suicide_list()

/mob/living/carbon/set_suicide(suicide_state) //you thought that box trick was pretty clever, didn't you? well now hardmode is on, boyo.
	. = ..()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		B.suicided = suicide_state

/mob/living/silicon/robot/set_suicide(suicide_state)
	. = ..()
	if(mmi)
		if(mmi.brain)
			mmi.brain.suicided = suicide_state
		if(mmi.brainmob)
			mmi.brainmob.suiciding = suicide_state

/mob/living/carbon/human/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/oldkey = ckey
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(ckey != oldkey)
		return
	if(!canSuicide())
		return
	if(confirm == "Yes")
		if(suiciding)
			to_chat(src, span_warning("You're already trying to commit suicide!"))
			return
		set_suicide(TRUE) //need to be called before calling suicide_act as fuck knows what suicide_act will do with your suicider
		var/obj/item/held_item = get_active_held_item()
		var/damagetype = SEND_SIGNAL(src, COMSIG_HUMAN_SUICIDE_ACT)
		if(held_item || damagetype)
			if(!damagetype && held_item)
				damagetype = held_item.suicide_act(src)
			if(damagetype)
				if(damagetype & SHAME)
					adjustStaminaLoss(200)
					set_suicide(FALSE)
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "shameful_suicide", /datum/mood_event/shameful_suicide)
					return

				if(damagetype & MANUAL_SUICIDE_NONLETHAL) //Make sure to call the necessary procs if it does kill later
					set_suicide(FALSE)
					return

				suicide_log()

				var/damage_mod = 0
				for(var/T in list(BRUTELOSS, FIRELOSS, TOXLOSS, OXYLOSS))
					damage_mod += (T & damagetype) ? 1 : 0
				damage_mod = max(1, damage_mod)

				//Do 200 damage divided by the number of damage types applied.
				if(damagetype & BRUTELOSS)
					adjustBruteLoss(200/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(200/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(200/damage_mod)

				if(damagetype & OXYLOSS)
					adjustOxyLoss(200/damage_mod)

				if(damagetype & MANUAL_SUICIDE) //Assume the object will handle the death.
					return

				//If something went wrong, just do normal oxyloss
				if(!(damagetype & (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS) ))
					adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				death(FALSE)
				ghostize(FALSE) // Disallows reentering body and disassociates mind

				return

		var/suicide_message

		if(!combat_mode)
			var/obj/item/organ/brain/userbrain = getorgan(/obj/item/organ/brain)
			if(userbrain?.damage >= 75)
				suicide_message = "[src] pulls both arms outwards in front of [p_their()] chest and pumps them behind [p_their()] back, repeats this motion in a smaller range of motion \
						down to [p_their()] hips two times once more all while sliding [p_their()] legs in a faux walking motion, claps [p_their()] hands together \
						in front of [p_them()] while both [p_their()] knees knock together, pumps [p_their()] arms downward, pronating [p_their()] wrists and abducting \
						[p_their()] fingers outward while crossing [p_their()] legs back and forth, repeats this motion again two times while keeping [p_their()] shoulders low\
						and hunching over, does finger guns with right hand and left hand bent on [p_their()] hip while looking directly forward and putting [p_their()] left leg forward then\
						crossing [p_their()] arms and leaning back a little while bending [p_their()] knees at an angle! It looks like [p_theyre()] trying to commit suicide."
			else
				suicide_message = pick("[src] is hugging [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.", \
							"[src] is high-fiving [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.", \
							"[src] is getting too high on life! It looks like [p_theyre()] trying to commit suicide.")
		else
			suicide_message = pick("[src] is attempting to bite [p_their()] tongue off! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is jamming [p_their()] thumbs into [p_their()] eye sockets! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is twisting [p_their()] own neck! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is holding [p_their()] breath! It looks like [p_theyre()] trying to commit suicide.")

		visible_message(span_danger("[suicide_message]"), span_userdanger("[suicide_message]"))

		suicide_log()

		adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind

/mob/living/brain/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."), \
						span_userdanger("[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."))

		suicide_log()

		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind

/mob/living/silicon/ai/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."))

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind

/mob/living/silicon/robot/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."))

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind

/mob/living/silicon/pai/verb/suicide()
	set hidden = TRUE
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(confirm == "Yes")
		var/turf/T = get_turf(src.loc)
		T.visible_message(span_notice("[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\""), null, \
			span_notice("[src] bleeps electronically."))

		suicide_log()

		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind
	else
		to_chat(src, "Aborting suicide attempt.")

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."), \
				span_hear("You hear thrashing."))

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(200 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind

/mob/living/simple_animal/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] begins to fall down. It looks like [p_theyve()] lost the will to live."), \
						span_userdanger("[src] begins to fall down. It looks like [p_theyve()] lost the will to live."))

		suicide_log()

		death(FALSE)
		ghostize(FALSE) // Disallows reentering body and disassociates mind

/mob/living/proc/suicide_log()
	log_message("committed suicide as [src.type]", LOG_ATTACK)

/mob/living/carbon/human/suicide_log()
	log_message("(job: [src.job ? "[src.job]" : "None"]) committed suicide", LOG_ATTACK)

/mob/living/proc/canSuicide()
	var/area/A = get_area(src)
	if(A.area_flags & BLOCK_SUICIDE)
		to_chat(src, span_warning("You can't commit suicide here! You can ghost if you'd like."))
		return
	switch(stat)
		if(CONSCIOUS)
			return TRUE
		if(SOFT_CRIT)
			to_chat(src, span_warning("You can't commit suicide while in a critical condition!"))
		if(UNCONSCIOUS, HARD_CRIT)
			to_chat(src, span_warning("You need to be conscious to commit suicide!"))
		if(DEAD)
			to_chat(src, span_warning("You're already dead!"))
	return

/mob/living/carbon/canSuicide()
	if(!..())
		return
	if(!(mobility_flags & MOBILITY_USE)) //just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, span_warning("You can't commit suicide whilst immobile! ((You can type Ghost instead however.))"))
		return
	return TRUE
