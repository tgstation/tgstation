/datum/job/brig_physician
	title = JOB_BRIG_PHYSICIAN
	description = "Stitch up security, prisoners, sometimes the crew."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOS
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BRIG_PHYSICIAN"

	outfit = /datum/outfit/job/brig_physician
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYSICIAN
	bounty_types = CIV_JOB_MED
	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/scalpel, /obj/item/hemostat, /obj/item/circular_saw, /obj/item/retractor, /obj/item/cautery)

	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/advanced = 6,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 6,
		/obj/effect/spawner/random/medical/organs = 5,
		/obj/effect/spawner/random/medical/memeorgans = 1
	)
	rpg_title = "Chirurgeon"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/brig_physician
	name = "Brig Physician"
	jobtype = /datum/job/brig_physician

	id_trim = /datum/id_trim/job/brig_physician
	uniform = /obj/item/clothing/under/rank/security/scrubs/sec
	suit = /obj/item/clothing/suit/toggle/labcoat/brig_physician
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_secmed
	head = /obj/item/clothing/head/utility/surgerycap/sec
	shoes = /obj/item/clothing/shoes/sneakers/secred
	l_hand = /obj/item/storage/medkit/surgery

	backpack = /obj/item/storage/backpack/brig_physician
	satchel = /obj/item/storage/backpack/satchel/brig_physician
	duffelbag = /obj/item/storage/backpack/duffelbag/brig_physician

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
	skillchips = list(/obj/item/skillchip/entrails_reader)
	implants = list(/obj/item/implant/mindshield)

/datum/outfit/plasmaman/brig_physician
	name = "Brig Physician Plasmaman"

	uniform = /obj/item/clothing/under/plasmaman/brig_physician
	gloves = /obj/item/clothing/gloves/color/plasmaman/brig_physician
	head = /obj/item/clothing/head/helmet/space/plasmaman/brig_physician

