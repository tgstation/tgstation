/datum/map_template/shuttle/voidcrew/cultist
	name = "Express-Class Eldritch Hijacked Freighter"
	suffix = "express_cultist"
	short_name = "Cultist-class"
	antag_datum = /datum/antagonist/cult

	job_slots = list(
		list(
			name = "Cultist Leader",
			officer = TRUE,
			outfit = /datum/outfit/job/captain/western,
			slots = 1,
		),
		list(
			name = "Converted Foreman",
			outfit = /datum/outfit/job/quartermaster/western,
			slots = 1,
		),
		list(
			name = "Converted Engineer",
			outfit = /datum/outfit/job/engineer/hazard,
			slots = 1,
		),
		list(
			name = "Converted Miner",
			outfit = /datum/outfit/job/miner/hazard,
			slots = 2,
		),
		list(
			name = "Cultist",
			outfit = /datum/outfit/job/assistant,
			slots = 3,
		)
	)

/datum/outfit/job/captain/western
	name = "Captain (Western)"
	uniform = /obj/item/clothing/under/suit/white
	shoes = /obj/item/clothing/shoes/cowboy/white
	head = /obj/item/clothing/head/caphat/cowboy
	glasses = /obj/item/clothing/glasses/sunglasses

/datum/outfit/job/quartermaster/western
	name = "Quartermaster (Western)"

	suit = /obj/item/clothing/suit/toggle/hazard
	head = /obj/item/clothing/head/cowboy/sec

/datum/outfit/job/engineer/hazard
	name = "Ship's Engineer (Hazard)"

	uniform = /obj/item/clothing/under/rank/engineering/engineer/hazard
	head = /obj/item/clothing/head/hardhat
	suit = /obj/item/clothing/suit/toggle/hazard

/datum/outfit/job/miner/hazard
	name = "Asteroid Miner (Hazard)"

	uniform = /obj/item/clothing/under/rank/cargo/miner/hazar

