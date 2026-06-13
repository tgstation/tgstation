// Apsis-Station DOWNSTREAM - species eligibility overrides
// Depends on: species_whitelist.dm
// Fragility note: if upstream renames check_roundstart_eligible() or
// changes its signature, verify this file still compiles and works.

// ============================================================
// FELINIDS
// ============================================================
/datum/species/human/felinid/check_roundstart_eligible(mob/living/carbon/human/player)
	if(!ckey_in_species_whitelist(player, "felinid_whitelist.txt"))
		return FALSE
	return ..()

// ============================================================
// LIZARDS
// ============================================================
/datum/species/lizard/check_roundstart_eligible(mob/living/carbon/human/player)
	if(!ckey_in_species_whitelist(player, "lizard_whitelist.txt"))
		return FALSE
	return ..()

// ============================================================
// MOTHS
// ============================================================
/datum/species/moth/check_roundstart_eligible(mob/living/carbon/human/player)
	if(!ckey_in_species_whitelist(player, "moth_whitelist.txt"))
		return FALSE
	return ..()

// ============================================================
// FACIAL HAIR ENFORCEMENT ON SPAWN
// Catches anyone who somehow has a banned style saved
// ============================================================
/datum/species/proc/enforce_facial_hair_restrictions(mob/living/carbon/human/H)
	if(!H?.client)
		return
	var/datum/sprite_accessory/facial_hair/style = GLOB.facial_hairstyles_list[H.facial_hairstyle]
	if(style?.lore_banned)
		H.facial_hairstyle = "None"
		H.update_hair()
		to_chat(H, span_warning("Your facial hair style has been reset: NT regulations prohibit styles that obstruct o2 mask seals."))

// Hook enforcement into species gain so it fires on every spawn
/datum/species/on_species_gain(mob/living/carbon/human/new_human, datum/species/old_species, pref_load, regenerate_icons = TRUE, replace_missing = TRUE)
	. = ..()
	if(pref_load)
		enforce_facial_hair_restrictions(new_human)
