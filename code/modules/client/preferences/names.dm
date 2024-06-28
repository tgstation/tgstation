/// A preference for a name. Used not just for normal names, but also for clown names, etc.
/datum/preference/name
	category = "names"
	priority = PREFERENCE_PRIORITY_NAMES
	savefile_identifier = PREFERENCE_CHARACTER
	abstract_type = /datum/preference/name

	/// The display name when showing on the "other names" panel
	var/explanation

	/// These will be grouped together on the preferences menu
	var/group

	/// Whether or not to allow numbers in the person's name
	var/allow_numbers = FALSE

	/// If the highest priority job matches this, will prioritize this name in the UI
	var/relevant_job

/datum/preference/name/apply_to_human(mob/living/carbon/human/target, value)
	// Only real_name applies directly, everything else is applied by something else
	return

/datum/preference/name/deserialize(input, datum/preferences/preferences)
	return reject_bad_name("[input]", allow_numbers)

/datum/preference/name/serialize(input)
	// `is_valid` should always be run before `serialize`, so it should not
	// be possible for this to return `null`.
	return reject_bad_name(input, allow_numbers)

/datum/preference/name/is_valid(value)
	return istext(value) && !isnull(reject_bad_name(value, allow_numbers))

/// A character's real name
/datum/preference/name/real_name
	explanation = "Name"
	// The `_` makes it first in ABC order.
	group = "_real_name"
	savefile_key = "real_name"

/datum/preference/name/real_name/apply_to_human(mob/living/carbon/human/target, value)
	target.real_name = value
	target.name = value
	target.log_mob_tag("TAG: [target.tag] RENAMED: [key_name(target)]")

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	return generate_random_name_species_based(
		preferences.read_preference(/datum/preference/choiced/gender),
		TRUE,
		preferences.read_preference(/datum/preference/choiced/species),
	)

/datum/preference/name/real_name/deserialize(input, datum/preferences/preferences)
	input = ..(input)
	if (!input)
		return input

	if (CONFIG_GET(flag/humans_need_surnames) && preferences.read_preference(/datum/preference/choiced/species) == /datum/species/human)
		var/first_space = findtext(input, " ")
		if(!first_space) //we need a surname
			input += " [pick(GLOB.last_names)]"
		else if(first_space == length(input))
			input += "[pick(GLOB.last_names)]"

	return reject_bad_name(input, allow_numbers)

/// The name for a backup human, when nonhumans are made into head of staff
/datum/preference/name/backup_human
	explanation = "Backup human name"
	group = "backup_human"
	savefile_key = "human_name"

/datum/preference/name/backup_human/create_informed_default_value(datum/preferences/preferences)
	return generate_random_name(preferences.read_preference(/datum/preference/choiced/gender))

/datum/preference/name/clown
	savefile_key = "clown_name"

	explanation = "Clown name"
	group = "fun"
	relevant_job = /datum/job/clown

/datum/preference/name/clown/create_default_value()
	return pick(GLOB.clown_names)

/datum/preference/name/mime
	savefile_key = "mime_name"

	explanation = "Mime name"
	group = "fun"
	relevant_job = /datum/job/mime

/datum/preference/name/mime/create_default_value()
	return pick(GLOB.mime_names)

/datum/preference/name/cyborg
	savefile_key = "cyborg_name"

	allow_numbers = TRUE
	can_randomize = FALSE

	explanation = "Cyborg name"
	group = "silicons"
	relevant_job = /datum/job/cyborg

/datum/preference/name/cyborg/create_default_value()
	return DEFAULT_CYBORG_NAME

/datum/preference/name/ai
	savefile_key = "ai_name"

	allow_numbers = TRUE
	explanation = "AI name"
	group = "silicons"
	relevant_job = /datum/job/ai

/datum/preference/name/ai/create_default_value()
	return pick(GLOB.ai_names)

/datum/preference/name/religion
	savefile_key = "religion_name"

	allow_numbers = TRUE

	explanation = "Religion name"
	group = "religion"

/datum/preference/name/religion/create_default_value()
	return pick(GLOB.religion_names)

/datum/preference/name/deity
	savefile_key = "deity_name"

	allow_numbers = TRUE
	can_randomize = FALSE

	explanation = "Deity name"
	group = "religion"

/datum/preference/name/deity/create_default_value()
	return DEFAULT_DEITY

/datum/preference/name/bible
	savefile_key = "bible_name"

	allow_numbers = TRUE
	can_randomize = FALSE

	explanation = "Bible name"
	group = "religion"

/datum/preference/name/bible/create_default_value()
	return DEFAULT_BIBLE

/// The first name given to nuclear operative antagonists. The last name will be chosen by the team leader.
/datum/preference/name/operative_alias
	savefile_key = "operative_alias"
	allow_numbers = TRUE //You can get a little wacky with your alias nobody will judge you
	explanation = "Operative Alias"
	group = "antagonists"

/datum/preference/name/operative_alias/create_default_value()
	return pick(GLOB.operative_aliases)

/datum/preference/name/operative_alias/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE

	// If one of the roles is ticked in the antag prefs menu, this option will show.
	var/static/list/ops_roles = list(ROLE_OPERATIVE, ROLE_LONE_OPERATIVE, ROLE_OPERATIVE_MIDROUND, ROLE_CLOWN_OPERATIVE)
	if(length(ops_roles & preferences.be_special))
		return TRUE

	return FALSE


/// The name to use while bitrunning
/datum/preference/name/hacker_alias
	explanation = "Hacker alias"
	group = "bitrunning"
	savefile_key = "hacker_alias"
	allow_numbers = TRUE
	relevant_job = /datum/job/bitrunner

/datum/preference/name/hacker_alias/create_default_value()
	return pick(GLOB.hacker_aliases)
