//Whitelisted or admin only jobs.

/*
AI
*/
/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = SPECIALJOBS
	faction = "Federation"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "the crew"
	req_admin_notify = 1
	minimal_player_age = 30

/datum/job/ai/equip(mob/living/carbon/human/H)
	if(!H)
		return 0

/datum/job/ai/config_check()
	if(config && config.allow_ai)
		return 1
	return 0


/datum/job/moraleofficer
	title = "Morale Officer"
	flag = MORALEOFFICER
	department_flag = SPECIALJOBS
	faction = "Starfleet Command"
	total_positions = 0
	spawn_positions = 0
	supervisors = "Starfleet Command"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/moraleofficer

/datum/outfit/job/moraleofficer
	name = "Morale Officer"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown


/datum/job/intelofficer
	title = "Intelligence Officer"
	flag = INTELOFFICER
	department_flag = SPECIALJOBS
	faction = "Starfleet Command"
	total_positions = 0
	spawn_positions = 0
	supervisors = "Starfleet Command"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/moraleofficer

/datum/outfit/job/intelofficer
	name = "Intelligence Officer"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown


/datum/job/diplomat
	title = "Diplomat"
	flag = DIPLOMAT
	department_flag = SPECIALJOBS
	faction = "Starfleet Command"
	total_positions = 0
	spawn_positions = 0
	supervisors = "Starfleet Command"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/diplomat

/datum/outfit/job/diplomat
	name = "Diplomat"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown

/datum/job/jag
	title = "Judge Advocate General"
	flag = JAG
	department_flag = SPECIALJOBS
	faction = "Starfleet Command"
	total_positions = 0
	spawn_positions = 0
	supervisors = "Starfleet Command"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/jag

/datum/outfit/job/jag
	name = "Judge Advocate General"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown

/datum/job/guest
	title = "Honored Guest"
	flag = GUEST
	department_flag = SPECIALJOBS
	faction = "Starfleet Command"
	total_positions = 0
	spawn_positions = 0
	supervisors = "Starfleet Command"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/guest

/datum/outfit/job/guest
	name = "Honored Guest"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown

/datum/job/trader
	title = "Trader"
	flag = TRADER
	department_flag = SPECIALJOBS
	faction = "Starfleet Command"
	total_positions = 0
	spawn_positions = 0
	supervisors = "Starfleet Command"
	selection_color = "#dddddd"
	access = list()
	minimal_access = list()
	outfit = /datum/outfit/job/trader

/datum/outfit/job/trader
	name = "Trader"

	id = /obj/item/weapon/card/id/silver
	belt = /obj/item/device/pda/heads/hop
	ears = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown
