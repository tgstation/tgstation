/mob/living/silicon/pai/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiInterface", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["door_jack"] = hacking_cable
	data["screen_image_interface_icon"] = card.screen_image.interface_icon
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
		balloon_alert(ui.user, "software unavailable!")
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
		if("Internal GPS")
			internal_gps = new(src)
		if("Music Synthesizer")
			instrument = new(src)
		if("Newscaster")
			newscaster = new(src)
		if("Photography Module")
			aicamera = new /obj/item/camera/siliconcam/pai_camera(src)
		if("Remote Signaler")
			signaler = new(src)
	return TRUE

/**
 * Changes the image displayed on the pAI.
 *
 * @returns {boolean} - TRUE if the image was changed, FALSE otherwise.
 */
/mob/living/silicon/pai/proc/change_image()
	var/list/possible_choices = list()
	for(var/datum/pai_screen_image/screen_option as anything in subtypesof(/datum/pai_screen_image))
		var/datum/radial_menu_choice/choice = new
		choice.name = screen_option.name
		choice.image = image(icon = screen_option.icon, icon_state = screen_option.icon_state)
		possible_choices[screen_option] += choice
	var/atom/anchor = get_atom_on_turf(src)
	var/new_image = show_radial_menu(src, anchor, possible_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), anchor), radius = 40, require_near = TRUE)
	if(isnull(new_image))
		return FALSE
	card.screen_image = new_image
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
	to_chat(src, span_bolddanger(("[holder]'s UE string: [holder.dna.unique_enzymes]")))
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
	grant_all_languages(source = LANGUAGE_SOFTWARE)
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
	switch(mode)
		if(PAI_SCAN_TARGET)
			var/mob/living/target = get_holder()
			if(!isliving(target))
				balloon_alert(src, "not being carried!")
				return FALSE
			healthscan(src, target)
			return TRUE

		if(PAI_SCAN_MASTER)
			var/mob/living/resolved_master = find_master()
			if(isnull(resolved_master))
				balloon_alert(src, "no master detected!")
				return FALSE
			if(!is_valid_z_level(get_turf(src), get_turf(resolved_master)))
				balloon_alert(src, "master out of range!")
				return FALSE
			healthscan(src, resolved_master)
			return TRUE

	stack_trace("Invalid mode passed to host scan: [mode || "null"]")
	return FALSE

/// Huds from PAI software
#define PAI_HUD_TRAIT "pai_hud"

/**
 * Proc that toggles any active huds based on the option.
 *
 * @param {string} mode - The hud to toggle.
 */
/mob/living/silicon/pai/proc/toggle_hud(mode)
	if(isnull(mode))
		return FALSE
	if(mode == PAI_TOGGLE_MEDICAL_HUD)
		if(HAS_TRAIT_FROM(src, TRAIT_MEDICAL_HUD, PAI_HUD_TRAIT))
			REMOVE_TRAIT(src, TRAIT_MEDICAL_HUD, PAI_HUD_TRAIT)
		else
			ADD_TRAIT(src, TRAIT_MEDICAL_HUD, PAI_HUD_TRAIT)
	if(mode == PAI_TOGGLE_SECURITY_HUD)
		if(HAS_TRAIT_FROM(src, TRAIT_SECURITY_HUD, PAI_HUD_TRAIT))
			REMOVE_TRAIT(src, TRAIT_SECURITY_HUD, PAI_HUD_TRAIT)
		else
			ADD_TRAIT(src, TRAIT_SECURITY_HUD, PAI_HUD_TRAIT)
	return TRUE

#undef PAI_HUD_TRAIT
