/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["door_jack"] = hacking_cable
	data["image"] = card.emotion_icon
	data["installed"] = installed_software
	data["ram"] = ram
	return data

/mob/living/silicon/pai/ui_static_data(mob/user)
	var/list/data = list()
	data["available"] = available_software
	data["directives"] = laws.supplied
	data["emagged"] = emagged
	data["languages"] = languages_granted
	data["master_name"] = master_name
	data["master_dna"] = master_dna
	return data

/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(available_software[action] && !installed_software.Find(action))
		to_chat(usr, span_warning("You do not have this software installed."))
		CRASH("[usr] attempted to activate software they hadn't installed: [action]")
	switch(action)
		if("Atmospheric Sensor")
			atmos_analyzer.attack_self(src)
			return TRUE
		if("buy")
			buy_software(usr, params["selection"])
			return TRUE
		if("change image")
			change_image(usr)
			return TRUE
		if("check dna")
			check_dna(usr)
			return TRUE
		if("Crew Manifest")
			ai_roster()
			return TRUE
		if("Crew Monitor")
			GLOB.crewmonitor.show(usr, src)
			return TRUE
		if("Digital Messenger")
			modularInterface?.interact(usr)
			return TRUE
		if("Door Jack")
			// Look to door_jack.dm for implementation
			door_jack(usr, params["mode"])
			return TRUE
		if("Encryption Slot")
			to_chat(usr, span_notice("You have [!encrypt_mod ? "enabled" : "disabled"] encrypted radio frequencies."))
			encrypt_mod = !encrypt_mod
			radio.subspace_transmission = !radio.subspace_transmission
			return TRUE
		if("Host Scan")
			host_scan(usr, params["mode"])
			return TRUE
		if("Internal GPS")
			internal_gps.attack_self(src)
			return TRUE
		if("Music Synthesizer")
			instrument.interact(src)
			return TRUE
		if("Medical HUD")
			toggle_hud(usr, "medical")
			return TRUE
		if("Newscaster")
			newscaster.ui_interact(src)
			return TRUE
		if("Photography Module")
			// Look to pai_camera.dm for implementation
			use_camera(usr, params["mode"])
			return TRUE
		if("Remote Signaler")
			signaler.ui_interact(src)
			return TRUE
		if("Security HUD")
			toggle_hud(usr, "security")
			return TRUE
		if("Universal Translator")
			grant_languages(usr, ui)
			return TRUE
	return FALSE

/**
 * Purchases the selected software from the list and deducts their
 * available ram.
 *
 * @param {mob} user - - The user purchasing the software.
 * @param {string} selection - The software to purchase.
 * @returns {boolean} - TRUE if the software was purchased, CRASH otherwise.
 */
/mob/living/silicon/pai/proc/buy_software(mob/user, selection)
	if(!available_software[selection] || installed_software.Find(selection))
		to_chat(user, span_warning("Error: Software unavailable."))
		CRASH("[user] tried to purchase unavailable software as a pAI.")
	var/cost = available_software[selection]
	if(ram < cost)
		to_chat(user, span_warning("Error: Insufficient RAM available."))
		CRASH("[user] tried to purchase software with insufficient RAM.")
	installed_software.Add(selection)
	ram -= cost
	var/datum/hud/pai/pAIhud = hud_used
	pAIhud?.update_software_buttons()
	switch(selection)
		if("Atmospheric Sensor")
			atmos_analyzer = new(src)
		if("Digital Messenger")
			create_modularInterface()
		if("Host Scan")
			host_scan = new(src)
		if("Internal GPS")
			internal_gps = new(src)
		if("Music Synthesizer")
			instrument = new(src)
		if("Newscaster")
			newscaster = new(src)
		if("Photography Module")
			camera = new(src)
		if("Remote Signaler")
			signaler = new(src)
	return TRUE

/**
 * Changes the image displayed on the pAI.
 *
 * @param {mob} user - The user who is changing the image.
 * @returns {boolean} - TRUE if the image was changed, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/change_image(mob/user)
	var/new_image = tgui_input_list(user, "Select your new display image", "Display Image", possible_overlays)
	if(isnull(new_image))
		return FALSE
	card.emotion_icon = new_image
	card.update_appearance()
	return TRUE

/**
 * Supporting proc for the pAI to prick it's master's hand
 * or... whatever. It must be held in order to work
 * Gives the owner a popup if they want to get the jab.
 *
 * @param {mob} user - The pAI requesting the sample.
 * @returns {boolean} - TRUE if a sample was taken, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_dna(mob/user)
	if(emagged) // Their master DNA signature is scrambled anyway
		to_chat(user, span_syndradio("You are not at liberty to do this! All agents are clandestine."))
		return FALSE
	var/mob/living/carbon/holder = get_holder()
	if(!holder)
		to_chat(user, span_warning("You must be in someone's hands to do this!"))
		return FALSE
	to_chat(user, span_notice("Requesting a DNA sample."))
	if(tgui_alert(holder, "[user] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "Checking DNA", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("[holder] does not seem like [holder.p_theyre()]	going to provide a DNA sample willingly."))
		return FALSE
	holder.visible_message(span_notice("[holder] presses [holder.p_their()] thumb against [user]."), span_notice("You press your thumb against [user]."), span_notice("[user] makes a sharp clicking sound as it extracts DNA material from [holder]."))
	if(!holder.has_dna())
		to_chat(user, span_warning("No DNA detected."))
		return FALSE
	to_chat(user, span_boldannounce(("[holder]'s UE string: [holder.dna.unique_enzymes]")))
	to_chat(user, span_notice("DNA [holder.dna.unique_enzymes == master_dna ? "matches" : "does not match"] our stored Master's DNA."))
	return TRUE

/**
 * Grant all languages to the current pAI.
 *
 * @param {mob} user - The pAI receiving the languages.
 * @param {tgui} ui - The interface for the pAI.
 * @returns {boolean} - TRUE if the languages were granted, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/grant_languages(mob/user, datum/tgui/ui)
	if(languages_granted)
		to_chat(usr, span_warning("Error: You know all that there is to know!"))
		return FALSE
	grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
	languages_granted = TRUE
	ui.send_full_update()
	return TRUE

/**
 * Host scan supporting proc
 *
 * Allows the pAI to scan its host's health vitals
 * An integrated health analyzer.
 *
 * @param {mob} user - The pAI requesting the scan.
 * @returns {boolean} - TRUE if the scan was successful, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/host_scan(mob/user, mode)
	if(mode == "target")
		var/mob/living/target = get_holder()
		if(!target || !isliving(target))
			to_chat(user, span_warning("You are not being carried by anyone!"))
			return FALSE
		host_scan.attack(target, user)
		return TRUE
	if(mode == "master")
		if(!master_ref)
			to_chat(user, span_warning("You are not bound to a master!"))
			return FALSE
		var/mob/living/resolved_master = find_master()
		if(!resolved_master)
			to_chat(user, span_warning("Your master cannot be located!"))
			return FALSE
		if(user.z != resolved_master.z)
			to_chat(user, span_warning("Your master, [master_name], seems to be out of range!"))
			return FALSE
		to_chat(user, span_notice("Your master, [master_name], is reporting the current vitals:"))
		host_scan.attack(resolved_master, user)
		return TRUE
	return FALSE

/**
 * Proc that toggles any active huds based on the option.
 *
 * @param {mob} user - The pAI toggling the hud.
 * @param {string} option - The hud to toggle.
 */
/mob/living/silicon/pai/proc/toggle_hud(mob/user, option)
	if(!option)
		return FALSE
	var/datum/atom_hud/hud
	var/hud_on
	if(option == "medical")
		hud = GLOB.huds[med_hud]
		medHUD = !medHUD
		hud_on = medHUD
	if(option == "security")
		hud = GLOB.huds[sec_hud]
		secHUD = !secHUD
		hud_on = secHUD
	if(hud_on)
		hud.show_to(user)
	else
		hud.hide_from(user)
	return TRUE
