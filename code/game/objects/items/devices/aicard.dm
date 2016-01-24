/obj/item/device/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2
	slot_flags = SLOT_BELT
	flags = NOBLUDGEON
	var/flush = FALSE
	var/mob/living/silicon/ai/AI
	origin_tech = "programming=4;materials=4"


/obj/item/device/aicard/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	if(AI) //AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		add_logs(user, AI, "carded", src)
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	update_state() //Whatever happened, update the card's state (icon, name) to match.


/obj/item/device/aicard/proc/update_state()
	if(AI)
		name = "intelliCard - [AI.name]"
		if (AI.stat == DEAD)
			icon_state = "aicard-404"
		else
			icon_state = "aicard-full"
		AI.cancel_camera() //AI are forced to move when transferred, so do this whenver one is downloaded.
	else
		icon_state = "aicard"
		name = "intelliCard"
		overlays.Cut()

/obj/item/device/aicard/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "intellicard", name, 500, 500, master_ui, state)
		ui.open()


/obj/item/device/aicard/get_ui_data()
	var/list/data = list()
	if(AI)
		data["name"] = AI.name
		data["laws"] = AI.laws.get_law_list(include_zeroth = 1)
		data["health"] = (AI.health + 100) / 2
		data["wireless"] = !AI.control_disabled //todo disabled->enabled
		data["radio"] = AI.radio_enabled
		data["isDead"] = AI.stat == DEAD
		data["isBraindead"] = AI.client ? TRUE : FALSE
	data["wiping"] = flush
	return data

/obj/item/device/aicard/ui_act(action,params)
	if(..())
		return

	switch(action)
		if("wipe")
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes" && !..())
				flush = 1
				if(AI && AI.loc == src)
					AI.suiciding = 1
					AI << "Your core files are being wiped!"
					while(AI.stat != DEAD)
						AI.adjustOxyLoss(2)
						AI.updatehealth()
						sleep(10)
					flush = 0
		if("wireless")
			AI.control_disabled = !AI.control_disabled
			AI << "The intellicard's wireless port has been [AI.control_disabled ? "disabled" : "enabled"]!"
			if (AI.control_disabled)
				overlays -= image('icons/obj/aicards.dmi', "aicard-on")
			else
				overlays += image('icons/obj/aicards.dmi', "aicard-on")
		if("radio")
			AI.radio_enabled = !AI.radio_enabled
			AI << "Your Subspace Transceiver has been [AI.radio_enabled ? "enabled" : "disabled"]!"
	return 1