/// Support unit gets it's own very basic antag datum for admin logging.
/datum/antagonist/traitor/contractor_support
	name = "Contractor Support Unit"
	job_rank = ROLE_CONTRACTOR_SUPPORT
	employer = "Contractor Support Unit"
	show_in_roundend = FALSE
	give_objectives = TRUE
	give_uplink = FALSE

/datum/antagonist/traitor/contractor_support/forge_traitor_objectives()
	var/datum/objective/generic_objective = new
	generic_objective.name = "Follow Contractor's Orders"
	generic_objective.explanation_text = "Follow your orders. Assist agents in this mission area."
	generic_objective.completed = TRUE
	objectives += generic_objective

/datum/antagonist/traitor/contractor_support/forge_ending_objective()
	return

/datum/outfit/contractor_partner
	name = "Contractor Support Unit"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	back = /obj/item/storage/backpack
	belt = /obj/item/modular_computer/pda/chameleon
	mask = /obj/item/cigarette/syndicate
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	ears = /obj/item/radio/headset/chameleon
	id = /obj/item/card/id/advanced/chameleon
	r_hand = /obj/item/storage/toolbox/syndicate
	id_trim = /datum/id_trim/chameleon/operative

	backpack_contents = list(
		/obj/item/storage/box/survival,
		/obj/item/implanter/uplink,
		/obj/item/clothing/mask/chameleon,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/lighter,
	)

/datum/outfit/contractor_partner/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/obj/item/cigarette/syndicate/cig = H.get_item_by_slot(ITEM_SLOT_MASK)
	cig.light()
