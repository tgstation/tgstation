/datum/antagonist/traitor/contractor_support
	name = "Contractor Support Unit"
	antag_moodlet = /datum/mood_event/focused

	show_in_roundend = FALSE // We're already adding them in to the contractor's roundend.
	give_uplink = FALSE
	give_objectives = TRUE // We give them their own custom objective.
	give_secondary_objectives = FALSE
	/// Team datum that contains the contractor and the support unit
	var/datum/team/contractor_team/contractor_team

/// Team for storing both the contractor and their support unit - only really for the HUD and admin logging.
/datum/team/contractor_team
	show_roundend_report = FALSE

/datum/antagonist/traitor/contractor_support/forge_traitor_objectives()
	var/datum/objective/generic_objective = new

	generic_objective.name = "Follow the Contractor's Orders"
	generic_objective.explanation_text = "Follow your orders. Assist agents in this mission area."

	generic_objective.completed = TRUE

	objectives += generic_objective

/datum/outfit/contractor_partner
	name = "Contractor Support Unit"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	back = /obj/item/storage/backpack
	belt = /obj/item/modular_computer/pda/chameleon
	mask = /obj/item/clothing/mask/cigarette/syndicate
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	ears = /obj/item/radio/headset/chameleon
	id = /obj/item/card/id/advanced/chameleon
	r_hand = /obj/item/storage/toolbox/syndicate
	id_trim = /datum/id_trim/chameleon/operative

	backpack_contents = list(
	/obj/item/storage/box/survival,
	/obj/item/clothing/mask/chameleon,
	/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
	/obj/item/lighter
	)

	implants = list(
		/obj/item/implant/uplink/precharged, //may need to make this not be precharged, we will see
	)

/datum/outfit/contractor_partner/post_equip(mob/living/carbon/human/partner, visualsOnly)
	. = ..()
	var/obj/item/clothing/mask/cigarette/syndicate/cig = partner.get_item_by_slot(ITEM_SLOT_MASK)

	// pre-light their cig
	cig.light()
