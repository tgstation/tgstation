/obj/item/mod/control/transfer_ai(interaction, mob/user, mob/living/silicon/ai/intAI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(!open) //mod must be open
		balloon_alert(user, "suit must be open to transfer!")
		return
	switch(interaction)
		if(AI_TRANS_TO_CARD)
			if(!ai)
				balloon_alert(user, "no AI in suit!")
				return
			balloon_alert(user, "transferring to card...")
			if(!do_after(user, 5 SECONDS, target = src))
				balloon_alert(user, "interrupted!")
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
			balloon_alert(intAI, "transferred to a card")
			balloon_alert("AI transferred to card")
			ai = null

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to the suit.
			intAI = card.AI
			if(!intAI)
				balloon_alert(user, "no AI in card!")
				return
			if(intAI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				intAI.disconnect_shell()
			if(intAI.stat || !intAI.client)
				balloon_alert(user, "AI unresponsive!")
				return
			balloon_alert(user, "transferring to suit...")
			if(!do_after(user, 5 SECONDS, target = src))
				balloon_alert(user, "interrupted!")
				return
			balloon_alert("AI transferred to suit")
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
	balloon_alert(newAI, "transferred to a suit")
	for(var/datum/action/action in actions)
		var/datum/action/newaction = action.type
		newaction = new newaction(src)
		newaction.Grant(newAI)

#define CARDINAL_DELAY 2
#define DIAGONAL_DELAY 3
#define WEARER_DELAY 1
#define LONE_DELAY 5
#define CELL_PER_STEP 25

/obj/item/mod/control/relaymove(mob/user, direction)
	if((!active && wearer) || !cell || cell.charge < CELL_PER_STEP  || user != ai || !COOLDOWN_FINISHED(src, cooldown_mod_move) || (wearer && (HAS_TRAIT(wearer, TRAIT_RESTRAINED) || !wearer.mob_has_gravity())))
		return FALSE
	var/timemodifier = ((direction in GLOB.cardinals) ? CARDINAL_DELAY : DIAGONAL_DELAY) * wearer ? WEARER_DELAY : LONE_DELAY
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown)
	playsound(src, 'sound/mecha/mechmove01.ogg', 25, TRUE)
	cell.charge = max(0, cell.charge - CELL_PER_STEP)
	if(!wearer)
		return step(src, direction)
	return step(wearer, direction)

#undef CARDINAL_DELAY
#undef DIAGONAL_DELAY
#undef WEARER_DELAY
#undef LONE_DELAY
#undef CELL_PER_STEP
