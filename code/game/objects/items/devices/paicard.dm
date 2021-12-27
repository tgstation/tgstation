/obj/item/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_premium_price = PAYCHECK_HARD * 1.25
	///don't spam alert messages.
	var/alert_cooldown
	/// If the pAIcard is slotted in a PDA
	var/slotted = FALSE
	/// Any pAI personalities inserted
	var/mob/living/silicon/pai/pai
	///what emotion icon we have. handled in /mob/living/silicon/pai/Topic()
	var/emotion_icon = "off"
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE

/obj/item/paicard/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is staring sadly at [src]! [user.p_they()] can't keep living without real human intimacy!"))
	return OXYLOSS

/obj/item/paicard/Initialize(mapload)
	SSpai.pai_card_list += src
	. = ..()
	update_appearance()

/obj/item/paicard/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, emotion_icon))
		update_appearance()

/obj/item/paicard/handle_atom_del(atom/A)
	if(A == pai) //double check /mob/living/silicon/pai/Destroy() if you change these.
		pai = null
		emotion_icon = initial(emotion_icon)
		update_appearance()
	return ..()

/obj/item/paicard/update_overlays()
	. = ..()
	. += "pai-[emotion_icon]"
	if(pai?.hacking_cable)
		. += "[initial(icon_state)]-connector"

/obj/item/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.pai_card_list -= src
	if(!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	ui_interact(user)

/obj/item/paicard/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiCard")
		ui.open()

/obj/item/paicard/ui_state(mob/user)
	return GLOB.paicard_state

/obj/item/paicard/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["candidates"] = list()
	if(!pai)
		data["candidates"] = pool_candidates()
		data["pai"] = null
		return data
	data["pai"] = list()
	data["pai"]["can_holo"] = pai.canholo
	data["pai"]["dna"] = pai.master_dna
	data["pai"]["emagged"] = pai.emagged
	data["pai"]["laws"] = pai.laws.supplied
	data["pai"]["master"] = pai.master
	data["pai"]["name"] = pai.name
	data["pai"]["transmit"] = pai.can_transmit
	data["pai"]["receive"] = pai.can_receive
	return data

/obj/item/paicard/ui_act(action, list/params)
	. = ..()
	if(.)
		return FALSE
	switch(action)
		if("download")
			/// The individual candidate to download
			var/datum/pai_candidate/candidate
			for(var/datum/pai_candidate/checked_candidate as anything in SSpai.candidates)
				if(params["key"] == checked_candidate.key)
					candidate = checked_candidate
					break
			if(isnull(candidate))
				return FALSE
			if(src.pai)
				return FALSE
			if(SSpai.check_ready(candidate) != candidate)
				return FALSE
			/// The newly downloaded pAI personality
			var/mob/living/silicon/pai/pai = new(src)
			pai.name = candidate.name || pick(GLOB.ninja_names)
			pai.real_name = pai.name
			pai.key = candidate.key
			src.setPersonality(pai)
			SSpai.candidates -= candidate
		if("fix_speech")
			to_chat(pai, span_notice("Your owner has corrected your speech modulation!"))
			to_chat(usr, span_notice("You fix the pAI's speech modulator."))
			pai.stuttering = 0
			pai.slurring = 0
			pai.derpspeech = 0
		if("request")
			if(!pai)
				SSpai.findPAI(src, usr)
		if("set_dna")
			if(pai.master_dna)
				return
			if(!iscarbon(usr))
				to_chat(usr, span_warning("You don't have any DNA, or your DNA is incompatible with this device!"))
			else
				var/mob/living/carbon/master = usr
				pai.master = master.real_name
				pai.master_dna = master.dna.unique_enzymes
				to_chat(pai, span_notice("You have been bound to a new master."))
				pai.emittersemicd = FALSE
		if("set_laws")
			var/newlaws = tgui_input_text(usr, "Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied[1], MAX_MESSAGE_LEN, TRUE)
			if(newlaws && pai)
				pai.add_supplied_law(0,newlaws)
		if("toggle_holo")
			if(pai.canholo)
				to_chat(pai, span_warning("Your owner has disabled your holomatrix projectors!"))
				pai.canholo = FALSE
				to_chat(usr, span_notice("You disable your pAI's holomatrix!"))
			else
				to_chat(pai, span_notice("Your owner has enabled your holomatrix projectors!"))
				pai.canholo = TRUE
				to_chat(usr, span_notice("You enable your pAI's holomatrix!"))
		if("toggle_radio")
			var/transmitting = params["option"] == "transmit" //it can't be both so if we know it's not transmitting it must be receiving.
			var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
			if(transmitting)
				pai.can_transmit = !pai.can_transmit
			else //receiving
				pai.can_receive = !pai.can_receive
			pai.radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
			transmit_holder = (transmitting ? pai.can_transmit : pai.can_receive) //recycling can be fun!
			to_chat(usr, span_notice("You [transmit_holder ? "enable" : "disable"] your pAI's [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
			to_chat(pai, span_notice("Your owner has [transmit_holder ? "enabled" : "disabled"] your [transmitting ? "outgoing" : "incoming"] radio transmissions!"))
		if("wipe_pai")
			var/confirm = tgui_alert(usr, "Are you certain you wish to delete the current personality? This action cannot be undone.", "Personality Wipe", list("Yes", "No"))
			if(confirm == "Yes")
				if(pai)
					to_chat(pai, span_warning("You feel yourself slipping away from reality."))
					to_chat(pai, span_danger("Byte by byte you lose your sense of self."))
					to_chat(pai, span_userdanger("Your mental faculties leave you."))
					to_chat(pai, span_rose("oblivion... "))
					qdel(pai)
	return

// WIRE_SIGNAL = 1
// WIRE_RECEIVE = 2
// WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	pai = personality
	emotion_icon = "null"
	update_appearance()

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, TRUE, -1)
	audible_message("\The [src] plays a cheerful startup noise!")

/obj/item/paicard/proc/alertUpdate()
	if(!COOLDOWN_FINISHED(src, alert_cooldown))
		return
	COOLDOWN_START(src, alert_cooldown, 5 SECONDS)
	flick("[initial(icon_state)]-alert", src)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	loc.visible_message(span_info("[src] flashes a message across its screen, \"Additional personalities available for download.\""), blind_message = span_notice("[src] vibrates with an alert."))

/obj/item/paicard/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)

/**
 * Gathers a list of candidates to display in the download candidate
 * window. If the candidate isn't marked ready, ie they have not
 * pressed submit, they will be skipped over.
 *
 * @return - An array of candidate objects.
 */
/obj/item/paicard/proc/pool_candidates()
	/// Array of pAI candidates
	var/list/candidates = list()
	if(length(SSpai.candidates))
		for(var/datum/pai_candidate/checked_candidate as anything in SSpai.candidates)
			if(!checked_candidate.ready)
				continue
			/// The object containing the candidate data.
			var/list/candidate = list()
			candidate["comments"] = checked_candidate.comments
			candidate["description"] = checked_candidate.description
			candidate["key"] = checked_candidate.key
			candidate["name"] = checked_candidate.name
			candidates += list(candidate)
	return candidates
