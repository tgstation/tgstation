#define SPAM_TIME 30 SECONDS

/obj/item/pai_card
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_premium_price = PAYCHECK_COMMAND * 1.25
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE

	/// Spam alert prevention
	var/alert_cooldown
	/// The emotion icon displayed.
	var/emotion_icon = "off"
	/// Any pAI personalities inserted
	var/mob/living/silicon/pai/pai
	/// Prevents a crew member from hitting "request pAI" repeatedly
	var/request_spam = FALSE
	/// If the pai_card is slotted in a PDA
	var/slotted = FALSE

/obj/item/pai_card/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	ui_interact(user)

/obj/item/pai_card/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.pai_card_list -= src
	if(!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/pai_card/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)

/obj/item/pai_card/handle_atom_del(atom/thing)
	if(thing == pai) //double check /mob/living/silicon/pai/Destroy() if you change these.
		pai = null
		emotion_icon = initial(emotion_icon)
		update_appearance()
	return ..()

/obj/item/pai_card/Initialize(mapload)
	SSpai.pai_card_list += src
	. = ..()
	update_appearance()

/obj/item/pai_card/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is staring sadly at [src]! [user.p_they()] can't keep living without real human intimacy!"))
	return OXYLOSS

/obj/item/pai_card/update_overlays()
	. = ..()
	. += "pai-[emotion_icon]"
	if(pai?.hacking_cable)
		. += "[initial(icon_state)]-connector"

/obj/item/pai_card/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, emotion_icon))
		update_appearance()

/obj/item/pai_card/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiCard")
		ui.open()

/obj/item/pai_card/ui_status(mob/user)
	if(!slotted && (src in user) || slotted && (src.loc in user))
		return UI_INTERACTIVE
	return ..()

/obj/item/pai_card/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	if(!pai)
		data["candidates"] = pool_candidates() || list()
	else
		data["pai"] = list(
			can_holo = pai.can_holo,
			dna = pai.master_dna,
			emagged = pai.emagged,
			laws = pai.laws.supplied,
			master = pai.master,
			name = pai.name,
			transmit = pai.can_transmit,
			receive = pai.can_receive,
		)
	return data

/obj/item/pai_card/ui_act(action, list/params)
	. = ..()
	if(.)
		return FALSE
	switch(action)
		if("download")
			download_candidate(params["ckey"])
			return TRUE
		if("fix_speech")
			fix_speech(usr)
			return TRUE
		if("request")
			find_pai(usr)
			return TRUE
		if("set_dna")
			set_dna(usr)
			return TRUE
		if("set_laws")
			set_laws(usr)
			return TRUE
		if("toggle_holo")
			toggle_holo(usr)
			return TRUE
		if("toggle_radio")
			toggle_radio(usr, params["option"])
			return TRUE
		if("wipe_pai")
			wipe_pai(usr)
			return TRUE
	return FALSE

/** Flashes the pai card screen */
/obj/item/pai_card/proc/add_alert()
	if(pai)
		return
	add_overlay(
		list(mutable_appearance(icon, "[initial(icon_state)]-alert"),
			emissive_appearance(icon, "[initial(icon_state)]-alert", alpha = src.alpha)))

/** Removes any overlays */
/obj/item/pai_card/proc/remove_alert()
	cut_overlays()

/** Alerts pAI cards that someone has submitted candidacy */
/obj/item/pai_card/proc/alert_update()
	if(!COOLDOWN_FINISHED(src, alert_cooldown))
		return
	COOLDOWN_START(src, alert_cooldown, 5 SECONDS)
	add_alert()
	addtimer(CALLBACK(src, .proc/remove_alert), 5 SECONDS)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	loc.visible_message(span_notice("[src] flashes a message across its screen"), "Additional personalities available for download.", blind_message = span_notice("[src] vibrates with an alert."))

/**
 * Downloads a candidate from the list and removes them from SSpai.candidates
 *
 * @params {string} ckey The ckey of the candidate to download
 * @returns {boolean} TRUE if the candidate was downloaded, FALSE if not
 */
/obj/item/pai_card/proc/download_candidate(ckey)
	if(pai)
		return FALSE
	var/datum/pai_candidate/candidate = SSpai.candidates[ckey]
	if(isnull(candidate) || !candidate.check_ready())
		return FALSE
	var/mob/living/silicon/pai/new_pai = new(src)
	new_pai.name = candidate.name || pick(GLOB.ninja_names)
	new_pai.real_name = new_pai.name
	new_pai.key = candidate.ckey
	set_personality(new_pai)
	SSpai.candidates.Remove(ckey)
	return TRUE

/** Pings ghosts to announce that someone is requesting a pAI */
/obj/item/pai_card/proc/find_pai(mob/user)
	if(pai)
		return FALSE
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Due to growing incidents of SELF corrupted independent artificial intelligences, freeform personality devices have been temporarily	banned in this sector."))
		return FALSE
	if(request_spam)
		to_chat(user, span_warning("Request sent too recently."))
		return FALSE
	request_spam = TRUE
	playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
	to_chat(user, span_notice("You have requested pAI assistance."))
	var/mutable_appearance/alert_overlay = mutable_appearance('icons/obj/aicards.dmi', "pai")
	notify_ghosts("[user] is requesting a pAI personality! Use the pAI button to submit yourself as one.", source = user, alert_overlay = alert_overlay, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "pAI Request!", ignore_key = POLL_IGNORE_PAI)
	addtimer(CALLBACK(src, .proc/request_again), SPAM_TIME,	TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_CLIENT_TIME | TIMER_DELETE_ME)
	return TRUE

/** Fixes weird speech issues with the pai. */
/obj/item/pai_card/proc/fix_speech(mob/user)
	if(!pai)
		return
	to_chat(pai, span_notice("Your owner has corrected your speech modulation!"))
	to_chat(user, span_notice("You fix the pAI's speech modulator."))
	for(var/effect in typesof(/datum/status_effect/speech))
		pai.remove_status_effect(effect)
	return TRUE

/**
 * Gathers a list of candidates to display in the download candidate
 * window. If the candidate isn't marked ready, ie they have not
 * pressed submit, they will be skipped over.
 *
 * @return - An array of candidate objects.
 */
/obj/item/pai_card/proc/pool_candidates()
	var/list/candidates = list()
	if(pai || !length(SSpai?.candidates))
		return candidates
	for(var/key in SSpai.candidates)
		var/datum/pai_candidate/checked_candidate = SSpai.candidates[key]
		if(!checked_candidate.ready)
			continue
		var/list/candidate = list(
			comments = checked_candidate.comments,
			ckey = checked_candidate.ckey,
			description = checked_candidate.description,
			name = checked_candidate.name,
		)
		candidates += list(candidate)
	return candidates

/** Cooldown for requesting pAIs from ghosts  */
/obj/item/pai_card/proc/request_again()
	request_spam = FALSE

/** Imprints your DNA onto the downloaded pAI */
/obj/item/pai_card/proc/set_dna(mob/user)
	if(!pai || pai.master_dna)
		return FALSE
	if(!iscarbon(user))
		to_chat(user, span_warning("You don't have any DNA, or your DNA is incompatible with this device!"))
	else
		var/mob/living/carbon/master = user
		pai.master = master.real_name
		pai.master_dna = master.dna.unique_enzymes
		to_chat(pai, span_notice("You have been bound to a new master: [master]!"))
		pai.emitter_semi_cd = FALSE
	return TRUE

/** Opens a tgui alert that allows someone to enter laws. */
/obj/item/pai_card/proc/set_laws(mob/user)
	if(!pai)
		return FALSE
	if(!pai.master)
		to_chat(user, span_warning("The pAI is not bound to a master! It doesn't have to listen to anyone."))
		return FALSE
	var/new_laws = tgui_input_text(usr, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied[1], 300)
	if(!new_laws || !pai || !pai.master)
		return FALSE
	pai.add_supplied_law(0, new_laws)
	to_chat(pai, span_notice("They are as follows:"))
	to_chat(pai, span_notice(new_laws))
	return TRUE

/**
 * Sets the personality on the current pai_card
 *
 * Parameters:
 * downloaded - required - The new pAI to load into the card.
 */
/obj/item/pai_card/proc/set_personality(mob/living/silicon/pai/downloaded)
	if(pai)
		return FALSE
	pai = downloaded
	emotion_icon = "null"
	update_appearance()
	playsound(loc, 'sound/effects/pai_boot.ogg', 50, TRUE, -1)
	audible_message("\The [src] plays a cheerful startup noise!")
	return TRUE

/** Toggles the ability of the pai to enter holoform */
/obj/item/pai_card/proc/toggle_holo(mob/user)
	if(!pai)
		return FALSE
	to_chat(user, span_notice("You [pai.can_holo ? "disabled" : "enabled"] your pAI's holomatrix."))
	to_chat(pai, span_warning("Your owner has [pai.can_holo ? "disabled" : "enabled"] your holomatrix projectors!"))
	pai.can_holo = !pai.can_holo
	return TRUE

/**
 * Toggles the radio settings on and off from the pAI.
 *
 * Parameters:
 * option: string - required - The option to toggle.
 */
/obj/item/pai_card/proc/toggle_radio(mob/user, option)
	if(!pai)
		return FALSE
	// it can't be both so if we know it's not transmitting it must be receiving.
	var/transmitting = option == "transmit"
	var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
	if(transmitting)
		pai.can_transmit = !pai.can_transmit
	else //receiving
		pai.can_receive = !pai.can_receive
	pai.radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
	transmit_holder = (transmitting ? pai.can_transmit : pai.can_receive) //recycling can be fun!
	to_chat(user, span_notice("You [transmit_holder ? "enable" : "disable"] your pAI's [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
	to_chat(pai, span_warning("Your owner has [transmit_holder ? "enabled" : "disabled"] your [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
	return TRUE

/**
 * Wipes the current pAI on the card.
 */
/obj/item/pai_card/proc/wipe_pai(mob/user)
	if(!pai)
		return FALSE
	if(tgui_alert(user, "Are you certain you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", list("Yes", "No")) != "Yes")
		return TRUE
	to_chat(pai, span_warning("You feel yourself slipping away from reality."))
	to_chat(pai, span_danger("Byte by byte you lose your sense of self."))
	to_chat(pai, span_userdanger("Your mental faculties leave you."))
	to_chat(pai, span_rose("oblivion... "))
	qdel(pai)
	return TRUE

#undef SPAM_TIME
