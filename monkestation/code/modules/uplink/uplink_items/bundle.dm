/datum/uplink_item/bundles_tc/contract_kit
	name = "Contractor Bundle"
	desc = "A box containing everything you need to take contracts from the Syndicate. Kidnap people and drop them off at specified locations for rewards in the form of Telecrystals \
			(Usable in the provided uplink) and Contractor Points. Can not be bought if you have taken any secondary objectives."
	item = /obj/item/storage/box/syndie_kit/contract_kit
	cost = 20
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/bundles_tc/contract_kit/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	if(length(handler.completed_objectives) || length(handler.active_objectives) || !handler.can_take_objectives || !handler.has_objectives)
		return FALSE
	return TRUE

/datum/uplink_item/bundles_tc/contract_kit/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	. = ..()
	var/datum/component/uplink/our_uplink = source.GetComponent(/datum/component/uplink)
	if(uplink_handler && our_uplink)
		our_uplink.become_contractor()
