/datum/id_trim/away
	access = list(ACCESS_AWAY_GENERAL)

/datum/id_trim/away/hotel
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/datum/id_trim/away/hotel/security
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/datum/id_trim/away/old/sec
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)
	assignment = "Charlie Station Security Officer"

/datum/id_trim/away/old/sci
	access = list(ACCESS_AWAY_GENERAL)
	assignment = "Charlie Station Scientist"

/datum/id_trim/away/old/eng
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)
	assignment = "Charlie Station Engineer"

/datum/id_trim/away/old/apc
	access = list(ACCESS_ENGINE_EQUIP)

/datum/id_trim/away/cat_surgeon
	assignment = "Cat Surgeon"
	trim_state = "trim_medicaldoctor"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/datum/id_trim/away/hilbert
	assignment = "Head Researcher"
	trim_state = "trim_researchdirector"
	access = list(ACCESS_AWAY_GENERIC3, ACCESS_RESEARCH)

/datum/id_trim/lifeguard
	assignment = "Lifeguard"

/datum/id_trim/space_bartender
	assignment = "Space Bartender"
	trim_state = "trim_bartender"
	access = list(ACCESS_BAR)

/datum/id_trim/centcom/corpse/bridge_officer
	assignment = "Bridge Officer"
	access = list(ACCESS_CENT_CAPTAIN)

/datum/id_trim/centcom/corpse/commander
	assignment = "Commander"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE)

/datum/id_trim/centcom/corpse/private_security
	assignment = "Private Security Force"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)

/datum/id_trim/centcom/corpse/private_security/tradepost_officer
	assignment = "Tradepost Officer"

/datum/id_trim/centcom/corpse/assault
	assignment = "Nanotrasen Assault Force"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)

/datum/id_trim/engioutpost
	assignment = "Senior Station Engineer"
	trim_state = "trim_stationengineer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)

/datum/id_trim/job/station_engineer/gunner
	assignment = "Gunner"
	template_access = null

/datum/id_trim/pirate/silverscale
	assignment = "Silver Scale Member"
	trim_state = "trim_unknown"

/datum/id_trim/pirate/silverscale/captain
	assignment = "Silver Scale VIP"
	trim_state = "trim_captain"
