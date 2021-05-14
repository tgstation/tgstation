/obj/item/mod/control/transfer_ai(interaction, mob/user, mob/living/silicon/ai/intAI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(!open) //mod must be open
		to_chat(user, "<span class='warning'>[src] must be open in order to allow a transfer.</span>")
		return
	switch(interaction)
		if(AI_TRANS_TO_CARD)
			if(!ai)
				to_chat(user, "<span class='warning'>No AI detected in [src].</span>")
				return
			if(!do_after(user, 5 SECONDS, target = src))
				return
			intAI = ai
			intAI.ai_restore_power()//So the AI initially has power.
			intAI.control_disabled = TRUE
			intAI.radio_enabled = FALSE
			intAI.disconnect_shell()
			intAI.forceMove(card)
			card.AI = intAI
			for(var/datum/action/action as anything in actions)
				if(action.owner == intAI)
					action.Remove(intAI)
					qdel(action)
			intAI.controlled_equipment = null
			intAI.remote_control = null
			to_chat(intAI, "<span class='notice'>You have been downloaded to a mobile storage device. Wireless connection offline.</span>")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [intAI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")
			ai = null

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to the suit.
			intAI = card.AI
			if(!intAI)
				to_chat(user, "<span class='warning'>There is no AI currently installed on this device.</span>")
				return
			if(intAI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				intAI.disconnect_shell()
			if(intAI.stat || !intAI.client)
				to_chat(user, "<span class='warning'>[intAI.name] is currently unresponsive, and cannot be uploaded.</span>")
				return
			if(!do_after(user, 5 SECONDS, target = src))
				return
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [intAI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			ai_enter_mod(intAI)
			card.AI = null

/obj/item/mod/control/proc/ai_enter_mod(mob/living/silicon/ai/newAI)
	newAI.control_disabled = FALSE
	newAI.radio_enabled = TRUE
	newAI.ai_restore_power()
	newAI.cancel_camera()
	newAI.controlled_equipment = src
	newAI.remote_control = src
	newAI.forceMove(src)
	ai = newAI
	to_chat(newAI, "<span class='notice'>You have been uploaded to a MODsuit's onboard system.</span>")
	for(var/datum/action/action in actions)
		var/datum/action/newaction = action.type
		newaction = new newaction(src)
		newaction.Grant(newAI)

/obj/item/mod/control/relaymove(mob/user, direction)
	if(!active && wearer || user != ai || !COOLDOWN_FINISHED(src, cooldown_mod_move) || wearer && HAS_TRAIT(wearer, TRAIT_RESTRAINED) || !cell.charge <= 0 || !has_gravity(get_turf(src)))
		return FALSE
	var/timemodifier = ((direction in GLOB.cardinals) ? 2 : 3) * wearer ? 1 : 5
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown)
	playsound(src, 'sound/mecha/mechmove01.ogg', 25, TRUE)
	cell.charge = max(0, cell.charge - 25)
	if(!wearer)
		return step(src, direction)
	return step(wearer, direction)
