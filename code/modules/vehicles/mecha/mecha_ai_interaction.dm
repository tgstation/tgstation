/obj/vehicle/sealed/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return

	var/obj/item/mecha_parts/mecha_tracking/data_tracker = null
	var/obj/item/mecha_parts/mecha_tracking/ai_control/control_tracker = null
	var/list/output = list()

	for(var/obj/item/mecha_parts/mecha_tracking/A in trackers)
		data_tracker = A
		break

	for(var/obj/item/mecha_parts/mecha_tracking/ai_control/B in trackers)
		control_tracker = B
		break

	if(!data_tracker)
		to_chat(user, span_warning("You cannot interface this exosuit without tracking beacons installed."))
		return

	if(data_tracker || user.can_dominate_mechs)
		output += span_notice("[icon2html(src, user)] [name] Exosuit Status Report\n")
		output += data_tracker.get_mecha_info()

	if(user.can_dominate_mechs)
		if(data_tracker)
			output += span_danger("\nWarning: Tracking detected. Enter at your own risk.")

	if(user.can_dominate_mechs)
		output += "\n<a href='byond://?src=[REF(user)];ai_take_control=[REF(src)]'>[span_warning("\[INITIALIZE CONTROL OVERRIDE\]")]</a>"
	else if(!control_tracker)
		output += span_warning("\n\[UNABLE TO CONTROL - NO AI TRACKING BEACONS INSTALLED\]")
	else if(length(return_occupants()) >= max_occupants)
		output += span_warning("\n\[UNABLE TO CONTROL - OCCUPIED\]")
	else
		output += "\n<a href='byond://?src=[REF(user)];ai_take_control=[REF(src)]'>[span_boldnotice("\[TAKE DIRECT CONTROL\]")]</a>"

	to_chat(user, boxed_message(jointext(output, "\n")))

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
				to_chat(user, span_warning("No AI detected in \the [src]'s onboard computer."))
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
			var/obj/structure/ai_core/deactivated/deactivated_core = new(AI.loc, FALSE, FALSE, AI)
			AI.linked_core = deactivated_core
			AI.linked_core.RegisterSignal(deactivated_core, COMSIG_ATOM_DESTRUCTION, TYPE_PROC_REF(/obj/structure/ai_core/deactivated, disable_doomsday)) //Protect that core! The structure goes bye-bye when we re-shunt back in so no need for cleanup.
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
			if(!(mecha_flags & AI_COMPATIBLE)) //If the mech isn't compatible with an AI transfer, early return.
				to_chat(user, span_warning("An AI cannot be installed into [src]."))
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
	AI.eyeobj?.RegisterSignal(src, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/eye/camera/ai, update_visibility))
	AI.controlled_equipment = src
	AI.remote_control = src
	add_occupant(AI)

	var/list/output = list()
	output += span_bold("You have been uploaded to the exosuits onboard computer.\n")
	output += "• Press the middle mouse button or the action button on your HUD panel to toggle equipment safety."
	output += "• Clicks with safety enabled will pass AI commands as usual."

	if(AI.can_dominate_mechs)
		output += "• [span_warning("Do not attempt to leave the station sector.")]"

	to_chat(AI, boxed_message(jointext(output, "\n")))
