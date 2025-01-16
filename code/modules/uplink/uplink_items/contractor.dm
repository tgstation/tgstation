/datum/uplink_category/contractor
	name = "Contractor"
	weight = 10

/datum/uplink_item/bundles_tc/contract_kit
	name = "Contract Kit"
	desc = "The Syndicate have offered you the chance to become a contractor, take on kidnapping contracts for TC \
		and cash payouts. Upon purchase, you'll be granted your own contract uplink embedded within the supplied \
		tablet computer. Additionally, you'll be granted standard contractor gear to help with your mission - \
		comes supplied with the tablet, specialised space suit, chameleon jumpsuit and mask, agent card, \
		specialised contractor baton, and three randomly selected low cost items. \
		Can include otherwise unobtainable items."
	item = /obj/item/storage/box/syndicate/contract_kit
	category = /datum/uplink_category/contractor
	cost = 20
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/bundles_tc/contract_kit/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	. = ..()
	for(var/uplink_items in subtypesof(/datum/uplink_item/contractor))
		var/datum/uplink_item/uplink_item = new uplink_items
		uplink_handler.extra_purchasable += uplink_item

/datum/uplink_item/contractor
	restricted = TRUE
	category = /datum/uplink_category/contractor
	purchasable_from = NONE //they will be added to extra_purchasable

//prevents buying contractor stuff before you make an account.
/datum/uplink_item/contractor/can_be_bought(datum/uplink_handler/uplink_handler)
	if(!uplink_handler.contractor_hub)
		return FALSE
	return ..()

/datum/uplink_item/contractor/reroll
	name = "Contract Reroll"
	desc = "Request a reroll of your current contract list. Will generate a new target, \
		payment, and dropoff for the contracts you currently have available."
	item = ABSTRACT_UPLINK_ITEM
	limited_stock = 2
	cost = 0

/datum/uplink_item/contractor/reroll/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	//We're not regenerating already completed/aborted/extracting contracts, but we don't want to repeat their targets.
	var/list/new_target_list = list()
	for(var/datum/syndicate_contract/contract_check in uplink_handler.contractor_hub.assigned_contracts)
		if (contract_check.status != CONTRACT_STATUS_ACTIVE && contract_check.status != CONTRACT_STATUS_INACTIVE)
			if (contract_check.contract.target)
				new_target_list.Add(contract_check.contract.target)
			continue

	//Reroll contracts without duplicates
	for(var/datum/syndicate_contract/rerolling_contract in uplink_handler.contractor_hub.assigned_contracts)
		if (rerolling_contract.status != CONTRACT_STATUS_ACTIVE && rerolling_contract.status != CONTRACT_STATUS_INACTIVE)
			continue

		rerolling_contract.generate(new_target_list)
		new_target_list.Add(rerolling_contract.contract.target)

	//Set our target list with the new set we've generated.
	uplink_handler.contractor_hub.assigned_targets = new_target_list
	return source //for log icon

/datum/uplink_item/contractor/pinpointer
	name = "Contractor Pinpointer"
	desc = "A pinpointer that finds targets even without active suit sensors. \
		Due to taking advantage of an exploit within the system, it can't pinpoint \
		to the same accuracy as the traditional models. \
		Becomes permanently locked to the user that first activates it."
	item = /obj/item/pinpointer/crew/contractor
	limited_stock = 2
	cost = 1

/datum/uplink_item/contractor/extraction_kit
	name = "Fulton Extraction Kit"
	desc = "For getting your target across the station to those difficult dropoffs. \
		Place the beacon somewhere secure, and link the pack. \
		Activating the pack on your target will send them over to the beacon - \
		make sure they're not just going to run away though!"
	item = /obj/item/storage/box/contractor/fulton_extraction
	limited_stock = 1
	cost = 1

/datum/uplink_item/contractor/partner
	name = "Contractor Reinforcement"
	desc = "A reinforcement operative will be sent to aid you in your goals, \
		they are paid separately, and will not take a cut from your profits."
	item = /obj/item/antag_spawner/loadout/contractor
	limited_stock = 1
	cost = 2
