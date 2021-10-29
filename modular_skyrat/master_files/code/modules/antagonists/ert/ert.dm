/datum/antagonist/ert/asset_protection
	name = "Asset Protection Specialist"
	outfit = /datum/outfit/centcom/asset_protection
	role = "Specialist"
	rip_and_tear = TRUE

/datum/antagonist/ert/asset_protection/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/asset_protection/leader
	name = "Asset Protection Officer"
	outfit = /datum/outfit/centcom/asset_protection
	role = "Officer"
