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
		return TRUE
	if(action == "buy")
		buy_software(params["selection"])
		return TRUE
	if(action == "change image")
		change_image()
		return TRUE
	if(action == "check dna")
		check_dna()
		return TRUE
	// Software related ui actions
	if(available_software[action] && !installed_software.Find(action))
		balloon_alert(usr, "software unavailable")
		return FALSE
	switch(action)
		if("Atmospheric Sensor")
			atmos_analyzer.attack_self(src)
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
			door_jack(params["mode"])
			return TRUE
		if("Encryption Slot")
			balloon_alert(usr, "radio frequencies [!encrypt_mod ? "enabled" : "disabled"]")
			encrypt_mod = !encrypt_mod
			radio.subspace_transmission = !radio.subspace_transmission
			return TRUE
		if("Host Scan")
			host_scan(params["mode"])
			return TRUE
		if("Internal GPS")
			internal_gps.attack_self(src)
			return TRUE
		if("Music Synthesizer")
			instrument.interact(src)
			return TRUE
		if("Medical HUD")
			toggle_hud(PAI_TOGGLE_MEDICAL_HUD)
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
			toggle_hud(PAI_TOGGLE_SECURITY_HUD)
			return TRUE
		if("Universal Translator")
			grant_languages()
			ui.send_full_update()
			return TRUE
	return FALSE

/**
 * Purchases the selected software from the list and deducts their
 * available ram.
 *
 * @param {string} selection - The software to purchase.
 *
 * @returns {boolean} - TRUE if the software was purchased, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/buy_software(selection)
	if(!available_software[selection] || installed_software.Find(selection))
		return FALSE
	var/cost = available_software[selection]
	if(ram < cost)
		return FALSE
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
 *
 * @returns {boolean} - TRUE if the image was changed, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/change_image()
	var/new_image = tgui_input_list(src, "Select your new display image", "Display Image", possible_overlays)
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
 * @returns {boolean} - TRUE if a sample was taken, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/check_dna()
	if(emagged) // Their master DNA signature is scrambled anyway
		to_chat(src, span_syndradio("You are not at liberty to do this! All agents are clandestine."))
		return FALSE
	var/mob/living/carbon/holder = get_holder()
	if(!iscarbon(holder))
		balloon_alert(src, "not being carried")
		return FALSE
	balloon_alert(src, "requesting dna sample")
	if(tgui_alert(holder, "[src] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "Checking DNA", list("Yes", "No")) != "Yes")
		balloon_alert(src, "dna sample refused!")
		return FALSE
	holder.visible_message(span_notice("[holder] presses [holder.p_their()] thumb against [src]."), span_notice("You press your thumb against [src]."), span_notice("[src] makes a sharp clicking sound as it extracts DNA material from [holder]."))
	if(!holder.has_dna())
		balloon_alert(src, "no dna detected!")
		return FALSE
	to_chat(src, span_boldannounce(("[holder]'s UE string: [holder.dna.unique_enzymes]")))
	to_chat(src, span_notice("DNA [holder.dna.unique_enzymes == master_dna ? "matches" : "does not match"] our stored Master's DNA."))
	return TRUE

/**
 * Grant all languages to the current pAI.
 *
 * @returns {boolean} - TRUE if the languages were granted, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/grant_languages()
	if(languages_granted)
		return FALSE
	grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_SOFTWARE)
	languages_granted = TRUE
	return TRUE

/**
 * Host scan supporting proc
 *
 * Allows the pAI to scan its host's health vitals
 * using an integrated health analyzer.
 *
 * @returns {boolean} - TRUE if the scan was successful, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/host_scan(mode)
	if(isnull(mode))
		return FALSE
	if(mode == PAI_SCAN_TARGET)
		var/mob/living/target = get_holder()
		if(!target || !isliving(target))
			balloon_alert(src, "not being carried")
			return FALSE
		host_scan.attack(target, src)
		return TRUE
	if(mode == PAI_SCAN_MASTER)
		if(!master_ref)
			balloon_alert(src, "no master detected")
			return FALSE
		var/mob/living/resolved_master = find_master()
		if(!resolved_master)
			balloon_alert(src, "cannot locate master")
			return FALSE
		if(!is_valid_z_level(get_turf(src), get_turf(resolved_master)))
			balloon_alert(src, "master out of range")
			return FALSE
		host_scan.attack(resolved_master, src)
		return TRUE
	return FALSE

/**
 * Proc that toggles any active huds based on the option.
 *
 * @param {string} mode - The hud to toggle.
 */
/mob/living/silicon/pai/proc/toggle_hud(mode)
	if(isnull(mode))
		return FALSE
	var/datum/atom_hud/hud
	var/hud_on
	if(mode == PAI_TOGGLE_MEDICAL_HUD)
		hud = GLOB.huds[med_hud]
		medHUD = !medHUD
		hud_on = medHUD
	if(mode == PAI_TOGGLE_SECURITY_HUD)
		hud = GLOB.huds[sec_hud]
		secHUD = !secHUD
		hud_on = secHUD
	if(hud_on)
		hud.show_to(src)
	else
		hud.hide_from(src)
	return TRUE
