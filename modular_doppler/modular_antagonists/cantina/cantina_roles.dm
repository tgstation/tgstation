//datums

/datum/job/cantina_regular
	title = "Undisclosed Location regular"

/datum/job/cantina_bartender
	title = "Undisclosed Location bartender"

/datum/antagonist/traitor/cantina_regular
	name = "\improper Cantina Regular"
	count_against_dynamic_roll_chance = FALSE
	show_in_roundend = FALSE
	default_custom_objective = "Thwart the encroachment on your turf... by any means necessary!"

/datum/antagonist/traitor/cantina_bartender
	name = "\improper Cantina Bartender"
	count_against_dynamic_roll_chance = FALSE
	show_in_roundend = FALSE
	default_custom_objective = "Serve refreshing drinks... by any means necessary!"

//childed to /datum/outfit/syndicate for uplink granting

/datum/outfit/syndicate/cantina_regular
	uplink_type = /obj/item/uplink/
	l_pocket = null

/datum/outfit/syndicate/cantina_bartender
	uplink_type = null
	l_pocket = null
