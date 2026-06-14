// Apsis-Station DOWNSTREAM - species eligibility overrides
// Depends on: species_whitelist.dm
/datum/preference/choiced/species/compile_ui_data(mob/user, value)
	// Return human if the current value is a whitelisted species they don't have access to
	var/datum/species/species = value
	if(!is_species_whitelisted_for_client(species.type, user?.client))
		return serialize(/datum/species/human)
	return ..()

/datum/preference/choiced/species/is_valid(value, datum/preferences/preferences)
	if(!..())
		return FALSE
	var/datum/species/species = value
	if(!is_species_whitelisted_for_client(species.type, preferences?.parent))
		if(preferences?.parent)
			to_chat(preferences.parent, span_warning("You are not whitelisted to play as [species.name]."))
		//	to_chat(preferences.parent, span_notice("Apsis-Station offers whitelist species to Patreon supporters. Visit <a href='https://www.patreon.com/YOURPAGE'>our Patreon</a> to apply."))
		return FALSE
	return TRUE

/proc/is_species_whitelisted_for_client(species_type, client/C)
	if(species_type == /datum/species/human/felinid)
		return C ? ckey_in_species_whitelist(C, "felinid_whitelist.txt") : FALSE
	if(species_type == /datum/species/lizard)
		return C ? ckey_in_species_whitelist(C, "lizard_whitelist.txt") : FALSE
	if(species_type == /datum/species/moth)
		return C ? ckey_in_species_whitelist(C, "moth_whitelist.txt") : FALSE
	return TRUE

// ============================================================
// FACIAL HAIR ENFORCEMENT ON SPAWN
// Catches anyone who somehow has a banned style saved from before
// the restriction was added. Style won't be in SSaccessories list
// if it's lore_banned, so we just check for existence.
// ============================================================
/datum/species/proc/enforce_facial_hair_restrictions(mob/living/carbon/human/H)
	if(!H?.client)
		return
	if(!(H.facial_hairstyle in SSaccessories.facial_hairstyles_list))
		H.facial_hairstyle = "Shaved"
		H.update_hair()
		to_chat(H, span_warning("Your facial hair style has been reset: NT regulations prohibit styles that obstruct o2 mask seals."))
	if(!(H.hairstyle in SSaccessories.hairstyles_list))
		H.hairstyle = "Bald"
		H.update_hair()
		to_chat(H, span_warning("Your hairstyle has been reset: NT regulations prohibit styles that obstruct helmet seals."))

// Hook enforcement into species gain so it fires on every spawn
/datum/species/on_species_gain(mob/living/carbon/human/new_human, datum/species/old_species, pref_load, regenerate_icons = TRUE, replace_missing = TRUE)
	. = ..()
	if(pref_load)
		enforce_facial_hair_restrictions(new_human)
