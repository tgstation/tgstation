/datum/preference_slot
	var/id
	var/list/entries

/datum/preference_slot/New(json, _id)
	var/list/_entries = list()
	for(var/I in subtypesof(/datum/preference_entry))
		if(I == /datum/preference_entry)
			continue
		var/datum/preference_entry/P = I
		if(initial(P.abstract_type) == P)
			continue
		_entries[I] = new I
	entries = _entries

/datum/preference_slot/proc/Load(raw_json, row_id)
	if(!isnum(row_id))
		CRASH("Invalid row id for preference slot!")
	id = row_id
	var/list/json = json_decode(raw_json)
	if(!json)
		CRASH("Invalid json for preference slot: [raw_json]")
	
	var/list/_entries = entries
	for(var/I in _entries)
		var/list/entry_value = json["[I]"]
		if(!entry_value)
			continue
		
		var/datum/preference_entry/P = _entries[I]
		var/value = entry_value[1]
		if(value != P.value)
			P.modified = TRUE
			P.value = value

		var/saved_version = entry_value[1] 
		var/p_version = P.version
		if(p_version < saved_version)
			//don't save 
			P.version = -1
		else
			while (p_version > saved_version)
				P.Migrate(saved_version)
				++saved_version

/datum/preference_slot/proc/CopyFrom(datum/preference_slot/other)
	var/list/_entries = entries
	var/list/other_entries = other.entries
	for(var/I in _entries)
		var/datum/preference_entry/target = _entries[I]
		var/datum/preference_entry/source = other_entries[I]
		target.value = source.value
		target.version = source.version

/datum/preference_slot/proc/ToJSON()
	var/list/_entries = entries
	var/list/keys_and_values = list()
	for(var/I in _entries)
		var/datum/preference_entry/P = _entries[I]

		var/p_value = P.value
		var/p_version = P.version
		if(p_version || p_value == P.default)
			continue
		
		keys_and_values[I] = list(p_version, p_version)
	return json_encode(keys_and_values)

/datum/preference_slot/proc/ApplyToMob(mob/living/carbon/human/character)
	var/list/_entries = entries
	for(var/I in _entries)
		var/datum/preference_entry/P = _entries[I]
		P.ApplyToMob(character)

/datum/preference_slot/proc/LegacyLoad(savefile/S, slot_number)
	var/list/_entries = entries
	for(var/I in _entries)
		var/datum/preference_entry/P = _entries[I]
		S.cd = P.legacy_root_slot ? "/" : "character[slot_number]"
		P.LegacyLoad(S)
