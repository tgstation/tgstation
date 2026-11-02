/**
 * The ship fulfillment crate (Ratwood merchant/trade/fulfillment_crate.dm and the harbor tab of merchant/_goldface.dm): the
 * harbor of the realm. Anyone with a NERVELOCK account deposits goods that docked ships demand and is paid to the account, less
 * the Crown's export duty and the merchant's middleman cut; ships also buy provisions of their realm's taste (dishes, drinks by
 * the keg dragged onto the crate, spirits by the sealed bottle), and a handcart or bin dragged onto the crate is unloaded. The
 * merchant and the shophand hail ships into port, send them away, buy the cargo and the cultural stock the ships sell with coins
 * inserted into the crate (paying the Crown's import tariff), set the middleman cut and may stop paying the Crown's duties here.
 * Ships of the merchant's kin pay more and sell cheaper (economy/ship_trade.dm); whatever the company sold bears its seal, and
 * no captain buys it back.
 */
/obj/structure/roguemachine/ship_fulfillment
	/// Roles that run the harbor (Ratwood profit_id).
	var/list/profit_jobs = list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
	/// The merchant stopped paying the Crown's export duty and import tariff here (Ratwood duty_suspended).
	var/duty_dodged = FALSE
	/// Crown duties paid and dodged here, for the merchant's audit.
	var/duty_collected = 0
	var/duty_evaded = 0

/obj/structure/roguemachine/ship_fulfillment/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/roguemachine/ship_fulfillment/update_overlays()
	. = ..()
	set_light(1, 1, "#c8a060")
	. += mutable_appearance(icon, "vendor-merch")

/obj/structure/roguemachine/ship_fulfillment/examine(mob/user)
	. = ..()
	. += span_info("Use a good on the crate to sell it to a docked ship that wants it, right click to sell everything at my feet. A NERVELOCK account is needed.")
	. += span_info("Drag a full keg, a handcart or a bin onto the crate to sell what it holds.")
	var/buying = 0
	for(var/datum/rogue_trade_ship/ship as anything in SSrogue_trade.docked_ships())
		for(var/list/line as anything in ship.demands + ship.provisions)
			if(line[ROGUE_LINE_DONE] < line[ROGUE_LINE_TARGET])
				buying++
				break
	if(buying)
		. += span_info("[buying] vessel\s at the pier seek[buying == 1 ? "s" : ""] goods. Look into the crate for the manifest.")
	else
		. += span_info("No vessels currently buying.")

/// The merchant and the shophand work the harbor (Ratwood can_manage()).
/obj/structure/roguemachine/ship_fulfillment/proc/can_manage(mob/user)
	return ishuman(user) && (user.mind?.assigned_role?.title in profit_jobs)

/obj/structure/roguemachine/ship_fulfillment/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	if(can_manage(user))
		SSrogue_trade.touch_merchant_activity()
	playsound(src, ROGUE_SOUND_GOLD_MENU, 100, FALSE, -1)
	return ..()

/obj/structure/roguemachine/ship_fulfillment/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguecoin))
		take_coins(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguebin))
		var/list/tally = new_tally()
		unload(tool, user, tally)
		flush_tally(tally, user)
	else
		deposit(tool, user)
	SStgui.update_uis(src)
	return ITEM_INTERACT_SUCCESS

/// A keg, a handcart or a bin dragged onto the crate sells what it holds (Ratwood MouseDrop_T()).
/obj/structure/roguemachine/ship_fulfillment/mouse_drop_receive(atom/dropped, mob/user, params)
	. = ..()
	if(!ishuman(user) || !Adjacent(user) || !user.Adjacent(dropped))
		return
	if(istype(dropped, /obj/structure/fermentation_keg))
		sell_keg(dropped, user)
	else if(istype(dropped, /obj/structure/handcart) || istype(dropped, /obj/item/roguebin))
		var/list/tally = new_tally()
		unload(dropped, user, tally)
		flush_tally(tally, user)
	else
		return
	SStgui.update_uis(src)

/// Right click sells everything at the seller's feet to the ships, carts and kegs with it, paid in one sum (Ratwood attack_right()).
/obj/structure/roguemachine/ship_fulfillment/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !ishuman(user))
		return
	if(!SSrogue_treasury.get_account(user))
		refuse("No account found for [user]. Submit your fingers to a Nervelock for inspection.")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/list/tally = new_tally()
	var/turf/spot = get_turf(user)
	for(var/obj/item/thing in spot)
		if(istype(thing, /obj/item/roguebin))
			unload(thing, user, tally)
		else if(!istype(thing, /obj/item/roguecoin))
			deposit(thing, user, tally)
	for(var/obj/structure/handcart/cart in spot)
		unload(cart, user, tally)
	for(var/obj/structure/fermentation_keg/keg in spot)
		sell_keg(keg, user, tally)
	flush_tally(tally, user)
	say("Bulk fulfillment in progress...")
	playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)
	playsound(src, ROGUE_SOUND_FLUSH, 100, FALSE, -1)
	SStgui.update_uis(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// The sums of a bulk sale, paid at once by flush_tally().
/obj/structure/roguemachine/ship_fulfillment/proc/new_tally()
	return list("producer" = 0, "gross" = 0, "duty" = 0, "cut" = 0, "quality" = 0, "kin" = 0, "lines" = list())

/**
 * Sells an item to the first docked ship that buys it (Ratwood attempt_deposit()): a provision line by its exact dish or bottle
 * first, then a cargo line by its trade good; a stack sells as many units as the line still wants, the price follows the item's
 * quality. Company stock and rotten food are refused. With a tally (bulk selling) the payout waits for flush_tally().
 * Returns TRUE when something was sold.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/deposit(obj/item/thing, mob/living/user, list/tally)
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account)
		if(!tally)
			refuse("No account found for [user]. Submit your fingers to a Nervelock for inspection.")
		return FALSE
	if(thing.rogue_company_seal)
		if(!tally)
			to_chat(user, span_warning("[thing] bears a Ferentian Trading Company seal - foreign captains will not buy Company stock back."))
		return FALSE
	var/obj/item/reagent_containers/food/food = thing
	if(istype(food) && food.rotten)
		if(!tally)
			to_chat(user, span_warning("[thing] is rotten. No captain will load spoiled stores aboard."))
		return FALSE
	var/provision_sold = sell_provision(thing, user, account, tally)
	if(!isnull(provision_sold))
		return provision_sold
	var/datum/rogue_trade_good/good = SSrogue_trade.good_for(thing)
	if(!good)
		if(!tally)
			to_chat(user, span_warning("[thing] is not something a foreign vessel would buy in bulk."))
		return FALSE
	var/list/match = SSrogue_trade.find_demand(good)
	if(!match)
		if(!tally)
			to_chat(user, span_warning("No vessel here is buying [thing]."))
		return FALSE
	var/datum/rogue_trade_ship/ship = match[1]
	var/list/line = match[2]
	var/units = 1
	var/obj/item/stack/pile = isstack(thing) ? thing : null
	if(pile)
		units = min(pile.get_amount(), line[ROGUE_LINE_TARGET] - line[ROGUE_LINE_DONE])
	if(units <= 0)
		return FALSE
	var/unit_price = round(line[ROGUE_LINE_PRICE] * rogue_quality_price_mult(thing.rogue_quality))
	var/quality_delta = (unit_price - line[ROGUE_LINE_PRICE]) * units
	if(!tally && thing.rogue_has_notable_quality())
		var/remark = rogue_harbor_quality_remark(thing.rogue_quality)
		if(remark)
			say(remark)
	line[ROGUE_LINE_DONE] += units
	if(pile && units < pile.get_amount())
		pile.use(units)
	else
		qdel(thing)
	settle(unit_price * units, user, account, ship, good.name, units, tally, quality_delta)
	return TRUE

/**
 * Sells a dish or a bottle to a ship that wants it among its provisions (Ratwood find_dish_match()): drinks other than spirits
 * go by the keg only, an opened bottle is refused. Returns TRUE when sold, FALSE when refused, null when no ship wants it.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/sell_provision(obj/item/thing, mob/living/user, datum/bank_account/rogue/account, list/tally)
	var/list/match = SSrogue_trade.find_provision(thing.type)
	if(!match)
		return null
	var/datum/rogue_trade_ship/ship = match[1]
	var/list/line = match[2]
	if(line[ROGUE_LINE_TAG] == ROGUE_PROVISION_DRINKS && !line[ROGUE_LINE_BY_BOTTLE])
		if(!tally)
			to_chat(user, span_warning("Captains buy drinks by the barrel - drag a full keg onto [src], not loose bottles."))
		return FALSE
	var/obj/item/reagent_containers/glass/bottle/brewing_bottle/bottle = thing
	if(istype(bottle) && !bottle.sealed)
		if(!tally)
			to_chat(user, span_warning("[thing] has been unsealed - no captain will load an opened bottle."))
		return FALSE
	var/unit_price = round(line[ROGUE_LINE_PRICE] * rogue_quality_price_mult(thing.rogue_quality))
	var/quality_delta = unit_price - line[ROGUE_LINE_PRICE]
	if(!tally && thing.rogue_has_notable_quality())
		var/remark = rogue_harbor_quality_remark(thing.rogue_quality)
		if(remark)
			say(remark)
	line[ROGUE_LINE_DONE]++
	qdel(thing)
	settle(unit_price, user, account, ship, line[ROGUE_LINE_NAME], 1, tally, quality_delta)
	return TRUE

/**
 * Sells a finished, sealed batch in its keg to a ship that wants that drink (Ratwood attempt_deposit_keg()). A keg fixed in place,
 * still brewing, tapped or empty is refused, and so is a keg of spirits, which captains buy by the bottle.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/sell_keg(obj/structure/fermentation_keg/keg, mob/living/user, list/tally)
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account)
		if(!tally)
			refuse("No account found for [user]. Submit your fingers to a Nervelock for inspection.")
		return FALSE
	if(keg.anchored)
		if(!tally)
			to_chat(user, span_warning("[keg] is fixed in place - bottle its spirits and deposit those instead."))
		return FALSE
	if(keg.brewing || !keg.ready_to_bottle || keg.tapped || !keg.selected_recipe)
		if(!tally)
			to_chat(user, span_warning("[keg] holds no finished, sealed batch the captains would buy."))
		return FALSE
	var/list/match = SSrogue_trade.find_provision(keg.selected_recipe.output_bottle_type)
	if(!match)
		if(!tally)
			to_chat(user, span_warning("No vessel here is buying [keg.selected_recipe.bottle_name]."))
		return FALSE
	var/datum/rogue_trade_ship/ship = match[1]
	var/list/line = match[2]
	if(line[ROGUE_LINE_BY_BOTTLE])
		if(!tally)
			to_chat(user, span_warning("Captains buy [keg.selected_recipe.bottle_name] by the sealed bottle - bottle it first."))
		return FALSE
	line[ROGUE_LINE_DONE]++
	qdel(keg)
	settle(line[ROGUE_LINE_PRICE], user, account, ship, line[ROGUE_LINE_NAME], 1, tally, 0)
	return TRUE

/**
 * Empties a handcart or a bin into the crate (Ratwood attempt_deposit() of carts and bins): what the ships buy is sold; a cart
 * tips the rest out onto its tile, a bin keeps it. Returns TRUE when something was sold.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/unload(atom/movable/container, mob/living/user, list/tally)
	var/list/held = list()
	var/obj/structure/handcart/cart = container
	if(istype(cart))
		held = cart.cargo.Copy()
	else
		for(var/obj/item/inside in container)
			held += inside
	. = FALSE
	for(var/obj/item/thing in held)
		if(!QDELETED(thing) && deposit(thing, user, tally))
			. = TRUE
	if(istype(cart) && !QDELETED(cart))
		cart.dump_contents()
	playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)

/// Where the merchant's middleman cut goes: the merchant's fund, or the merchant's own account without one.
/obj/structure/roguemachine/ship_fulfillment/proc/middleman_account()
	var/datum/bank_account/fund = SSrogue_treasury.get_fund(ROGUE_FUND_MERCHANT)
	if(fund)
		return fund
	for(var/datum/bank_account/rogue/account as anything in SSrogue_treasury.accounts)
		if(account.job_title() == JOB_ROCKHILL_MERCHANT && account.owner())
			return account
	return null

/**
 * Pays a ship sale (Ratwood settle_payout()): a ship of the merchant's kin pays more; the Crown's export duty on the sale and on
 * the merchant's cut goes to the Crown's Purse, the cut less its duty to the merchant, the rest to the seller. Money from abroad
 * is new to the realm; the sale counts towards the trade the ship's captain hoped for.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/settle(gross, mob/living/user, datum/bank_account/rogue/account, datum/rogue_trade_ship/ship, good_name, units, list/tally, quality_delta)
	if(gross <= 0)
		return
	var/kin_bonus = 0
	var/kin_mult = SSrogue_trade.kin_sell_mult(ship)
	if(kin_mult > 1)
		var/before = gross
		gross = round(gross * kin_mult)
		kin_bonus = gross - before
	var/datum/bank_account/middleman = middleman_account()
	var/cut = middleman ? gross * SSrogue_trade.middleman_cut / 100 : 0
	var/duty_rate = SSrogue_treasury.get_tax_rate(ROGUE_TAX_EXPORT)
	var/duty_on_gross = round(gross * duty_rate)
	var/duty_on_cut = round(cut * duty_rate)
	var/duty = 0
	if(duty_dodged)
		duty_evaded += duty_on_gross + duty_on_cut
		duty_on_gross = 0
		duty_on_cut = 0
	else
		duty = duty_on_gross + duty_on_cut
		if(SSrogue_treasury.mint(SSrogue_treasury.crown_purse, duty, "[ROGUE_TAX_EXPORT] (ship fulfillment)"))
			duty_collected += duty
			SSrogue_trade.total_export_duty += duty
			SSrogue_treasury.apply_concordat_tithe(gross, ROGUE_TAX_EXPORT)
	var/merchant_net = round(cut) - duty_on_cut
	if(merchant_net > 0)
		SSrogue_treasury.mint(middleman, merchant_net, "Merchant's levy: [units] [good_name] -> [ship.name]")
	var/producer = max(0, gross - duty_on_gross - round(cut))
	ship.traded += gross
	SSrogue_trade.total_ship_sales += gross
	playsound(src, ROGUE_SOUND_HISS, 70, TRUE, -1)
	if(tally)
		tally["producer"] += producer
		tally["gross"] += gross
		tally["duty"] += duty
		tally["cut"] += max(0, merchant_net)
		tally["quality"] += quality_delta
		tally["kin"] += kin_bonus
		var/list/lines = tally["lines"]
		lines += "[units] [good_name] -> [ship.name]"
		return
	if(producer > 0 && SSrogue_treasury.mint(account, producer, "[units] [good_name] for [ship.name]: gross [gross]m, Crown [duty]m, Merchant [max(0, merchant_net)]m[kin_bonus ? ", Kinship +[kin_bonus]m" : ""][quality_delta ? ", quality [quality_delta > 0 ? "+" : ""][quality_delta]m" : ""]"))
		account.bank_card_talk("You received [producer]m. ([units] [good_name] for [ship.name])")

/// Pays the whole of a bulk sale at once (Ratwood flush_tally()).
/obj/structure/roguemachine/ship_fulfillment/proc/flush_tally(list/tally, mob/living/user)
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account || tally["producer"] <= 0)
		if(!length(tally["lines"]))
			to_chat(user, span_warning("No vessel here is buying anything I brought."))
		return
	var/quality = tally["quality"]
	var/kin = tally["kin"]
	if(SSrogue_treasury.mint(account, tally["producer"], "[english_list(tally["lines"])]: gross [tally["gross"]]m, Crown [tally["duty"]]m, Merchant [tally["cut"]]m[kin ? ", Kinship +[kin]m" : ""][quality ? ", quality [quality > 0 ? "+" : ""][quality]m" : ""]"))
		account.bank_card_talk("You received [tally["producer"]]m. (bulk sale to the ships)")
	if(quality)
		var/remark = rogue_harbor_quality_remark(quality > 0 ? ROGUE_QUALITY_MASTERWORK : ROGUE_QUALITY_CRUDE)
		if(remark)
			say(remark)

/// The Crown's import tariff on a purchase from a ship, unless dodged here; it goes to the Crown's Purse with the Concordat's tithe.
/obj/structure/roguemachine/ship_fulfillment/proc/collect_import_tariff(tariff, base, reason)
	if(tariff <= 0)
		return
	if(duty_dodged)
		duty_evaded += tariff
		return
	if(SSrogue_treasury.mint(SSrogue_treasury.crown_purse, tariff, "[ROGUE_TAX_IMPORT] ([reason])"))
		duty_collected += tariff
		SSrogue_treasury.total_tariff += tariff
		SSrogue_treasury.apply_concordat_tithe(base, ROGUE_TAX_IMPORT)

/**
 * The merchant buys cargo a docked ship sells (Ratwood bulk_buy of the GOLDFACE): paid from the coins in the crate, cheaper from
 * kin, with the Crown's import tariff unless the merchant dodges it; the goods come out at the crate under the company's seal.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/buy_cargo(datum/rogue_trade_ship/ship, good_id, qty, mob/living/user)
	if(!ship || ship.state != ROGUE_SHIP_DOCKED)
		to_chat(user, span_warning("That vessel is no longer at the pier."))
		return FALSE
	var/list/line
	for(var/list/supply as anything in ship.supplies)
		var/datum/rogue_trade_good/good = supply[ROGUE_LINE_GOOD]
		if(good.id == good_id)
			line = supply
			break
	if(!line)
		to_chat(user, span_warning("That cargo is no longer on offer."))
		return FALSE
	qty = min(round(qty), line[ROGUE_LINE_TARGET] - line[ROGUE_LINE_DONE], rogue_value("trade_bulk_buy_max"))
	if(qty < 1)
		to_chat(user, span_warning("That cargo is sold out."))
		return FALSE
	var/datum/rogue_trade_good/good = line[ROGUE_LINE_GOOD]
	var/obj/item/cargo_type = good.item_type || good.purchase_type
	if(!cargo_type)
		to_chat(user, span_warning("That cargo cannot be handled at this pier."))
		return FALSE
	var/unit_price = line[ROGUE_LINE_PRICE]
	var/kin_mult = SSrogue_trade.kin_buy_mult(ship, user)
	if(kin_mult < 1)
		unit_price = max(1, round(unit_price * kin_mult))
	var/gross = unit_price * qty
	var/kin_saving = line[ROGUE_LINE_PRICE] * qty - gross
	var/tariff = round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * gross)
	var/total = gross + (duty_dodged ? 0 : tariff)
	if(budget < total)
		say("Not enough!")
		return FALSE
	budget -= total
	line[ROGUE_LINE_DONE] += qty
	collect_import_tariff(tariff, gross, "bulk import: [good.name] x[qty]")
	ship.traded += gross
	SSrogue_trade.total_ship_purchases += total
	var/turf/spot = drop_location()
	for(var/i in 1 to qty)
		var/obj/item/cargo = new cargo_type(spot)
		cargo.rogue_company_seal = TRUE
		if(good.reagent_type && good.required_volume && cargo.reagents)
			cargo.reagents.add_reagent(good.reagent_type, good.required_volume)
	playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
	to_chat(user, span_notice("You buy [qty] [good.name] from [ship.name] for [total]m[!duty_dodged && tariff ? " (incl. [tariff]m Crown duty)" : ""][kin_saving > 0 ? " (Kinship saved [kin_saving]m)" : ""]."))
	return TRUE

/**
 * The merchant buys a pack of the cultural stock a docked ship sells (Ratwood cultural_buy of the GOLDFACE): at the ship's
 * discount, cheaper from kin, with the Crown's import tariff unless dodged; the goods come out at the crate under the company's
 * seal, and the purchase counts towards the trade the captain hoped for.
 */
/obj/structure/roguemachine/ship_fulfillment/proc/buy_cultural(datum/rogue_trade_ship/ship, pack_text, mob/living/user)
	if(!ship || ship.state != ROGUE_SHIP_DOCKED)
		to_chat(user, span_warning("That vessel is no longer at the pier."))
		return FALSE
	var/pack_type = text2path(pack_text)
	var/list/entry = ship.cultural_line(pack_type)
	var/datum/rogue_supply_pack/pack = pack_type ? GLOB.rogue_supply_packs[pack_type] : null
	if(!entry || !pack)
		to_chat(user, span_warning("That stock is no longer available."))
		return FALSE
	var/price = entry["cost"]
	var/kin_mult = SSrogue_trade.kin_buy_mult(ship, user)
	if(kin_mult < 1)
		price = max(1, round(price * kin_mult))
	var/kin_saving = entry["cost"] - price
	var/tariff = round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * price)
	var/total = price + (duty_dodged ? 0 : tariff)
	if(budget < total)
		say("Not enough!")
		return FALSE
	budget -= total
	entry["qty"]--
	collect_import_tariff(tariff, price, "cultural stock: [pack.name]")
	ship.traded += price
	SSrogue_trade.total_ship_purchases += total
	var/turf/spot = drop_location()
	for(var/ware_type in pack.contains)
		var/obj/item/ware = new ware_type(spot)
		if(istype(ware))
			ware.rogue_company_seal = TRUE
	playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
	to_chat(user, span_notice("You buy [pack.name] from [ship.name] for [total]m[!duty_dodged && tariff ? " (incl. [tariff]m Crown duty)" : ""][kin_saving > 0 ? " (Kinship saved [kin_saving]m)" : ""]."))
	return TRUE

/obj/structure/roguemachine/ship_fulfillment/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueHarbor", name)
		ui.open()

/obj/structure/roguemachine/ship_fulfillment/ui_data(mob/user)
	var/list/data = list()
	var/manager = can_manage(user)
	data["budget"] = budget
	data["manager"] = manager
	data["has_account"] = !!SSrogue_treasury.get_account(user)
	data["duty_dodged"] = duty_dodged
	data["duty_rate"] = round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_EXPORT) * 100)
	data["tariff_rate"] = round(SSrogue_treasury.get_tax_rate(ROGUE_TAX_IMPORT) * 100)
	data["middleman_cut"] = SSrogue_trade.middleman_cut
	data["duty_collected"] = duty_collected
	data["duty_evaded"] = duty_evaded
	data["hails_left"] = SSrogue_trade.hails_left
	data["dock_spots"] = SSrogue_trade.dock_spots()
	data["kinship"] = SSrogue_trade.kinship_homeland
	data["favor"] = SSrogue_trade.merchant_favor
	var/list/docked = list()
	for(var/datum/rogue_trade_ship/ship as anything in SSrogue_trade.docked_ships())
		var/list/entry = ship.ui_entry()
		entry["buy_percent"] = round(SSrogue_trade.kin_buy_mult(ship, user) * 100)
		entry["sell_percent"] = round(SSrogue_trade.kin_sell_mult(ship) * 100)
		docked += list(entry)
	data["docked"] = docked
	var/list/offshore = list()
	if(manager)
		for(var/datum/rogue_trade_ship/ship as anything in SSrogue_trade.offshore_ships())
			offshore += list(ship.ui_entry())
	data["offshore"] = offshore
	return data

/obj/structure/roguemachine/ship_fulfillment/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(action == "change")
		return_change(user)
		return TRUE
	if(!can_manage(user))
		return TRUE
	SSrogue_trade.touch_merchant_activity()
	switch(action)
		if("hail")
			var/failure = SSrogue_trade.hail(SSrogue_trade.find_ship(text2num("[params["id"]]")), user)
			if(failure)
				to_chat(user, span_warning(failure))
				refuse()
			else
				playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
			return TRUE
		if("send_away")
			var/failure = SSrogue_trade.send_away(SSrogue_trade.find_ship(text2num("[params["id"]]")))
			if(failure)
				to_chat(user, span_warning(failure))
				refuse()
			return TRUE
		if("buy")
			buy_cargo(SSrogue_trade.find_ship(text2num("[params["id"]]")), "[params["good"]]", text2num("[params["qty"]]"), user)
			return TRUE
		if("buy_cultural")
			buy_cultural(SSrogue_trade.find_ship(text2num("[params["id"]]")), "[params["pack"]]", user)
			return TRUE
		if("set_cut")
			var/percent = tgui_input_number(user, "Merchant's middleman cut of every ship sale, in percent:", name, SSrogue_trade.middleman_cut, rogue_value("trade_middleman_cut_max"), 0)
			if(isnull(percent) || QDELETED(src) || !can_manage(user))
				return TRUE
			SSrogue_trade.middleman_cut = clamp(round(percent), 0, rogue_value("trade_middleman_cut_max"))
			to_chat(user, span_notice("Merchant's levy set to [SSrogue_trade.middleman_cut]%."))
			return TRUE
		if("toggle_duty")
			duty_dodged = !duty_dodged
			to_chat(user, span_notice("Crown duties now [duty_dodged ? "DODGED" : "PAID"] at this crate."))
			playsound(src, ROGUE_SOUND_GOLD_MISC, 70, FALSE, -1)
			return TRUE
