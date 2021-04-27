/datum/job/virologist
	title = "Virologist"
	department_head = list("Chief Medical Officer")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	exp_type = EXP_TYPE_CREW
	exp_requirements = 60

	outfit = /datum/outfit/job/virologist
	plasmaman_outfit = /datum/outfit/plasmaman/viro

	bounty_types = CIV_JOB_VIRO
	departments = DEPARTMENT_MEDICAL
	display_order = JOB_DISPLAY_ORDER_VIROLOGIST
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	family_heirlooms = list(
		/obj/item/reagent_containers/syringe,
		)
	liver_traits = list(
		TRAIT_MEDICAL_METABOLISM,
		)

	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/random_virus = 15,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 10,
		/obj/item/reagent_containers/glass/bottle/synaptizine = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/uranium = 5
	)


/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist

	id_trim = /datum/id_trim/job/virologist
	uniform = /obj/item/clothing/under/rank/medical/virologist
	suit =  /obj/item/clothing/suit/toggle/labcoat/virologist
	suit_store =  /obj/item/flashlight/pen
	belt = /obj/item/pda/viro
	ears = /obj/item/radio/headset/headset_med
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel/vir
	duffelbag = /obj/item/storage/backpack/duffelbag/virology

	box = /obj/item/storage/box/survival/medical
