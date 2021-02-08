/datum/id_trim/syndicom
	assignment = "Syndicate Overlord"
	trim_state = "trim_syndicate"
	access = list(ACCESS_SYNDICATE)

/datum/id_trim/syndicom/crew
	assignment = "Syndicate Operative"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)

/datum/id_trim/syndicom/captain
	assignment = "Syndicate Ship Captain"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)

/datum/id_trim/battlecruiser
	assignment = "Syndicate Battlecruiser Crew"
	trim_state = "trim_syndicate"
	access = list(ACCESS_SYNDICATE)

/datum/id_trim/battlecruiser/captain
	assignment = "Syndicate Battlecruiser Captain"
	access = SYNDICATE_ACCESS

/datum/id_trim/chameleon
	assignment = "Unknown"
	access = list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)

/datum/id_trim/chameleon/operative
	assignment = "Syndicate Operative"
	trim_state = "trim_syndicate"

/datum/id_trim/chameleon/operative/clown
	assignment = "Syndicate Entertainment Operative"

/datum/id_trim/chameleon/operative/clown_leader
	assignment = "Syndicate Entertainment Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/datum/id_trim/chameleon/operative/nuke_leader
	assignment = "Syndicate Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
