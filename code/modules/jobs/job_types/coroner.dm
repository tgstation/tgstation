/datum/job/coroner
	title = JOB_CORONER
	description = "Perform Autopsies whenever needed, \
		Update medical records accordingly, apply formaldehyde."
	department_head = list(JOB_CHIEF_MEDICAL_OFFICER)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Head of Personnel and the Chief Medical Officer"
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "CORONER"

	outfit = /datum/outfit/job/coroner
	plasmaman_outfit = /datum/outfit/plasmaman/coroner

	mind_traits = list(TRAIT_MORBID)
	liver_traits = list(TRAIT_CORONER_METABOLISM)

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_CORONER
	bounty_types = CIV_JOB_MED
	department_for_prefs = /datum/job_department/medical
	departments_list = list(
		/datum/job_department/medical,
		/datum/job_department/service,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 30,
		/obj/item/storage/box/bodybags = 15,
		/obj/item/healthanalyzer = 10,
		/obj/item/shovel/serrated/dull = 5,
		/obj/effect/spawner/random/medical/organs = 5,
		/obj/item/reagent_containers/cup/beaker/organ_jar/brain_in_a_jar = 5,
		/obj/effect/spawner/random/medical/memeorgans = 1,
		/obj/item/scythe = 1,
	)

	family_heirlooms = list(/obj/item/clothing/head/helmet/skull, /obj/item/table_clock, /obj/item/shovel, /obj/item/storage/fancy/pickles_jar)

	job_flags = STATION_JOB_FLAGS

	rpg_title = "Undertaker"

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner
	id_trim = /datum/id_trim/job/coroner

	box = /obj/item/storage/box/survival/medical
	backpack_contents = list(
		/obj/item/storage/box/bodybags = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/storage/medkit/coroner = 1,
	)

	belt = /obj/item/modular_computer/pda/coroner
	ears = /obj/item/radio/headset/headset_srvmed
	gloves = /obj/item/clothing/gloves/latex/coroner
	head = /obj/item/clothing/head/utility/surgerycap/black
	l_pocket = /obj/item/clipboard //good for storing autopsy reports and taking notes
	r_pocket = /obj/item/reagent_containers/dropper
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/toggle/labcoat/coroner
	uniform = /obj/item/clothing/under/rank/medical/scrubs/coroner

	backpack = /obj/item/storage/backpack/coroner
	satchel = /obj/item/storage/backpack/satchel/coroner
	duffelbag = /obj/item/storage/backpack/duffelbag/coroner
	messenger = /obj/item/storage/backpack/messenger/coroner

	skillchips = list(/obj/item/skillchip/entrails_reader)
