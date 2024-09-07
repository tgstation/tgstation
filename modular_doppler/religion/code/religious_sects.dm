// Allowing religion to be reselected by new chaplains if something happened to the old one (cryo or being deleted)

/datum/religion_sect/on_select()
	. = ..()

	// if the same religious sect gets selected, carry the favor over
	if(istype(src, GLOB.prev_sect_type))
		set_favor(GLOB.prev_favor)

/// It's time to kill GLOB
/**
 * Reset religion to its default state so the new chaplain becomes high priest and can change the sect, armor, weapon type, etc
 * Also handles the selection of a holy successor from existing crew if multiple chaplains are on station.
 */
/proc/reset_religion()

	// try to pick the successor from existing crew, or leave it empty if no valid candidates found
	var/mob/living/carbon/human/chosen_successor = pick_holy_successor()
	GLOB.current_highpriest = chosen_successor ? WEAKREF(chosen_successor) : null // if a successor is already on the station then pick the first in line

	if(isnull(GLOB.religious_sect)) // sect already been reset, maybe a chaplain cryo'd before choosing a sect
		return

	// remember what the previous sect and favor values were so they can be restored if the same one gets chosen
	GLOB.prev_favor = GLOB.religious_sect.favor
	GLOB.prev_sect_type = GLOB.religious_sect.type

	// set the altar references to the old religious_sect to null
	SEND_GLOBAL_SIGNAL(COMSIG_RELIGIOUS_SECT_RESET)

	QDEL_NULL(GLOB.religious_sect) // queue for removal but also set it to null, in case a new chaplain joins before it can be deleted

	// set the rest of the global vars to null for the new chaplain
	GLOB.religion = null
	GLOB.deity = null
	GLOB.bible_name = null
	GLOB.bible_icon_state = null
	GLOB.bible_inhand_icon_state = null
	GLOB.holy_armor_type = null
	GLOB.holy_weapon_type = null

/**
 * Chooses a valid holy successor from GLOB.holy_successor weakref list and sets things up for them to be the new high priest
 *
 * Returns the chosen holy successor, or null if no valid successor
 */
/proc/pick_holy_successor()
	for(var/datum/weakref/successor as anything in GLOB.holy_successors)
		var/mob/living/carbon/human/actual_successor = successor.resolve()
		if(!actual_successor)
			GLOB.holy_successors -= successor
			continue

		if(!actual_successor.key || !actual_successor.mind)
			continue

		// we have a match! set the religious globals up properly and make the candidate high priest
		GLOB.holy_successors -= successor
		GLOB.religion = actual_successor.client?.prefs?.read_preference(/datum/preference/name/religion) || DEFAULT_RELIGION
		GLOB.bible_name = actual_successor.client?.prefs?.read_preference(/datum/preference/name/deity) || DEFAULT_DEITY
		GLOB.deity = actual_successor.client?.prefs?.read_preference(/datum/preference/name/bible) || DEFAULT_BIBLE

		actual_successor.mind.holy_role = HOLY_ROLE_HIGHPRIEST

		to_chat(actual_successor, span_warning("You have been chosen as the successor to the previous high priest. Visit a holy altar to declare the station's religion!"))

		return actual_successor

	return null

/**
 * Create a list of the holy successors mobs from GLOB.holy_successors weakref list
 *
 * Returns the list of valid holy successors
 */
/proc/list_holy_successors()
	var/list/holy_successors = list()
	for(var/datum/weakref/successor as anything in GLOB.holy_successors)
		var/mob/living/carbon/human/actual_successor = successor.resolve()
		if(!actual_successor)
			GLOB.holy_successors -= successor
			continue

		holy_successors += actual_successor

	return holy_successors
