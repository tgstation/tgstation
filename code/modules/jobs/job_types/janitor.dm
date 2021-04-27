/datum/job/janitor
	title = "Janitor"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/janitor
	plasmaman_outfit = /datum/outfit/plasmaman/janitor

	display_order = JOB_DISPLAY_ORDER_JANITOR
	departments = DEPARTMENT_SERVICE
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	family_heirlooms = list(
		/obj/item/clothing/suit/caution,
		/obj/item/mop,
		/obj/item/paper/fluff/stations/soap,
		/obj/item/reagent_containers/glass/bucket,
		)

	mail_goodies = list(
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10
	)

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	id_trim = /datum/id_trim/job/janitor
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/advanced = 1,
		)
	belt = /obj/item/pda/janitor
	ears = /obj/item/radio/headset/headset_srv

/datum/outfit/job/janitor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(GARBAGEDAY in SSevents.holidays)
		backpack_contents += /obj/item/gun/ballistic/revolver
		r_pocket = /obj/item/ammo_box/a357
