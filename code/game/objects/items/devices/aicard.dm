/obj/item/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	var/flush = FALSE
	var/mob/living/silicon/ai/AI

/obj/item/computer_disk/syndie_ai_upgrade
	name = "AI interaction range upgrade"
	desc = "A NT data chip containing information that a syndiCard AI can utilize to improve its wireless interfacing abilities. Simply slap it on top of an intelliCard, MODsuit, or AI core and watch it do its work! It's rumoured that there's something 'pretty awful' in it."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "something_awful"
	max_capacity = 1000
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/computer_disk/syndie_ai_upgrade/pre_attack(atom/A, mob/living/user, params)
	var/mob/living/silicon/ai/AI
	if(isAI(A))
		AI = A
	else
		AI = locate() in A
	if(AI && AI.interaction_range != INFINITY)
		AI.interaction_range += 2
		playsound(src,'sound/machines/twobeep.ogg',50,FALSE)
		to_chat(user, span_notice("You insert [src] into [AI]'s compartment, and it beeps as it processes the data."))
		to_chat(AI, span_notice("You process [src], and find yourself able to manipulate electronics from up to [AI.interaction_range] meters!"))
		qdel(src)
	else
		playsound(src,'sound/machines/buzz-sigh.ogg',50,FALSE)
		to_chat(user, span_notice("Error! Incompatible object!"))
		..()

/obj/item/aicard/syndie
	name = "syndiCard"
	desc = "A storage device for AIs. Nanotrasen forgot to make the patent, so the Syndicate made their own version!"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "syndicard"
	item_flags = null
	force = 7

/obj/item/aicard/syndie/loaded
	var/used = FALSE

/obj/item/aicard/syndie/loaded/examine(mob/user)
	. = ..()

	. += span_notice("This one has a little S.E.L.F. insignia on the back, and a label next to it that says 'Activate for one FREE aligned AI! Please attempt uplink reintegration or ask your employers for reimbursal if AI is unavailable or belligerent.")

/obj/item/aicard/syndie/loaded/attack_self(mob/user, modifiers)
	if(AI || used)
		return ..()
	procure_ai(user)

/obj/item/aicard/syndie/loaded/proc/procure_ai(mob/user)
	var/datum/antagonist/nukeop/creator_op = user.mind?.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(!creator_op)
		return
	var/list/nuke_candidates = poll_ghost_candidates("Do you want to play as a syndicate artifical intelligence inside an intelliCard?", ROLE_OPERATIVE, ROLE_OPERATIVE, 150, POLL_IGNORE_SYNDICATE)
	if(LAZYLEN(nuke_candidates))
		if(QDELETED(src))
			return
		used = TRUE
		// pick ghost, create AI and transfer
		var/mob/dead/observer/ghos = pick(nuke_candidates)
		AI = new /mob/living/silicon/ai/weak_syndie(src, ghos)
		AI.key = ghos.key
		// create and apply syndie datum
		var/datum/antagonist/nukeop/nuke_datum = new()
		nuke_datum.send_to_spawnpoint = FALSE
		AI.mind.add_antag_datum(nuke_datum, creator_op.nuke_team)
		AI.mind.special_role = "Syndicate AI"
		AI.faction |= ROLE_SYNDICATE
		// Make it look evil!!!
		AI.hologram_appearance = mutable_appearance('icons/mob/silicon/ai.dmi',"xeno_queen") //good enough
		AI.icon_state = resolve_ai_icon("hades") // evli
		do_sparks(4, TRUE, src)
		playsound(src, 'sound/machines/chime.ogg', 25, TRUE)
	else
		to_chat(user, span_warning("Unable to connect to S.E.L.F. dispatch. Please wait and try again later or use the intelliCard on your uplink to get your points refunded."))

/obj/item/aicard/Destroy(force)
	if(AI)
		AI.death()
		AI.ghostize(can_reenter_corpse = FALSE)
		QDEL_NULL(AI)

	return ..()

/obj/item/aicard/aitater
	name = "intelliTater"
	desc = "A stylish upgrade (?) to the intelliCard."
	icon_state = "aitater"

/obj/item/aicard/aispook
	name = "intelliLantern"
	desc = "A spoOoOoky upgrade to the intelliCard."
	icon_state = "aispook"

/obj/item/aicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to upload [user.p_them()]self into [src]! That's not going to work out well!"))
	return BRUTELOSS

/obj/item/aicard/pre_attack(atom/target, mob/living/user, params)
	if(AI) //AI is on the card, implies user wants to upload it.
		var/our_ai = AI
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		if(!AI)
			log_combat(user, our_ai, "uploaded", src, "to [target].")
			update_appearance()
			return TRUE
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
		if(AI)
			log_silicon("[key_name(user)] carded [key_name(AI)]", src)
			update_appearance()
			return TRUE
	return ..()

/obj/item/aicard/update_icon_state()
	if(!AI)
		name = initial(name)
		icon_state = initial(icon_state)
		return ..()
	name = "[initial(name)] - [AI.name]"
	icon_state = "[initial(icon_state)][AI.stat == DEAD ? "-404" : "-full"]"
	AI.cancel_camera()
	return ..()

/obj/item/aicard/update_overlays()
	. = ..()
	if(!AI?.control_disabled)
		return
	. += "[initial(icon_state)]-on"

/obj/item/aicard/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/aicard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Intellicard", name)
		ui.open()

/obj/item/aicard/ui_data()
	var/list/data = list()
	if(AI)
		data["name"] = AI.name
		data["laws"] = AI.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)
		data["health"] = (AI.health + 100) / 2
		data["wireless"] = !AI.control_disabled //todo disabled->enabled
		data["radio"] = AI.radio_enabled
		data["isDead"] = AI.stat == DEAD
		data["isBraindead"] = AI.client ? FALSE : TRUE
	data["wiping"] = flush
	return data

/obj/item/aicard/ui_act(action,params)
	. = ..()
	if(.)
		return
	switch(action)
		if("wipe")
			if(flush)
				flush = FALSE
			else
				var/confirm = tgui_alert(usr, "Are you sure you want to wipe this card's memory?", name, list("Yes", "No"))
				if(confirm == "Yes" && !..())
					flush = TRUE
					if(AI && AI.loc == src)
						to_chat(AI, span_userdanger("Your core files are being wiped!"))
						while(AI.stat != DEAD && flush)
							AI.adjustOxyLoss(5)
							AI.updatehealth()
							sleep(0.5 SECONDS)
						flush = FALSE
			. = TRUE
		if("wireless")
			AI.control_disabled = !AI.control_disabled
			if(!AI.control_disabled)
				AI.interaction_range = INFINITY
			else
				AI.interaction_range = 0
			to_chat(AI, span_warning("[src]'s wireless port has been [AI.control_disabled ? "disabled" : "enabled"]!"))
			. = TRUE
		if("radio")
			AI.radio_enabled = !AI.radio_enabled
			to_chat(AI, span_warning("Your Subspace Transceiver has been [AI.radio_enabled ? "enabled" : "disabled"]!"))
			. = TRUE
	update_appearance()
