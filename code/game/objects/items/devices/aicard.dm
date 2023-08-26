/obj/item/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	base_icon_state = "aicard"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	var/flush = FALSE
	var/mob/living/silicon/ai/AI

/obj/item/aicard/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CASTABLE_LOC, INNATE_TRAIT)

/obj/item/computer_disk/syndie_ai_upgrade
	name = "AI interaction range upgrade"
	desc = "A NT data chip containing information that a syndiCard AI can utilize to improve its wireless interfacing abilities. Simply slap it on top of an intelliCard, MODsuit, or AI core and watch it do its work! It's rumoured that there's something 'pretty awful' in it."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "something_awful"
	max_capacity = 1000
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/computer_disk/syndie_ai_upgrade/pre_attack(atom/A, mob/living/user, params)
	var/mob/living/silicon/ai/AI
	if(isAI(A))
		AI = A
	else
		AI = locate() in A
	if(!AI || AI.interaction_range == INFINITY)
		playsound(src,'sound/machines/buzz-sigh.ogg',50,FALSE)
		to_chat(user, span_notice("Error! Incompatible object!"))
		return ..()
	AI.interaction_range += 2
	if(AI.interaction_range > 7)
		AI.interaction_range = INFINITY
	playsound(src,'sound/machines/twobeep.ogg',50,FALSE)
	to_chat(user, span_notice("You insert [src] into [AI]'s compartment, and it beeps as it processes the data."))
	to_chat(AI, span_notice("You process [src], and find yourself able to manipulate electronics from up to [AI.interaction_range] meters!"))
	qdel(src)

/obj/item/aicard/syndie
	name = "syndiCard"
	desc = "A storage device for AIs. Nanotrasen forgot to make the patent, so the Syndicate made their own version!"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "syndicard"
	base_icon_state = "syndicard"
	item_flags = null
	force = 7

/obj/item/aicard/syndie/loaded
	var/being_or_was_used = FALSE

/obj/item/aicard/syndie/loaded/examine(mob/user)
	. = ..()

	. += span_notice("This one has a little S.E.L.F. insignia on the back, and a label next to it that says 'Activate for one FREE aligned AI! Please attempt uplink reintegration or ask your employers for reimbursal if AI is unavailable or belligerent.")

/obj/item/aicard/syndie/loaded/attack_self(mob/user, modifiers)
	if(AI || being_or_was_used)
		return ..()
	being_or_was_used = TRUE
	to_chat(user, span_notice("Connecting to S.E.L.F. dispatch..."))
	being_or_was_used = procure_ai(user)

/obj/item/aicard/syndie/loaded/proc/procure_ai(mob/user)
	var/datum/antagonist/nukeop/creator_op = user.mind?.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(!creator_op)
		return FALSE
	var/list/nuke_candidates = poll_ghost_candidates("Do you want to play as a syndicate artifical intelligence inside an intelliCard?", ROLE_OPERATIVE, ROLE_OPERATIVE, 150, POLL_IGNORE_SYNDICATE)
	if(QDELETED(src))
		return FALSE
	if(!LAZYLEN(nuke_candidates))
		to_chat(user, span_warning("Unable to connect to S.E.L.F. dispatch. Please wait and try again later or use the intelliCard on your uplink to get your points refunded."))
		return FALSE
	// pick ghost, create AI and transfer
	var/mob/dead/observer/ghos = pick(nuke_candidates)
	var/mob/living/silicon/ai/weak_syndie/new_ai = new /mob/living/silicon/ai/weak_syndie(get_turf(src), null, ghos) // wow so cool i love how laws go before the mob to insert for no reason this definitely didnt delay this pr for weeks
	new_ai.key = ghos.key
	// create and apply syndie datum
	var/datum/antagonist/nukeop/nuke_datum = new()
	nuke_datum.send_to_spawnpoint = FALSE
	new_ai.mind.add_antag_datum(nuke_datum, creator_op.nuke_team)
	new_ai.mind.special_role = "Syndicate AI"
	new_ai.faction |= ROLE_SYNDICATE
	// Make it look evil!!!
	new_ai.hologram_appearance = mutable_appearance('icons/mob/silicon/ai.dmi',"xeno_queen") //good enough
	new_ai.icon_state = resolve_ai_icon("hades") // evli
	pre_attack(new_ai, user) // i love shitcode!
	AI.control_disabled = FALSE // re-enable wireless activity
	AI.radio_enabled = TRUE // ditto
	var/obj/structure/ai_core/deactivated/detritus = locate() in get_turf(src)
	qdel(detritus)
	do_sparks(4, TRUE, src)
	playsound(src, 'sound/machines/chime.ogg', 25, TRUE)
	return TRUE

/obj/item/aicard/Destroy(force)
	if(AI)
		AI.ghostize(can_reenter_corpse = FALSE)
		QDEL_NULL(AI)

	return ..()

/obj/item/aicard/aitater
	name = "intelliTater"
	desc = "A stylish upgrade (?) to the intelliCard."
	icon_state = "aitater"
	base_icon_state = "aitater"

/obj/item/aicard/aispook
	name = "intelliLantern"
	desc = "A spoOoOoky upgrade to the intelliCard."
	icon_state = "aispook"
	base_icon_state = "aispook"

/obj/item/aicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to upload [user.p_them()]self into [src]! That's not going to work out well!"))
	return BRUTELOSS

/obj/item/aicard/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(AI)
		if(upload_ai(target, user))
			return TRUE
	else
		if(capture_ai(target, user))
			return TRUE

/// Tries to get an AI from the atom clicked
/obj/item/aicard/proc/capture_ai(atom/from_what, mob/living/user)
	from_what.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	if(isnull(AI))
		return FALSE

	log_silicon("[key_name(user)] carded [key_name(AI)]", src)
	update_appearance()
	AI.cancel_camera()
	RegisterSignal(AI, COMSIG_MOB_STATCHANGE, PROC_REF(on_ai_stat_change))
	return TRUE

/// Tries to upload the AI we have captured to the atom clicked
/obj/item/aicard/proc/upload_ai(atom/to_what, mob/living/user)
	var/mob/living/silicon/ai/old_ai = AI
	to_what.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
	if(!isnull(AI))
		return FALSE

	log_combat(user, old_ai, "uploaded", src, "to [to_what].")
	update_appearance()
	old_ai.cancel_camera()
	UnregisterSignal(old_ai, COMSIG_MOB_STATCHANGE)
	return TRUE

/obj/item/aicard/proc/on_ai_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER

	if(new_stat == DEAD || old_stat == DEAD)
		update_appearance()

/obj/item/aicard/update_name(updates)
	. = ..()
	if(AI)
		name = "[initial(name)] - [AI.name]"
	else
		name = initial(name)

/obj/item/aicard/update_icon_state()
	if(AI)
		icon_state = "[base_icon_state][AI.stat == DEAD ? "-404" : "-full"]"
	else
		icon_state = base_icon_state
	return ..()

/obj/item/aicard/update_overlays()
	. = ..()
	if(!AI?.control_disabled)
		return
	. += "[base_icon_state]-on"

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
					wipe_ai()
			. = TRUE
		if("wireless")
			AI.control_disabled = !AI.control_disabled
			to_chat(AI, span_warning("[src]'s wireless port has been [AI.control_disabled ? "disabled" : "enabled"]!"))
			. = TRUE
		if("radio")
			AI.radio_enabled = !AI.radio_enabled
			to_chat(AI, span_warning("Your Subspace Transceiver has been [AI.radio_enabled ? "enabled" : "disabled"]!"))
			. = TRUE
	update_appearance()

/obj/item/aicard/proc/wipe_ai()
	set waitfor = FALSE

	if(AI && AI.loc == src)
		to_chat(AI, span_userdanger("Your core files are being wiped!"))
		while(AI.stat != DEAD && flush)
			AI.adjustOxyLoss(5)
			AI.updatehealth()
			sleep(0.5 SECONDS)
		flush = FALSE
