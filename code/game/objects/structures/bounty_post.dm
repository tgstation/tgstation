GLOBAL_LIST_EMPTY(holy_contracts)

/datum/holy_bounty
	///name of the bounty
	var/bounty_name = "bounty"
	///details of the contract
	var/bounty_description = "some bounty"
	///associated icon
	var/bounty_icon

/datum/holy_bounty/New()
	. = ..()
	GLOB.holy_contracts += src

/datum/holy_bounty/Destroy()
	. = ..()
	GLOB.holy_contracts -= src

/datum/holy_bounty/eliminate_monster

/datum/holy_bounty/seal_portal
