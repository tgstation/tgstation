/datum/job/migrant
	title = JOB_MIGRANT
	description = "Try to survive the barren wasteland and reach the station alive."
	faction = FACTION_STATION
	total_positions = 5 // tbh should be infinite positions
	spawn_positions = 5
	selection_color = "#ffe1c3" // change this later
	config_tag = "MIGRANT"
	outfit = /datum/outfit/job/migrant // need to make this behave like assistant outfits?
	plasmaman_outfit = /datum/outfit/plasmaman/migrant // need to make this
	display_order = JOB_DISPLAY_ORDER_MIGRANT
	random_spawns_possible = FALSE
	rpg_title = "Wasteland Monster"
	job_flags = JOB_NEW_PLAYER_JOINABLE|JOB_ASSIGN_QUIRKS|JOB_EQUIP_RANK 

/datum/outfit/job/migrant
	name = "Migrant"
	jobtype = /datum/job/migrant
	id = /obj/item/card/id/advanced/migrant
	id_trim = /datum/id_trim/job/migrant
	uniform = /obj/item/clothing/under/misc/durathread
	belt = null
	ears = null
	shoes = /obj/item/clothing/shoes/workboots
	// need a way to check if we spawn on ice, then to change the uniform so migrants don't die lol
