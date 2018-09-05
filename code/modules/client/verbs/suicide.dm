/mob/var/suiciding = 0

/mob/living/carbon/human/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/oldkey = ckey
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(ckey != oldkey)
		return
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = TRUE
		var/obj/item/held_item = get_active_held_item()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(damagetype)
				if(damagetype & SHAME)
					adjustStaminaLoss(200)
					suiciding = FALSE
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "shameful_suicide", /datum/mood_event/shameful_suicide)
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

				if(damagetype & MANUAL_SUICIDE)	//Assume the object will handle the death.
					return

				//If something went wrong, just do normal oxyloss
				if(!(damagetype & (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS) ))
					adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				death(FALSE)

				return

		var/suicide_message

		if(a_intent == INTENT_DISARM)
			suicide_message = pick("[src] is attempting to push [p_their()] own head off [p_their()] shoulders! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is pushing [p_their()] thumbs into [p_their()] eye sockets! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is ripping [p_their()] own arms off! It looks like [p_theyre()] trying to commit suicide.")//heheh get it?
		if(a_intent == INTENT_GRAB)
			suicide_message = pick("[src] is attempting to pull [p_their()] own head off! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is aggressively grabbing [p_their()] own neck! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is pulling [p_their()] eyes out of their sockets! It looks like [p_theyre()] trying to commit suicide.")
		if(a_intent == INTENT_HELP)
			suicide_message = pick("[src] is hugging [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is high-fiving [p_them()]self to death! It looks like [p_theyre()] trying to commit suicide.", \
									"[src] is getting too high on life! It looks like [p_theyre()] trying to commit suicide.")
		else
			suicide_message = pick("[src] is attempting to bite [p_their()] tongue off! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is jamming [p_their()] thumbs into [p_their()] eye sockets! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is twisting [p_their()] own neck! It looks like [p_theyre()] trying to commit suicide.", \
								"[src] is holding [p_their()] breath! It looks like [p_theyre()] trying to commit suicide.")

		visible_message("<span class='danger'>[suicide_message]</span>", "<span class='userdanger'>[suicide_message]</span>")

		suicide_log()

		adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(0)

/mob/living/brain/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live.</span>", \
						"<span class='userdanger'>[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live.</span>")

		suicide_log()

		death(0)

/mob/living/carbon/monkey/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is attempting to bite [p_their()] tongue. It looks like [p_theyre()] trying to commit suicide.</span>", \
				"<span class='userdanger'>[src] is attempting to bite [p_their()] tongue. It looks like [p_theyre()] trying to commit suicide.</span>")

		suicide_log()

		adjustOxyLoss(max(200- getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(0)

/mob/living/silicon/ai/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is powering down. It looks like [p_theyre()] trying to commit suicide.</span>", \
				"<span class='userdanger'>[src] is powering down. It looks like [p_theyre()] trying to commit suicide.</span>")

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(0)

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is powering down. It looks like [p_theyre()] trying to commit suicide.</span>", \
				"<span class='userdanger'>[src] is powering down. It looks like [p_theyre()] trying to commit suicide.</span>")

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(0)

/mob/living/silicon/pai/verb/suicide()
	set hidden = 1
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(confirm == "Yes")
		var/turf/T = get_turf(src.loc)
		T.visible_message("<span class='notice'>[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"</span>", null, \
		 "<span class='notice'>[src] bleeps electronically.</span>")

		suicide_log()

		death(0)
	else
		to_chat(src, "Aborting suicide attempt.")

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide.</span>", \
				"<span class='userdanger'>[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide.</span>", \
				"<span class='italics'>You hear thrashing.</span>")

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(200 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(0)

/mob/living/simple_animal/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] begins to fall down. It looks like [p_theyve()] lost the will to live.</span>", \
						"<span class='userdanger'>[src] begins to fall down. It looks like [p_theyve()] lost the will to live.</span>")

		suicide_log()

		death(0)

/mob/living/proc/suicide_log()
	log_game("[key_name(src)] committed suicide at [AREACOORD(src)] as [src.type].")

/mob/living/carbon/human/suicide_log()
	log_game("[key_name(src)] (job: [src.job ? "[src.job]" : "None"]) committed suicide at [AREACOORD(src)].")

/mob/living/proc/canSuicide()
	switch(stat)
		if(CONSCIOUS)
			return TRUE
		if(SOFT_CRIT)
			to_chat(src, "You can't commit suicide while in a critical condition!")
		if(UNCONSCIOUS)
			to_chat(src, "You need to be conscious to commit suicide!")
		if(DEAD)
			to_chat(src, "You're already dead!")
	return

/mob/living/carbon/canSuicide()
	if(!..())
		return
	if(IsStun() || IsKnockdown())	//just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, "You can't commit suicide while stunned! ((You can type Ghost instead however.))")
		return
	if(restrained())
		to_chat(src, "You can't commit suicide while restrained! ((You can type Ghost instead however.))")
		return
	return TRUE
