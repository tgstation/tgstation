/obj/item/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	var/flush = FALSE
	var/mob/living/silicon/ai/AI

/obj/item/aicard/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is trying to upload [user.p_them()]self into [src]! That's not going to work out well!</span>")
	return BRUTELOSS

/obj/item/aicard/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target)
		return
	if(AI) //AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		add_logs(user, AI, "carded", src)
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	update_icon() //Whatever happened, update the card's state (icon, name) to match.

/obj/item/aicard/update_icon()
	cut_overlays()
	if(AI)
		name = "[initial(name)]- [AI.name]"
		if(AI.stat == DEAD)
			icon_state = "aicard-404"
		else
			icon_state = "aicard-full"
		if(!AI.control_disabled)
			add_overlay("aicard-on")
		AI.cancel_camera()
	else
		name = initial(name)
		icon_state = initial(icon_state)

/obj/item/aicard/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.hands_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "intellicard", name, 500, 500, master_ui, state)
		ui.open()

/obj/item/aicard/ui_data()
	var/list/data = list()
	if(AI)
		data["name"] = AI.name
		data["laws"] = AI.laws.get_law_list(include_zeroth = 1)
		data["health"] = (AI.health + 100) / 2
		data["wireless"] = !AI.control_disabled //todo disabled->enabled
		data["radio"] = AI.radio_enabled
		data["isDead"] = AI.stat == DEAD
		data["isBraindead"] = AI.client ? FALSE : TRUE
	data["wiping"] = flush
	return data

/obj/item/aicard/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("wipe")
			if(flush)
				flush = FALSE
			else
				var/confirm = alert("Are you sure you want to wipe this card's memory?", name, "Yes", "No")
				if(confirm == "Yes" && !..())
					flush = TRUE
					if(AI && AI.loc == src)
						to_chat(AI, "Your core files are being wiped!")
						while(AI.stat != DEAD && flush)
							AI.adjustOxyLoss(1)
							AI.updatehealth()
							sleep(5)
						flush = FALSE
			. = TRUE
		if("wireless")
			AI.control_disabled = !AI.control_disabled
			to_chat(AI, "[src]'s wireless port has been [AI.control_disabled ? "disabled" : "enabled"]!")
			. = TRUE
		if("radio")
			AI.radio_enabled = !AI.radio_enabled
			to_chat(AI, "Your Subspace Transceiver has been [AI.radio_enabled ? "enabled" : "disabled"]!")
			. = TRUE
	update_icon()
