/obj/item/rig/control/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(!open) //rig must be open
		to_chat(user, "<span class='warning'>[name] must be open in order to allow a transfer.</span>")
		return
	switch(interaction)
		if(AI_TRANS_TO_CARD)
			if(!AI) //Mech does not have an AI for a pilot
				to_chat(user, "<span class='warning'>No AI detected in [src].</span>")
				return
			if(!do_after(user, 50, target = src))
				return
			AI.ai_restore_power()//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.radio_enabled = FALSE
			AI.disconnect_shell()
			AI.forceMove(card)
			card.AI = AI
			for(var/datum/action/action in actions)
				if(action.owner == AI)
					action.Remove(AI)
					qdel(action)
			AI.controlled_equipment = null
			AI.remote_control = null
			to_chat(AI, "<span class='notice'>You have been downloaded to a mobile storage device. Wireless connection offline.</span>")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")
			AI = null

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			var/mob/living/silicon/ai/cardAI = card.AI
			if(!cardAI)
				to_chat(user, "<span class='warning'>There is no AI currently installed on this device.</span>")
				return
			if(cardAI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				cardAI.disconnect_shell()
			if(cardAI.stat || !cardAI.client)
				to_chat(user, "<span class='warning'>[cardAI.name] is currently unresponsive, and cannot be uploaded.</span>")
				return
			if(!do_after(user, 50, target = src))
				return
			cardAI.control_disabled = FALSE
			cardAI.radio_enabled = TRUE
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [cardAI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			ai_enter_rig(cardAI)
			card.AI = null

/obj/item/rig/control/proc/ai_enter_rig(mob/living/silicon/ai/newAI)
	newAI.ai_restore_power()
	newAI.cancel_camera()
	newAI.controlled_equipment = src
	newAI.remote_control = src
	newAI.mobility_flags = ALL //Much easier than adding AI checks! Be sure to set this back to 0 if you decide to allow an AI to leave a RIG somehow.
	newAI.forceMove(src)
	AI = newAI
	to_chat(newAI, "<span class='notice'>You have been uploaded to a RIGsuit's onboard system.</span>")
	for(var/datum/action/action in actions)
		var/datum/action/newaction = action.type
		newaction = new newaction(src)
		newaction.Grant(newAI)

/obj/item/rig/control/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, cooldown_rig_move) || user != AI || !wearer || !(wearer.mobility_flags & MOBILITY_STAND))
		return FALSE
	COOLDOWN_START(src, cooldown_rig_move, movedelay)
	return step(wearer, direction)
