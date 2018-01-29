/datum/preferences
	var/ckey_owner
	var/max_slots = 3
	var/list/slots

	var/static/list/selected_slots
	var/static/selected_slots_dirty = FALSE

/datum/preferences/New(client/owner)
	ckey_owner = owner.ckey
	if(IsGuestKey(ckey_owner))
		max_slots = 1
	else if(owner.IsByondMember())
		max_slots = 8
	GLOB.preferences_datums[ckey_owner] = prefs
	if(SSdbcore.initialized)
		Load()

/datum/preferences/Destroy()
	QDEL_LIST(slots)
	GLOB.preferences_datums -= ckey_owner]
	return ..()

/datum/preferences/proc/Load()
	if(IsGuestKey(ckey_owner))
		slots = list(new /datum/preference_slot)
		return

	if(SSdbcore.Connect())
		var/datum/DBQuery/Q = SSdbcore.NewQuery("SELECT id, json FROM [format_table_name("preferences")] WHERE owner = '[ckey_owner]'")
		if(Q.Execute() && Q.NextRow())
			do
				var/datum/preference_slot/P = new
				if(P.Load(Q.items[2], Q.items[1]))
					LAZYADD(slots, P)
			while(Q.NextRow())
	if(LAZYLEN(slots) && !AttemptLegacyLoad())
		slots = list(new /datum/preference_slot)
	
	if(!selected_slots)
		selected_slots = json_decode(file2text(PREFERENCES_SELECTED_SLOT_JSON))
		if(!selected_slots)
			selected_slots = list()
	
	if(!selected_slots[ckey_owner])
		selected_slots[ckey_owner] = 1

/datum/preferences/proc/Save(dry_run = FALSE)
	//go reg you meme
	if(IsGuestKey(ckey_owner))
		return FALSE
	var/rows = list()

	for(var/I in slots)
		var/datum/preference_slot/P = I
		var/json = sanitizeSQL(P.ToJSON())
		var/list/entry = list("json" = json, "ckey" = sanitizeSQL(ckey_owner))
		if(P_id != null)
			entry["id"] = sanitizeSQL(P_id)
		rows += list(entry)

	if(selected_slots_dirty && text2file(json_encode(selected_slots), PREFERENCES_SELECTED_SLOT_JSON))
		selected_slots_dirty = FALSE

	if(dry_run)
		return rows
	
	if(!SSdbcore.Connect())
		return FALSE

	return SSdbcore.MassInsert(format_table_name("preferences"), ., TRUE, TRUE)

/datum/preferences/proc/GetSelectedSlot()
	return IsGuestKey(ckey_owner) ? 1 : selected_slots[ckey_owner]

/datum/preferences/proc/ApplyToMob(mob/living/carbon/human/character)
	var/datum/preference_slot/P = slots[GetSelectedSlot()]
	P.ApplyToMob(character)

/datum/preferences/proc/ShowEditWindow(mob/user)
	CRASH("TODO")

/datum/preferences/proc/AttemptLegacyLoad()
	. = FALSE

	var/sfilePath = "data/player_saves/[copytext(ckey_owner, 1, 2)]/[ckey_owner]/preferences.sav"
	if(!fexists(sfilePath))
		return

	var/savefile/S = new(sfilePath)

	//forget about the crappy builtin version handling that shit was dumb
	for(var/I in 1 to max_slots)
		var/datum/preference_slot/P = new
		if(P.LegacyLoad(S, I))
			LAZYADD(slots, P)
	
	if(!slots)
		return
	
	. = TRUE

	if(!Save(FALSE))
		return

	S = null
	if(fcopy(sfilePath, "data/migrated_player_saves/[sfilePath].migrated"))
		fdel(sfilePath)

/datum/preferences/proc/SetSelectedSlot(index)
	if(slots.len < index)
		CRASH("Attempt to set preference slot to [index] while only having [slots.len] slots!")
	
	if(IsGuestKey(ckey_owner) || selected_slots[ckey_owner] == index)
		return

	selected_slots[ckey_owner] = index
	selected_slots_dirty = TRUE

/datum/preferences/proc/AddSlot()
	if(slots.len >= max_slots)
		return FALSE
	var/datum/preference_slot/P = new
	P.CopyFrom(GetSelectedSlot())
	slots += P
	return TRUE

/datum/preferences/proc/DeleteSlot(index)
	if(slots.len < index)
		CRASH("Attempt to delete non-existent preference slot [index]!")
	slots -= slots[index]
	if(!GetSelectedSlot())
		SetSelectedSlot(1)

/datum/preferences/proc/Get(entry_type)
	var/datum/preference_slot/P = GetSelectedSlot()
	var/datum/preference_entry/E = P.entries[entry_type]
	return E.value

/datum/preferences/proc/Set(entry_type, new_value)
	var/datum/preference_slot/P = GetSelectedSlot()
	var/datum/preference_entry/E = P.entries[entry_type]
	E.value = new_value
