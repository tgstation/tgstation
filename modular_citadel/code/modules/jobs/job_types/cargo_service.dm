/datum/job/bartender
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_BAR, ACCESS_MINERAL_STOREROOM)

/datum/job/qm
	department_head = list("Captain")
	supervisors = "the captain"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 180
	exp_type_department = EXP_TYPE_SUPPLY

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_KEYCARD_AUTH, ACCESS_RC_ANNOUNCE, ACCESS_SEC_DOORS, ACCESS_HEADS)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_KEYCARD_AUTH, ACCESS_RC_ANNOUNCE, ACCESS_SEC_DOORS, ACCESS_HEADS)

/datum/outfit/job/quartermaster
	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/heads/qm
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1, /obj/item/modular_computer/tablet/preset/advanced = 1)

/datum/job/cargo_tech
	department_head = list("Quartermaster")
	supervisors = "the quartermaster"

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/datum/job/mining
	department_head = list("Quartermaster")
	supervisors = "the quartermaster"

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)