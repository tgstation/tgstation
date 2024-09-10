/obj/vehicle/sealed/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)
			to_chat(user, span_danger("Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:"))
			to_chat(user, "[B.get_mecha_info()]")
			break
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='?src=[REF(user)];ai_take_control=[REF(src)]'>[span_userdanger("ASSUME DIRECT CONTROL?")]</a><br>")
		return
	examine(user)
	if(length(return_occupants()) >= max_occupants)
		to_chat(user, span_warning("This exosuit has a pilot and cannot be controlled."))
		return
	var/can_control_mech = FALSE
	for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in trackers)
		can_control_mech = TRUE
		to_chat(user, "[span_notice("[icon2html(src, user)] Status of [name]:")]\n[A.get_mecha_info()]")
		break
	if(!can_control_mech)
		to_chat(user, span_warning("You cannot control exosuits without AI control beacons installed."))
		return
	to_chat(user, "<a href='?src=[REF(user)];ai_take_control=[REF(src)]'>[span_boldnotice("Take control of exosuit?")]</a><br>")

/obj/vehicle/sealed/mecha/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return

	//Transfer from core or card to mech. Proc is called by mech.
	switch(interaction)
		if(AI_TRANS_TO_CARD) //Upload AI from mech to AI card.
			if(!(mecha_flags & PANEL_OPEN)) //Mech must be in maint mode to allow carding.
				to_chat(user, span_warning("[name] must have maintenance protocols active in order to allow a transfer."))
				return
			var/list/ai_pilots = list()
			for(var/mob/living/silicon/ai/aipilot in occupants)
				ai_pilots += aipilot
			if(!length(ai_pilots)) //Mech does not have an AI for a pilot
				to_chat(user, span_warning("No AI detected in the [name] onboard computer."))
				return
			if(length(ai_pilots) > 1) //Input box for multiple AIs, but if there's only one we'll default to them.
				AI = tgui_input_list(user, "Which AI do you wish to card?", "AI Selection", sort_list(ai_pilots))
			else
				AI = ai_pilots[1]
			if(isnull(AI))
				return
			if(!(AI in occupants) || !user.Adjacent(src))
				return //User sat on the selection window and things changed.

			AI.ai_restore_power()//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.radio_enabled = FALSE
			AI.disconnect_shell()
			remove_occupant(AI)
			mecha_flags  &= ~SILICON_PILOT
			AI.forceMove(card)
			card.AI = AI
			AI.controlled_equipment = null
			AI.remote_control = null
			to_chat(AI, span_notice("You have been downloaded to a mobile storage device. Wireless connection offline."))
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")
			return

		if(AI_MECH_HACK) //Called by AIs on the mech
			AI.linked_core = new /obj/structure/ai_core/deactivated(AI.loc)
			AI.linked_core.remote_ai = AI
			if(AI.can_dominate_mechs && LAZYLEN(occupants)) //Oh, I am sorry, were you using that?
				to_chat(AI, span_warning("Occupants detected! Forced ejection initiated!"))
				to_chat(occupants, span_danger("You have been forcibly ejected!"))
				for(var/ejectee in occupants)
					mob_exit(ejectee, silent = TRUE, randomstep = TRUE, forced = TRUE) //IT IS MINE, NOW. SUCK IT, RD!

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			AI = card.AI
			if(!AI)
				to_chat(user, span_warning("There is no AI currently installed on this device."))
				return
			if(AI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				AI.disconnect_shell()
			if(AI.stat || !AI.client)
				to_chat(user, span_warning("[AI.name] is currently unresponsive, and cannot be uploaded."))
				return
			if((LAZYLEN(occupants) >= max_occupants) || dna_lock) //Normal AIs cannot steal mechs!
				to_chat(user, span_warning("Access denied. [name] is [LAZYLEN(occupants) >= max_occupants ? "currently fully occupied" : "secured with a DNA lock"]."))
				return
			AI.control_disabled = FALSE
			AI.radio_enabled = TRUE
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			card.AI = null
	ai_enter_mech(AI)

///Hack and From Card interactions share some code, so leave that here for both to use.
/obj/vehicle/sealed/mecha/proc/ai_enter_mech(mob/living/silicon/ai/AI)
	AI.ai_restore_power()
	mecha_flags |= SILICON_PILOT
	moved_inside(AI)
	AI.eyeobj?.forceMove(src)
	AI.eyeobj?.RegisterSignal(src, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/camera/ai_eye, update_visibility))
	AI.controlled_equipment = src
	AI.remote_control = src
	AI.ShutOffDoomsdayDevice()
	add_occupant(AI)
	to_chat(AI, AI.can_dominate_mechs ? span_greenannounce("Takeover of [name] complete! You are now loaded onto the onboard computer. Do not attempt to leave the station sector!") :\
		span_notice("You have been uploaded to a mech's onboard computer."))
	to_chat(AI, "<span class='reallybig boldnotice'>Use Middle-Mouse or the action button in your HUD to toggle equipment safety. Clicks with safety enabled will pass AI commands.</span>")
