///Spawns a contractor partner to a spawning user, with a given key to assign to the new player.
/proc/spawn_contractor_partner(mob/living/user, key)
	var/mob/living/carbon/human/partner = new()
	var/datum/outfit/contractor_partner/partner_outfit = new()

	partner_outfit.equip(partner)

	var/obj/structure/closet/supplypod/arrival_pod = new(null, STYLE_SYNDICATE)
	arrival_pod.explosionSize = list(0,0,0,1)
	arrival_pod.bluespace = TRUE

	var/turf/free_location = find_obstruction_free_location(2, user)

	// We really want to send them - if we can't find a nice location just land it on top of them.
	if (!free_location)
		free_location = get_turf(user)

	partner.forceMove(arrival_pod)
	partner.ckey = key

	/// We give a reference to the mind that'll be the support unit
	var/datum/antagonist/traitor/contractor_support/new_datum = partner.mind.add_antag_datum(/datum/antagonist/traitor/contractor_support)

	to_chat(partner, "\n[span_alertwarning("[user.real_name] is your superior. Follow any, and all orders given by them. You're here to support their mission only.")]")
	to_chat(partner, "[span_alertwarning("Should they perish, or be otherwise unavailable, you're to assist other active agents in this mission area to the best of your ability.")]")

	new /obj/effect/pod_landingzone(free_location, arrival_pod)
	return new_datum

/// Support unit gets it's own very basic antag datum for admin logging.
/datum/antagonist/traitor/contractor_support
	name = "Contractor Support Unit"
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
	mask = /obj/item/clothing/mask/cigarette/syndicate
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
	var/obj/item/clothing/mask/cigarette/syndicate/cig = H.get_item_by_slot(ITEM_SLOT_MASK)
	cig.light()
