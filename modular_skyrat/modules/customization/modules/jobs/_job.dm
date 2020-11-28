/datum/job
	///With this set to TRUE, the loadout will be applied before a job clothing will be
	var/no_dresscode
	//Whether the job can use the loadout system
	var/loadout = TRUE
	//List of banned quirks in their names(dont blame me, that's how they're stored), players can't join as the job if they have the quirk. Associative for the purposes of performance
	var/list/banned_quirks

/datum/job/proc/has_banned_quirk(datum/preferences/pref)
	if(!pref) //No preferences? We'll let you pass, this time (just a precautionary check,you dont wanna mess up gamemode setting logic)
		return FALSE
	if(banned_quirks)
		for(var/Q in pref.all_quirks)
			if(banned_quirks[Q])
				return TRUE
	return FALSE

/datum/job/assistant
	no_dresscode = TRUE

/datum/job/officer
	banned_quirks = list(SEC_RESTRICTED_QUIRKS)

/datum/job/detective
	banned_quirks = list(SEC_RESTRICTED_QUIRKS)

/datum/job/warden
	banned_quirks = list(SEC_RESTRICTED_QUIRKS)

/datum/job/blueshield
	banned_quirks = list(SEC_RESTRICTED_QUIRKS)

/datum/job/hos
	banned_quirks = list(SEC_RESTRICTED_QUIRKS, HEAD_RESTRICTED_QUIRKS)

/datum/job/cmo
	banned_quirks = list(HEAD_RESTRICTED_QUIRKS)

/datum/job/chief_engineer
	banned_quirks = list(HEAD_RESTRICTED_QUIRKS, "Paraplegic" = TRUE)

/datum/job/rd
	banned_quirks = list(HEAD_RESTRICTED_QUIRKS)

/datum/job/hop
	banned_quirks = list(HEAD_RESTRICTED_QUIRKS)

/datum/job/qm
	banned_quirks = list(HEAD_RESTRICTED_QUIRKS)

/datum/job/ai
	loadout = FALSE

/datum/job/cyborg
	loadout = FALSE
