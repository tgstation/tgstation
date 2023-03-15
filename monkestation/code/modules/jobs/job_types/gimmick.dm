/datum/job/gimmick/mailman
	title = "Mailman"
	flag = MAILMAN
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	outfit = /datum/outfit/job/gimmick/mailman
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO)
	total_positions = 1
	supervisors = "the quartermaster and the head of personnel"
	paycheck = PAYCHECK_EASY
	gimmick = TRUE
	chat_color = "#8ebee6"
	departments = DEPARTMENT_CARGO
	rpg_title = "Courier"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/mailman
	)

/datum/outfit/job/gimmick/mailman
	name = "Mailman"
	jobtype = /datum/job/gimmick/mailman

	belt = /obj/item/storage/bag/mail
	ears = /obj/item/radio/headset/headset_cargo
	head = /obj/item/clothing/head/mailman
	uniform = /obj/item/clothing/under/misc/mailman
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/pda/unlicensed
	l_pocket = /obj/item/pinpointer/crew //for tracking down those mail recipients!
	can_be_admin_equipped = TRUE

/datum/outfit/plasmaman/mailman
	name = "Mailman Plasmaman"

	belt = /obj/item/storage/bag/mail
	ears = /obj/item/radio/headset/headset_cargo
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/helmet/space/plasmaman/mailman
	uniform = /obj/item/clothing/under/plasmaman/mailman
	r_pocket = /obj/item/pda/unlicensed
	l_pocket = /obj/item/pinpointer/crew

	helmet_variants = list(HELMET_MK2 = /obj/item/clothing/head/helmet/space/plasmaman/mailman/mark2,
							HELMET_PROTECTIVE = /obj/item/clothing/head/helmet/space/plasmaman/mailman/protective)
