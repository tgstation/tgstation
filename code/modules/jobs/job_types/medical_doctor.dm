/datum/job/doctor
	title = JOB_MEDICAL_DOCTOR
	description = "Save lives, run around the station looking for victims, \
		scan everyone in sight, brew medicine, perform autopsies."
	faction = FACTION_STATION
	// Lowpop: absorbs Paramedic, Chemist and Coroner.
	total_positions = 11
	spawn_positions = 9
	supervisors = SUPERVISOR_CMO
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "MEDICAL_DOCTOR"

	outfit = /datum/outfit/job/doctor
	plasmaman_outfit = /datum/outfit/plasmaman/medical

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	desensitized_base = DESENSITIZED_THRESHOLD
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	bounty_types = CIV_JOB_MED_VIRO
	departments_list = list(
		/datum/job_department/medical,
		)

	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/scalpel, /obj/item/hemostat, /obj/item/circular_saw, /obj/item/retractor, /obj/item/cautery, /obj/item/statuebust/hippocratic)

	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 15,
		/obj/item/scalpel/advanced = 6,
		/obj/item/retractor/advanced = 6,
		/obj/item/cautery/advanced = 6,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 6,
		/obj/effect/spawner/random/medical/organs = 5,
		/obj/effect/spawner/random/medical/memeorgans = 1
	)
	rpg_title = "Cleric"
	job_flags = STATION_JOB_FLAGS
	tgui_icon = FA_ICON_STAFF_SNAKE


/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor

	id_trim = /datum/id_trim/job/medical_doctor
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/toggle/labcoat
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/storage/belt/medical/paramedic // Lowpop: gear from Paramedic, Chemist and Coroner.
	ears = /obj/item/radio/headset/headset_med
	gloves = /obj/item/clothing/gloves/latex/nitrile
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/modular_computer/pda/crew/medical
	r_pocket = /obj/item/storage/box/bandages
	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/emergency_bed = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/reagent_containers/dropper = 1,
		/obj/item/clothing/glasses/science = 1,
	)
	pda_slot = ITEM_SLOT_LPOCKET

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	messenger = /obj/item/storage/backpack/messenger/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
	skillchips = list(/obj/item/skillchip/entrails_reader)

	wintercoat = /obj/item/clothing/suit/hooded/wintercoat/medical
