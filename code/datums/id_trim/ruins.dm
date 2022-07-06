/// Generic away/pffstation trim.
/datum/id_trim/away
	access = list(ACCESS_AWAY_GENERAL)

/// Trim for the hotel ruin. Not Hilbert's Hotel.
/datum/id_trim/away/hotel
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINTENANCE)

/// Trim for the hotel ruin. Not Hilbert's Hotel.
/datum/id_trim/away/hotel/security
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINTENANCE, ACCESS_AWAY_SEC)

/// Trim for the oldstation ruin/Charlie station
/datum/id_trim/away/old/sec
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)
	assignment = "Charlie Station Security Officer"

/// Trim for the oldstation ruin/Charlie station
/datum/id_trim/away/old/sci
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SCIENCE)
	assignment = "Charlie Station Scientist"

/// Trim for the oldstation ruin/Charlie station
/datum/id_trim/away/old/eng
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINEERING)
	assignment = "Charlie Station Engineer"

/// Trim for the oldstation ruin/Charlie station to access APCs and other equipment
/datum/id_trim/away/old/apc
	access = list(ACCESS_ENGINEERING, ACCESS_ENGINE_EQUIP)
	assignment = "Engineering Equipment Access"

/// Trim for the oldstation ruin/Charlie station to access robots, and downloading of paper publishing software for experiments
/datum/id_trim/away/old/robo
	access = list(ACCESS_AWAY_GENERAL, ACCESS_ROBOTICS, ACCESS_ORDNANCE)

/// Trim for the cat surgeon ruin.
/datum/id_trim/away/cat_surgeon
	assignment = "Cat Surgeon"
	trim_state = "trim_medicaldoctor"
	department_color = "#5B97BC"
	subdepartment_color = "#58C800"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINTENANCE)

/// Trim for Hilbert in Hilbert's Hotel.
/datum/id_trim/away/hilbert
	assignment = "Head Researcher"
	department_color = "#1B67A5"
	subdepartment_color = "#C96DBF"
	trim_state = "trim_scientist"
	department_state = "departmenthead"
	access = list(ACCESS_AWAY_GENERIC3, ACCESS_RESEARCH)

/// Trim for beach bum lifeguards.
/datum/id_trim/lifeguard
	assignment = "Lifeguard"

/// Trim for beach bum bartenders.
/datum/id_trim/space_bartender
	assignment = "Space Bartender"
	trim_state = "trim_bartender"
	department_color = "#58C800"
	subdepartment_color = "#C96DBF"
	access = list(ACCESS_BAR)

/// Trim for various Centcom corpses.
/datum/id_trim/centcom/corpse/bridge_officer
	assignment = "Bridge Officer"
	access = list(ACCESS_CENT_CAPTAIN)

/// Trim for various Centcom corpses.
/datum/id_trim/centcom/corpse/commander
	assignment = "Commander"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE)

/// Trim for various Centcom corpses.
/datum/id_trim/centcom/corpse/private_security
	assignment = JOB_CENTCOM_PRIVATE_SECURITY
	department_color = "#CB0000"
	subdepartment_color = "#CB0000"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)

/// Trim for various Centcom corpses.
/datum/id_trim/centcom/corpse/private_security/tradepost_officer
	assignment = "Tradepost Officer"
	subdepartment_color = "#B18644"

/// Trim for various Centcom corpses.
/datum/id_trim/centcom/corpse/assault
	assignment = "Nanotrasen Assault Force"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)

/// Trim for various various ruins.
/datum/id_trim/engioutpost
	assignment = "Senior Station Engineer"
	trim_state = "trim_stationengineer"
	department_color = "#FFA62B"
	subdepartment_color = "#FFA62B"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINEERING, ACCESS_ENGINEERING, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)

/// Trim for various various ruins.
/datum/id_trim/job/station_engineer/gunner
	assignment = "Gunner"
	template_access = null

/// Trim for pirates.
/datum/id_trim/pirate
	assignment = "Pirate"
	trim_state = "trim_unknown"
	department_color = "#F10303"
	subdepartment_color = "#F10303"
	access = list(ACCESS_SYNDICATE)

/// Trim for pirates.
/datum/id_trim/pirate/silverscale
	assignment = "Silver Scale Member"

/// Trim for the pirate captain.
/datum/id_trim/pirate/captain
	assignment = "Pirate Captain"
	trim_state = "trim_captain"

/// Trim for the pirate captain.
/datum/id_trim/pirate/captain/silverscale
	assignment = "Silver Scale VIP"
