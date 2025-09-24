
/mob/living/carbon/human/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job", hand_first = TRUE)
	var/obj/item/card/id/id = get_idcard(hand_first)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_id
	if(id)
		. = id.assignment
	else
		var/obj/item/modular_computer/pda = wear_id
		if(istype(pda))
			. = pda.saved_job
		else
			return if_no_id
	if(!.)
		return if_no_job

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = get_idcard(FALSE)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_id
	if(id)
		return id.registered_name
	var/obj/item/modular_computer/pda = wear_id
	if(istype(pda))
		return pda.saved_identification
	return if_no_id

/// Used to update our name based on whether our face is obscured/disfigured
/mob/living/carbon/human/proc/update_visible_name()
	SIGNAL_HANDLER
	name = get_visible_name()

/// Combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a separate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	var/list/identity = list(null, null, null)
	SEND_SIGNAL(src, COMSIG_HUMAN_GET_VISIBLE_NAME, identity)
	var/signal_face = LAZYACCESS(identity, VISIBLE_NAME_FACE)
	var/signal_id = LAZYACCESS(identity, VISIBLE_NAME_ID)
	var/force_set = LAZYACCESS(identity, VISIBLE_NAME_FORCED)
	if(force_set) // our name is overriden by something
		return signal_face // no need to null-check, because force_set will always set a signal_face

	var/face_name = isnull(signal_face) ? get_face_name("") : signal_face
	var/id_name = isnull(signal_id) ? get_id_name("",  honorifics = TRUE) : signal_id

	// We need to account for real name
	if(force_real_name)
		var/disguse_name = get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
		return "[real_name][disguse_name == real_name ? "" : " (as [disguse_name])"]"

	// We're just some unknown guy
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE) || HAS_TRAIT(src, TRAIT_INVISIBLE_MAN))
		return "Unknown"

	// We have a face and an ID
	if(face_name && id_name)
		var/normal_id_name = get_id_name("") // need to check base ID name to avoid "John (as Captain John)"
		if(normal_id_name == face_name)
			return id_name // (this turns "John" into "Captain John")
		if(add_id_name)
			return "[face_name] (as [id_name])"

	// Just go down the list of stuff we recorded
	return face_name || id_name || "Unknown"

/**
 * Gets what the face of this mob looks like
 *
 * * if_no_face - What to return if we have no face or our face is obscured/disfigured
 */
/mob/living/carbon/proc/get_face_name(if_no_face = "Unknown")
	return real_name

/mob/living/carbon/human/get_face_name(if_no_face = "Unknown")
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_face //We're Unknown, no face information for you
	if(obscured_slots & HIDEFACE)
		return if_no_face
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	if(isnull(head) || !real_name || HAS_TRAIT(src, TRAIT_DISFIGURED) || HAS_TRAIT(src, TRAIT_INVISIBLE_MAN)) //disfigured. use id-name if possible
		return if_no_face
	return real_name

/**
 * Gets whatever name is in our ID or PDA
 *
 * * if_no_id - What to return if we have no ID or PDA
 * * honorifics - Whether to include honorifics in the returned name (if the found ID has any set)
 */
/mob/living/carbon/proc/get_id_name(if_no_id = "Unknown", honorifics = FALSE)
	return

/mob/living/carbon/human/get_id_name(if_no_id = "Unknown", honorifics = FALSE)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		var/list/identity = list(null, null, null)
		SEND_SIGNAL(src, COMSIG_HUMAN_GET_FORCED_NAME, identity)
		return identity[VISIBLE_NAME_FORCED] ? identity[VISIBLE_NAME_FACE] : if_no_id

	// either results in an ID card, a generic card, or null
	var/obj/item/card/id = wear_id?.GetID() || astype(wear_id, /obj/item/card)
	return id?.get_displayed_name(honorifics) || if_no_id

/mob/living/carbon/human/get_idcard(hand_first = TRUE)
	. = ..()
	if(. && hand_first)
		return
	//Check inventory slots
	return (wear_id?.GetID() || belt?.GetID())

/mob/living/carbon/human/can_use_guns(obj/item/G)
	. = ..()
	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(check_chunky_fingers())
			balloon_alert(src, "fingers are too big!")
			return FALSE
	if(HAS_TRAIT(src, TRAIT_NOGUNS))
		to_chat(src, span_warning("You can't bring yourself to use a ranged weapon!"))
		return FALSE

/mob/living/carbon/human/proc/check_chunky_fingers()
	if(HAS_TRAIT_NOT_FROM(src, TRAIT_CHUNKYFINGERS, RIGHT_ARM_TRAIT) && HAS_TRAIT_NOT_FROM(src, TRAIT_CHUNKYFINGERS, LEFT_ARM_TRAIT))
		return TRUE
	return IS_LEFT_INDEX(active_hand_index) ? HAS_TRAIT_FROM(src, TRAIT_CHUNKYFINGERS, LEFT_ARM_TRAIT) : HAS_TRAIT_FROM(src, TRAIT_CHUNKYFINGERS, RIGHT_ARM_TRAIT)

/mob/living/carbon/human/get_policy_keywords()
	. = ..()
	. += "[dna.species.type]"

/mob/living/carbon/human/proc/get_eye_scars()
	var/obj/item/organ/eyes/eyes = get_organ_slot(ORGAN_SLOT_EYES)
	if (!isnull(eyes))
		return eyes.scarring

/// When we're joining the game in [/mob/dead/new_player/proc/create_character], we increment our scar slot then store the slot in our mind datum.
/mob/living/carbon/human/proc/increment_scar_slot()
	var/check_ckey = ckey || client?.ckey
	if(!check_ckey || !mind || !client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
		return

	var/path = "data/player_saves/[check_ckey[1]]/[check_ckey]/scars.sav"
	var/index = mind.current_scar_slot_index
	if(!index)
		if(fexists(path))
			var/savefile/F = new /savefile(path)
			index = F["current_scar_index"] || 1
		else
			index = 1

	mind.current_scar_slot_index = (index % PERSISTENT_SCAR_SLOTS) + 1 || 1

/// For use formatting all of the scars this human has for saving for persistent scarring, returns a string with all current scars/missing limb amputation scars for saving or loading purposes
/mob/living/carbon/human/proc/format_scars()
	var/list/missing_bodyparts = get_missing_limbs()
	if(!all_scars && !length(missing_bodyparts))
		return
	var/scars = ""
	for(var/i in missing_bodyparts)
		var/datum/scar/scaries = new
		scars += "[scaries.format_amputated(i)]"
	for(var/datum/scar/iter_scar as anything in all_scars)
		if(!iter_scar.fake)
			scars += "[iter_scar.format()];"
	return scars

/// Takes a single scar from the persistent scar loader and recreates it from the saved data
/mob/living/carbon/human/proc/load_scar(scar_line, specified_char_index)
	var/list/scar_data = splittext(scar_line, "|")
	if(LAZYLEN(scar_data) != SCAR_SAVE_LENGTH)
		return // invalid, should delete
	var/version = text2num(scar_data[SCAR_SAVE_VERS])
	if(!version || version != SCAR_CURRENT_VERSION) // get rid of scars using a incompatable version
		return
	if(specified_char_index && (mind?.original_character_slot_index != specified_char_index))
		return
	if (isnull(text2num(scar_data[SCAR_SAVE_BIOLOGY])))
		return
	var/obj/item/bodypart/the_part = get_bodypart("[scar_data[SCAR_SAVE_ZONE]]")
	var/datum/scar/scaries = new
	return scaries.load(the_part, scar_data[SCAR_SAVE_VERS], scar_data[SCAR_SAVE_DESC], scar_data[SCAR_SAVE_PRECISE_LOCATION], text2num(scar_data[SCAR_SAVE_SEVERITY]), text2num(scar_data[SCAR_SAVE_BIOLOGY]), text2num(scar_data[SCAR_SAVE_CHAR_SLOT]), text2num(scar_data[SCAR_SAVE_CHECK_ANY_BIO]))

/// Read all the scars we have for the designated character/scar slots, verify they're good/dump them if they're old/wrong format, create them on the user, and write the scars that passed muster back to the file
/mob/living/carbon/human/proc/load_persistent_scars()
	if(!ckey || !mind?.original_character_slot_index || !client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
		return

	var/path = "data/player_saves/[ckey[1]]/[ckey]/scars.sav"
	var/loaded_char_slot = client.prefs.default_slot

	if(!loaded_char_slot || !fexists(path))
		return FALSE
	var/savefile/F = new /savefile(path)
	if(!F)
		return

	var/char_index = mind.original_character_slot_index
	var/scar_index = mind.current_scar_slot_index || F["current_scar_index"] || 1

	var/scar_string = F["scar[char_index]-[scar_index]"]
	var/valid_scars = ""

	for(var/scar_line in splittext(sanitize_text(scar_string), ";"))
		if(load_scar(scar_line, char_index))
			valid_scars += "[scar_line];"

	WRITE_FILE(F["scar[char_index]-[scar_index]"], sanitize_text(valid_scars))

/// Save any scars we have to our designated slot, then write our current slot so that the next time we call [/mob/living/carbon/human/proc/increment_scar_slot] (the next round we join), we'll be there
/mob/living/carbon/human/proc/save_persistent_scars(nuke = FALSE)
	if(!ckey || !mind?.original_character_slot_index || !client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
		return

	var/path = "data/player_saves/[ckey[1]]/[ckey]/scars.sav"
	var/savefile/F = new /savefile(path)
	var/char_index = mind.original_character_slot_index
	var/scar_index = mind.current_scar_slot_index || F["current_scar_index"] || 1

	if(nuke)
		WRITE_FILE(F["scar[char_index]-[scar_index]"], "")
		return

	for(var/k in all_wounds)
		var/datum/wound/iter_wound = k
		iter_wound.remove_wound() // so we can get the scars for open wounds

	var/valid_scars = format_scars()
	WRITE_FILE(F["scar[char_index]-[scar_index]"], sanitize_text(valid_scars))
	WRITE_FILE(F["current_scar_index"], sanitize_integer(scar_index))

///copies over clothing preferences like underwear to another human
/mob/living/carbon/human/proc/copy_clothing_prefs(mob/living/carbon/human/destination)
	destination.underwear = underwear
	destination.underwear_color = underwear_color
	destination.undershirt = undershirt
	destination.socks = socks
	destination.jumpsuit_style = jumpsuit_style


/// Fully randomizes everything according to the given flags.
/mob/living/carbon/human/proc/randomize_human_appearance(randomize_flags = ALL)
	var/datum/preferences/preferences = new(new /datum/client_interface)

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			preference.apply_to_human(src, preference.create_random_value(preferences))

	fully_replace_character_name(real_name, generate_random_mob_name())

/**
 * Setter for mob height - updates the base height of the mob (which is then adjusted by traits or species)
 *
 * Exists so that the update is done immediately
 *
 * Returns TRUE if changed, FALSE otherwise
 */
/mob/living/carbon/human/proc/set_mob_height(new_height)
	base_mob_height = new_height
	update_mob_height()

/**
 * Updates the mob's height
 *
 * Mainly so that dwarfism can adjust height without needing to override existing height
 *
 * Returns a mob height num
 */
/mob/living/carbon/human/proc/update_mob_height()
	var/old_height = mob_height
	mob_height = dna?.species?.update_species_heights(src) || base_mob_height
	if(old_height != mob_height)
		regenerate_icons()

/**
 * Makes a full copy of src and returns it.
 * Attempts to copy as much as possible to be a close to the original.
 * This includes job outfit (which handles skillchips), quirks, and mutations.
 * We do not set a mind here, so this is purely the body.
 * Args:
 * location - The turf the human will be spawned on.
 */
/mob/living/carbon/human/proc/make_full_human_copy(turf/location, client/quirk_client)
	RETURN_TYPE(/mob/living/carbon/human)

	var/mob/living/carbon/human/clone = new(location)

	clone.fully_replace_character_name(null, dna.real_name)
	copy_clothing_prefs(clone)
	clone.age = age
	clone.voice = voice
	clone.pitch = pitch
	dna.copy_dna(clone.dna, COPY_DNA_SE|COPY_DNA_SPECIES|COPY_DNA_MUTATIONS)

	clone.dress_up_as_job(SSjob.get_job(job))

	for(var/datum/quirk/original_quircks as anything in quirks)
		clone.add_quirk(original_quircks.type, override_client = client, announce = FALSE)

	clone.updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)

	return clone

/mob/living/carbon/human/calculate_fitness()
	var/fitness_modifier = 1
	if (HAS_TRAIT(src, TRAIT_HULK))
		fitness_modifier *= 2
	if (HAS_TRAIT(src, TRAIT_STRENGTH))
		fitness_modifier *= 1.5
	if (HAS_TRAIT(src, TRAIT_ROD_SUPLEX))
		fitness_modifier *= 2 // To be able to suplex a rod, you must possess an incredible amount of power
	if (HAS_TRAIT(src, TRAIT_EASILY_WOUNDED))
		fitness_modifier /= 2
	if (HAS_TRAIT(src, TRAIT_GAMER))
		fitness_modifier /= 1.5
	if (HAS_TRAIT(src, TRAIT_GRABWEAKNESS))
		fitness_modifier /= 1.5

	var/athletics_level = mind?.get_skill_level(/datum/skill/athletics) || 1

	var/min_damage = 0
	var/max_damage = 0
	for (var/body_zone in GLOB.limb_zones)
		var/obj/item/bodypart/part = get_bodypart(body_zone)
		if (isnull(part) || part.unarmed_damage_high <= 0 || HAS_TRAIT(part, TRAIT_PARALYSIS))
			continue
		min_damage += part.unarmed_damage_low
		max_damage += part.unarmed_damage_high

	var/damage = ((min_damage / 4) + (max_damage / 4)) / 2 // We expect you to have 4 functional limbs- if you have fewer you're probably not going to be so good at lifting

	return ceil(damage * (ceil(athletics_level / 2)) * fitness_modifier * maxHealth)

/mob/living/carbon/human/proc/item_heal(mob/user, brute_heal, burn_heal, heal_message_brute, heal_message_burn, required_bodytype)
	var/obj/item/bodypart/affecting = src.get_bodypart(check_zone(user.zone_selected))
	if (!affecting || !(affecting.bodytype & required_bodytype))
		to_chat(user, span_warning("[affecting] is already in good condition!"))
		return FALSE

	var/brute_damaged = affecting.brute_dam > 0
	var/burn_damaged = affecting.burn_dam > 0

	var/nothing_to_heal = ((brute_heal <= 0 || !brute_damaged) && (burn_heal <= 0 || !burn_damaged))
	if (nothing_to_heal)
		to_chat(user, span_notice("[affecting] is already in good condition!"))
		return FALSE

	src.update_damage_overlays()
	var/message
	if ((brute_damaged && brute_heal > 0) && (burn_damaged && burn_heal > 0))
		message = "[heal_message_brute] and [heal_message_burn] on"
	else if (brute_damaged && brute_heal > 0)
		message = "[heal_message_brute] on"
	else
		message = "[heal_message_burn] on"
	affecting.heal_damage(brute_heal, burn_heal, required_bodytype)
	user.visible_message(span_notice("[user] fixes some of the [message] [src]'s [affecting.name]."), \
		span_notice("You fix some of the [message] [src == user ? "your" : "[src]'s"] [affecting.name]."))
	return TRUE

/// Sets both mob's and eye organ's eye color values
/// If color_right is not passed, its assumed to be the same as color_left
/mob/living/carbon/human/proc/set_eye_color(color_left, color_right)
	if (!color_right)
		color_right = color_left
	eye_color_left = color_left
	eye_color_right = color_right
	// Doesn't assign eye color if they already have one from their type
	var/obj/item/organ/eyes/eyes = get_organ_by_type(/obj/item/organ/eyes)
	if (istype(eyes) && !initial(eyes.eye_color_left) && !initial(eyes.eye_color_right))
		eyes.eye_color_left = color_left
		eyes.eye_color_right = color_right
		eyes.refresh(src, FALSE)
