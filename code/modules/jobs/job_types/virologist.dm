/datum/job/virologist
	title = JOB_VIROLOGIST
	description = "Study the effects of various diseases and synthesize a \
		vaccine for them. Engineer beneficial viruses."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CMO
	exp_requirements = 60
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "VIROLOGIST"

	outfit = /datum/outfit/job/virologist
	plasmaman_outfit = /datum/outfit/plasmaman/viro

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_VIROLOGIST
	bounty_types = CIV_JOB_VIRO
	departments_list = list(
		/datum/job_department/medical,
		)

	family_heirlooms = list(/obj/item/reagent_containers/syringe)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/bottle/random_virus = 15,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 10,
		/obj/item/reagent_containers/cup/bottle/synaptizine = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/uranium = 5,
	)
	rpg_title = "Plague Doctor"
	job_flags = STATION_JOB_FLAGS


/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist

	id_trim = /datum/id_trim/job/virologist
	uniform = /obj/item/clothing/under/rank/medical/virologist
	suit = /obj/item/clothing/suit/toggle/labcoat/virologist
	suit_store = /obj/item/flashlight/pen
	belt = /obj/item/modular_computer/pda/viro
	ears = /obj/item/radio/headset/headset_med
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel/vir
	duffelbag = /obj/item/storage/backpack/duffelbag/virology
	messenger = /obj/item/storage/backpack/messenger/vir

	box = /obj/item/storage/box/survival/medical
