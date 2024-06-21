#define MAX_FLAVOR_LEN 2048

/datum/preference/multiline_text
	abstract_type = /datum/preference/multiline_text
	can_randomize = FALSE
	var/max_length = MAX_FLAVOR_LEN

/datum/preference/multiline_text/deserialize(input, datum/preferences/preferences)
	return STRIP_HTML_SIMPLE("[input]", max_length)

/datum/preference/multiline_text/serialize(input)
	return STRIP_HTML_SIMPLE(input, max_length)

/datum/preference/multiline_text/is_valid(value)
	return istext(value) && !isnull(STRIP_HTML_SIMPLE(value, max_length))

/datum/preference/multiline_text/create_default_value()
	return null

/datum/preference/multiline_text/compile_constant_data()
	return list("maximum_length" = max_length)

/// Preferences that add onto flavor text datum
/datum/preference/multiline_text/flavor_datum
	abstract_type = /datum/preference/multiline_text/flavor_datum
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_NAMES

/datum/preference/multiline_text/flavor_datum/apply_to_human(mob/living/carbon/human/target, value)
	if(!length(value) || istype(target, /mob/living/carbon/human/dummy)) // Don't stick flavor text on dummies
		return

	var/datum/flavor_text/our_flavor = target.linked_flavor || add_or_get_mob_flavor_text(target)
	if(isnull(our_flavor))
		return

	add_to_flavor_datum(our_flavor, value)

/datum/preference/multiline_text/flavor_datum/proc/add_to_flavor_datum(datum/flavor_text/our_flavor, value)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("add_to_flavor_datum not implemented for [type]")

/datum/preference/multiline_text/flavor_datum/flavor
	savefile_key = "flavor_text"

/datum/preference/multiline_text/flavor_datum/flavor/add_to_flavor_datum(datum/flavor_text/our_flavor, value)
	our_flavor.flavor_text = value

/datum/preference/multiline_text/flavor_datum/silicon
	savefile_key = "silicon_text"

/datum/preference/multiline_text/flavor_datum/silicon/add_to_flavor_datum(datum/flavor_text/our_flavor, value)
	our_flavor.silicon_text = value

/datum/preference/multiline_text/flavor_datum/exploitable
	savefile_key = "exploitable_info"

/datum/preference/multiline_text/flavor_datum/exploitable/add_to_flavor_datum(datum/flavor_text/our_flavor, value)
	our_flavor.expl_info = value

/// Preferences that add onto crew records
/datum/preference/multiline_text/record
	abstract_type = /datum/preference/multiline_text/record
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_NAMES
	max_length = MAX_FLAVOR_LEN

/datum/preference/multiline_text/record/New()
	. = ..()
	// This is here to catch people who have preferences assigned before the manifest is built (IE: roundstart players)
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(on_new_player_joined))
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(unregister_join_sig))
	// Confusingly, roundstart character setup goes "create characters" -> "assign quirks" -> "build manifest" -> "transfer clients in"
	// while latejoin character setup is "create charater" -> "transfer clients in" -> "inject manifest entry" -> "assign quirks"

/datum/preference/multiline_text/record/proc/on_new_player_joined(datum/source, mob/living/carbon/human/joined, rank)
	SIGNAL_HANDLER

	apply_to_human_records(joined)

/datum/preference/multiline_text/record/proc/unregister_join_sig()
	SIGNAL_HANDLER

	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/datum/preference/multiline_text/record/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/multiline_text/record/after_apply_to_human(mob/living/carbon/human/target, datum/preferences/prefs, value)
	apply_to_human_records(target, prefs, value)

/datum/preference/multiline_text/record/proc/apply_to_human_records(mob/living/carbon/human/joined, datum/preferences/prefs, value)
	if(!ishuman(joined) || istype(joined, /mob/living/carbon/human/dummy)) // Fairly certain this is redundant but let's just be safe
		return

	prefs ||= joined.client?.prefs
	if(isnull(prefs))
		CRASH("[type] was applied to a mob ([joined]) without prefs.")

	value ||= prefs.read_preference(type)
	if(!length(value))
		return // valid

	var/datum/record/crew/associated_record = find_record(joined.real_name)
	if(isnull(associated_record))
		if(length(GLOB.manifest?.general))
			stack_trace("[type] was applied to a mob ([joined], [joined.key]) before their record was created.")
		return

	add_to_record(associated_record, value)

/datum/preference/multiline_text/record/proc/add_to_record(datum/record/crew/associated_record, value)
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("add_to_record not implemented for [type]")

/datum/preference/multiline_text/record/general
	savefile_key = "general_records"

/datum/preference/multiline_text/record/general/add_to_record(datum/record/crew/associated_record, value)
	var/fake_author = "Record Database"
	for(var/datum/medical_note/existing_note as anything in associated_record.medical_notes)
		if(existing_note.author == fake_author)
			existing_note.content = value
			return

	var/datum/medical_note/new_note = new(fake_author, value)
	new_note.time = "Past record"
	associated_record.medical_notes += new_note

/datum/preference/multiline_text/record/medical
	savefile_key = "medical_records"

/datum/preference/multiline_text/record/medical/add_to_record(datum/record/crew/associated_record, value)
	var/fake_author = "Medical Database"
	for(var/datum/medical_note/existing_note as anything in associated_record.medical_notes)
		if(existing_note.author == fake_author)
			existing_note.content = value
			return

	var/datum/medical_note/new_note = new(fake_author, value)
	new_note.time = "Past record"
	associated_record.medical_notes += new_note

/datum/preference/multiline_text/record/security
	savefile_key = "security_records"

/datum/preference/multiline_text/record/security/add_to_record(datum/record/crew/associated_record, value)
	var/fake_author = "Security Database"
	for(var/datum/crime/existing_note as anything in associated_record.crimes)
		if(existing_note.author == fake_author)
			existing_note.details = value
			return

	var/datum/crime/new_crime = new("Notes / Past infractions", value, fake_author, "Indetermined")
	new_crime.time = "Past record"
	new_crime.valid = FALSE // This makes it so the record is printed as "REDACTED", which I think is cool
	associated_record.crimes += new_crime

#undef MAX_FLAVOR_LEN
