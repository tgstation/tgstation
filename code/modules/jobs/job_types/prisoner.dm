/datum/job/prisoner
	title = "Prisoner"
	department_head = list("The Security Team")
	faction = "Station"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the security team"
	selection_color = "#ffe1c3"
	paycheck = PAYCHECK_PRISONER

	outfit = /datum/outfit/job/prisoner
	plasmaman_outfit = /datum/outfit/plasmaman/prisoner

	display_order = JOB_DISPLAY_ORDER_PRISONER

	family_heirlooms = list(
		/obj/item/pen/blue,
	)

	exclusive_mail_goodies = TRUE
	mail_goodies = list (
		/obj/effect/spawner/lootdrop/prison_contraband = 1,
	)

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/advanced/prisoner
	id_trim = /datum/id_trim/job/prisoner
	uniform = /obj/item/clothing/under/color/prisoner
	belt = null
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/orange
