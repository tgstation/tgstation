// -- Extra helper procs for humans. --

/* Determine if the current mob's real identity is visible.
 * This probably has a lot of edge cases that will get missed but we can find those later.
 * (There's gotta be a helper proc for this that already exists in the code, right?)
 *
 * returns a reference to a mob -
 *	- returns SRC if [src] isn't disguised, or is wearing their id / their name is visible
 *	- returns another mob if [src] is disguised as someone that exists in the world
 * returns null otherwise.
 */
/mob/living/proc/get_visible_flavor(mob/examiner)
	RETURN_TYPE(/datum/flavor_text)

	var/datum/flavor_text/found_flavor = linked_flavor
	// Simple animals, basic animals, anything that's not a human/silicon is lumped under "simple"
	if(found_flavor?.linked_species != "simple" || HAS_TRAIT(src, TRAIT_UNKNOWN))
		return null

	return found_flavor

/mob/living/carbon/human/get_visible_flavor(mob/examiner)
	// your identity is always known to you
	if(examiner == src)
		return linked_flavor

	var/shown_name = get_visible_name()
	if(shown_name == "Unknown" || HAS_TRAIT(src, TRAIT_UNKNOWN)) // Redundant, but just in case
		return null

	var/datum/flavor_text/found_flavor
	// the important check - if the visible name is our flavor text name, display our flavor text
	// if the visible name is not, however, we may be in disguise - so grab the corresponding flavor text from our global list
	if(shown_name == linked_flavor?.name || findtext(shown_name, linked_flavor?.name))
		found_flavor = linked_flavor
	else
		found_flavor = GLOB.flavor_texts[shown_name]

	// if you are not the species linked to the flavor text we found, you are not recognizable
	if(found_flavor?.linked_species != dna?.species.id)
		return null

	return found_flavor

/mob/living/silicon/get_visible_flavor(mob/examiner)
	if(examiner == src)
		return linked_flavor

	var/datum/flavor_text/found_flavor = linked_flavor
	if(found_flavor?.linked_species != "silicon" || HAS_TRAIT(src, TRAIT_UNKNOWN))
		return null

	return found_flavor

/mob/proc/check_med_hud_and_access()
	return FALSE

/mob/living/silicon/check_med_hud_and_access()
	return TRUE

/mob/living/carbon/human/check_med_hud_and_access()
	var/list/access = wear_id?.GetAccess()
	return HAS_TRAIT(src, TRAIT_MEDICAL_HUD) && (ACCESS_MEDICAL in access)

/mob/proc/check_sec_hud_and_access()
	return FALSE

/mob/living/silicon/check_sec_hud_and_access()
	return TRUE

/mob/living/carbon/human/check_sec_hud_and_access()
	var/list/access = wear_id?.GetAccess()
	return  HAS_TRAIT(src, TRAIT_SECURITY_HUD) && (ACCESS_SECURITY in access)
