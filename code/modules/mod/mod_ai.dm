/obj/item/mod/control/transfer_ai(interaction, mob/user, mob/living/silicon/ai/oldAI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(!open) //mod must be open
		to_chat(user, "<span class='warning'>[name] must be open in order to allow a transfer.</span>")
		return
	switch(interaction)
		if(AI_TRANS_TO_CARD)
			if(!AI)
				to_chat(user, "<span class='warning'>No AI detected in [src].</span>")
				return
			if(!do_after(user, 50, target = src))
				return
			oldAI = AI
			oldAI.ai_restore_power()//So the AI initially has power.
			oldAI.control_disabled = TRUE
			oldAI.radio_enabled = FALSE
			oldAI.disconnect_shell()
			oldAI.forceMove(card)
			card.AI = oldAI
			for(var/datum/action/action in actions)
				if(action.owner == oldAI)
					action.Remove(oldAI)
					qdel(action)
			oldAI.controlled_equipment = null
			oldAI.remote_control = null
			to_chat(oldAI, "<span class='notice'>You have been downloaded to a mobile storage device. Wireless connection offline.</span>")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [oldAI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")
			AI = null

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to the suit.
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
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [cardAI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			ai_enter_mod(cardAI)
			card.AI = null

/obj/item/mod/control/proc/ai_enter_mod(mob/living/silicon/ai/newAI)
	newAI.control_disabled = FALSE
	newAI.radio_enabled = TRUE
	newAI.ai_restore_power()
	newAI.cancel_camera()
	newAI.controlled_equipment = src
	newAI.remote_control = src
	newAI.forceMove(src)
	AI = newAI
	to_chat(newAI, "<span class='notice'>You have been uploaded to a MODsuit's onboard system.</span>")
	for(var/datum/action/action in actions)
		var/datum/action/newaction = action.type
		newaction = new newaction(src)
		newaction.Grant(newAI)

/obj/item/mod/control/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, cooldown_mod_move) || user != AI || !wearer || !wearer.has_gravity()|| !active)
		return FALSE
	var/timemodifier = (direction in GLOB.cardinals) ? 2 : 3
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown)
	playsound(src, 'sound/mecha/mechmove01.ogg', 25, TRUE)
	return step(wearer, direction)
