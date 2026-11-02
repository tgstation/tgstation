/**
 * The steward's export machine (Ratwood roguemachine/steward_export/steward_export.dm and the standing orders tab of the
 * nerve master): the ledger of the standing orders the regions of the realm post every dawn, the urgent ones shortages post and
 * the ones the Steward petitioned for. The Crown's fiscal officers fill them, for a premium into the Crown's Purse: raw goods
 * from the stockpile, finished items and potions left within a step of the machine, the warehouse dock (economy/petitions.dm);
 * a region behind a held road waits. Anyone may read the ledger and what each region trades.
 */
/obj/structure/roguemachine/steward_export/examine(mob/user)
	. = ..()
	. += span_info("[length(SSrogue_trade.orders)] standing order\s open. The Crown's officers fill them from the stockpile here.")
	. += span_info("Finished arms, garments, jewelry and potions for an order are left on the floor beside the machine.")

/obj/structure/roguemachine/steward_export/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	playsound(src, ROGUE_SOUND_KEYBOARD, 100, FALSE, -1)
	return ..()

/obj/structure/roguemachine/steward_export/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueStandingOrders", name)
		ui.open()

/obj/structure/roguemachine/steward_export/ui_static_data(mob/user)
	var/list/data = list()
	var/list/regions = list()
	for(var/id in SSrogue_trade.regions)
		var/datum/rogue_trade_region/region = SSrogue_trade.regions[id]
		regions += list(list(
			"name" = region.name,
			"subtitle" = region.subtitle,
			"produces" = region.good_names(region.produces),
			"demands" = region.good_names(region.demands),
		))
	data["regions"] = regions
	return data

/obj/structure/roguemachine/steward_export/ui_data(mob/user)
	var/list/data = list()
	data["fiscal"] = rogue_fiscal_authority(user)
	data["purse"] = SSrogue_treasury.crown_purse?.account_balance || 0
	var/list/orders = list()
	for(var/datum/rogue_standing_order/order as anything in SSrogue_trade.orders)
		orders += list(order.ui_entry())
	data["orders"] = orders
	return data

/obj/structure/roguemachine/steward_export/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || action != "fulfill")
		return
	var/mob/living/user = ui.user
	if(!rogue_fiscal_authority(user))
		refuse("Only the Crown's officers may fill the Crown's orders.")
		return TRUE
	var/order_id = text2num("[params["id"]]")
	var/result = SSrogue_trade.fulfill_order(SSrogue_trade.find_order(order_id), user)
	if(result == ROGUE_ORDER_NEEDS_CONFIRM)
		if(tgui_alert(user, "The stockpile is short of this order. Settle it partially for a reduced payout?", name, list("Settle", "Cancel")) != "Settle")
			return TRUE
		if(QDELETED(src) || !user.Adjacent(src))
			return TRUE
		result = SSrogue_trade.fulfill_order(SSrogue_trade.find_order(order_id), user, partial = TRUE)
	if(result)
		playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)
	else
		refuse()
	return TRUE
