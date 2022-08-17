/datum/map_template/shuttle/voidcrew/geneva
	name = "Geneva-class Search and Rescue Vessel"
	suffix = "syndicate_geneva"
	short_name = "Geneva-class"

	job_slots = list(
		list(
			name = "Chief Medical Officer",
			officer = TRUE,
			outfit = /datum/outfit/job/cmo/syndicate,
			slots = 1,
		),
		list(
			name = "Medical Doctor",
			outfit = /datum/outfit/job/doctor/syndicate,
			slots = 2,
		),
		list(
			name = "Botanist",
			outfit = /datum/outfit/job/botanist/syndicate,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer/gec,
			slots = 2,
		),
		list(
			name = "Rescue Specialist",
			outfit = /datum/outfit/job/miner/syndicate,
			slots = 2,
		),
		list(
			name = "Paramedic"
			outfit = /datum/outfit/job/paramedic/syndicate/gorlex,
			slots = 1,
		),
	)

/datum/outfit/job/cmo/syndicate
	name = "Chief Medical Officer (Syndicate)"

	uniform = /obj/item/clothing/under/syndicate
	ears = /obj/item/radio/headset/syndicate/alt/leader
	id = /obj/item/card/id/advanced/black/syndicate_command/captain_id
	shoes = /obj/item/clothing/shoes/jackboots

/datum/outfit/job/doctor/syndicate
	name = "Medical Doctor (Syndicate)"

	uniform = /obj/item/clothing/under/syndicate
	id = /obj/item/card/id/advanced/black/syndicate_command
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/syndicate/alt

/datum/outfit/job/botanist/syndicate
	name = "Botanist (Syndicate)"

	uniform = /obj/item/clothing/under/syndicate
	id = /obj/item/card/id/advanced/black/syndicate_command
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/science
	suit = /obj/item/clothing/suit/toggle/labcoat/chemist

/datum/outfit/job/engineer/gec
	name = "Station Engineer (Syndicate)"

	uniform = /obj/item/clothing/under/syndicate/intern
	suit = /obj/item/clothing/suit/toggle/hazard
	head = /obj/item/clothing/head/hardhat
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/advanced/black/syndicate_command

/datum/outfit/job/miner/syndicate
	name = "Shaft Miner (Syndicate)"

	id = /obj/item/card/id/advanced/black/syndicate_command
	ears = /obj/item/radio/headset/syndicate/alt
	uniform = /obj/item/clothing/under/syndicate/gorlex
	accessory = /obj/item/clothing/accessory/armband/cargo
	head = /obj/item/clothing/head/hardhat/orange

/datum/outfit/job/paramedic/syndicate/gorlex
	name = "Paramedic (Syndicate)"

	id = /obj/item/card/id/advanced/black/syndicate_command
	ears = /obj/item/radio/headset/syndicate/alt
	uniform = /obj/item/clothing/under/syndicate/gorlex
	alt_uniform = null
	shoes = /obj/item/clothing/shoes/jackboots
