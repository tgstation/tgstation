/**
 * Navigator (Ratwood code/modules/roguetown/roguemachine/merchant/navigator.dm): a machine that calls trading balloons. Once a
 * minute a balloon lifts every loose item from the eight tiles around it and drops its worth in coin on the tile it came from,
 * less the Crown's export duty and the Merchant's levy (to the merchants' fund); the merchant may stop paying either, which the
 * machine tallies. Every honest sale earns the merchant the company's favor (adjust_favor(), merchant_favor.dm). The private
 * navigator pays no levy; the suspicious one in the ruins pays neither and earns no favor, but its handler keeps half unless
 * someone of the bathhouse stands near. Ratwood's market saturation and demand pools are not ported: every good sells
 * at its worth. Coins, carts and containers are left alone.
 */
/obj/item/roguemachine/navigator
	anchored = TRUE
	density = TRUE
	/// Share of the worth the handler keeps before any duty (Ratwood fixed_tax).
	var/handler_fee = 0
	/// The Crown's export duty is paid, the Merchant's levy is taken (Ratwood pay_taxes, pay_merchant_share).
	var/pay_taxes = TRUE
	var/pay_merchant_share = TRUE
	/// Sales here earn the merchant the trading company's favor (Ratwood grants_passive_favor).
	var/grants_favor = TRUE
	/// Roles that may stop paying them (Ratwood profit_id).
	var/list/profit_jobs = list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
	var/motto = "NAVIGATOR - Your goods, airborne."
	var/next_airlift = 0
	var/duty_collected = 0
	var/duty_evaded = 0
	var/levy_collected = 0

/obj/item/roguemachine/navigator/Initialize(mapload)
	. = ..()
	next_airlift = world.time + rogue_value("machines_navigator_period")
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/roguemachine/navigator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/roguemachine/navigator/update_overlays()
	. = ..()
	set_light(anchored ? 2 : 0, 2, "#1b7bf1")

/obj/item/roguemachine/navigator/examine(mob/user)
	. = ..()
	. += span_notice("This machine attracts trading balloons every [DisplayTimeText(rogue_value("machines_navigator_period"))]. Goods are sucked into the air and mammons are dropped after tax has been collected.")
	. += span_info("Drop items on the tiles around the navigator. Trading balloons arrive periodically and lift the goods away, leaving mammon in change on that tile.")
	if(handler_fee > 0)
		. += span_info("This navigator charges a fixed handler's fee of [handler_fee * 100]% before any Crown duty. Smuggler-grade.")
	else if(pay_taxes)
		. += span_info("The Crown's export duty is applied to the payout at the prevailing rate.")
	if(user?.mind?.assigned_role?.title in profit_jobs)
		. += span_info("Crown duty: <b>[pay_taxes ? "PAYING" : "DODGING"]</b>. Merchant's levy: <b>[pay_merchant_share ? "COLLECTING" : "WAIVED"]</b>.")

/obj/item/roguemachine/navigator/attack_hand(mob/user, list/modifiers)
	if(!anchored)
		return ..()
	if(ishuman(user))
		ui_interact(user)
	return TRUE

/obj/item/roguemachine/navigator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueNavigator", name)
		ui.open()

/obj/item/roguemachine/navigator/ui_data(mob/user)
	var/list/data = list()
	data["motto"] = motto
	data["handler_fee_percent"] = round(handler_fee * 100)
	data["duty_rate"] = SSrogue_treasury.get_tax_rate(ROGUE_TAX_EXPORT)
	data["levy_rate"] = SSrogue_trade.middleman_cut
	data["pay_taxes"] = pay_taxes
	data["pay_merchant_share"] = pay_merchant_share
	data["duty_collected"] = duty_collected
	data["duty_evaded"] = duty_evaded
	data["levy_collected"] = levy_collected
	data["next_airlift_seconds"] = max(0, round((next_airlift - world.time) / 10))
	data["is_proprietor"] = user?.mind?.assigned_role?.title in profit_jobs
	return data

/obj/item/roguemachine/navigator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	if(!(user?.mind?.assigned_role?.title in profit_jobs))
		to_chat(user, span_warning("Only a Merchant may tamper with the Navigator's toll."))
		return TRUE
	switch(action)
		if("toggle_duty")
			pay_taxes = !pay_taxes
			to_chat(user, span_notice("The Navigator's toll clasp clicks. Crown duty: <b>[pay_taxes ? "PAYING" : "DODGING"]</b>."))
		if("toggle_levy")
			pay_merchant_share = !pay_merchant_share
			to_chat(user, span_notice("The Navigator's toll clasp clicks. Merchant's levy: <b>[pay_merchant_share ? "COLLECTING" : "WAIVED"]</b>."))
		else
			return TRUE
	playsound(src, ROGUE_SOUND_GOLD_MISC, 80, FALSE, -1)
	return TRUE

/// Ratwood process(): once a period the balloons take what lies around the machine.
/obj/item/roguemachine/navigator/process(seconds_per_tick)
	if(!anchored || world.time < next_airlift)
		return
	next_airlift = world.time + rogue_value("machines_navigator_period")
	airlift()

/// The balloons lift the goods on each tile around the machine and pay for them there (Ratwood process() export loop).
/obj/item/roguemachine/navigator/proc/airlift()
	var/lifted = FALSE
	for(var/direction in GLOB.alldirs)
		var/turf/pad = get_step(src, direction)
		if(!pad)
			continue
		var/gross = 0
		for(var/obj/thing in pad)
			if(!exportable(thing))
				continue
			var/prize = round(thing.get_real_price() * (1 - handler_fee))
			if(prize < 1)
				continue
			gross += prize
			thing.visible_message(span_warning("[thing] is sucked into the air!"))
			qdel(thing)
		if(gross > 0)
			lifted = TRUE
			settle_export(gross, pad)
	if(lifted)
		playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)

/// What the balloons take: loose things of worth, not coins, carts, containers or anything fixed in place.
/obj/item/roguemachine/navigator/proc/exportable(obj/thing)
	if(thing.anchored || !isturf(thing.loc) || istype(thing, /obj/item/roguecoin) || istype(thing, /obj/structure/handcart))
		return FALSE
	if(istype(thing, /obj/item/storage) || istype(thing, /obj/structure/closet))
		return FALSE
	var/obj/item/ware = thing
	return !istype(ware) || !(ware.item_flags & ABSTRACT)

/**
 * Ratwood settle_export(): the Crown's export duty on the gross and on the Merchant's levy goes to the Crown's Purse, the levy
 * less its duty to the merchants' fund, the rest drops as coin on the tile. Dodged duty is tallied.
 */
/obj/item/roguemachine/navigator/proc/settle_export(gross, turf/pad)
	var/duty_rate = SSrogue_treasury.get_tax_rate(ROGUE_TAX_EXPORT)
	var/levy = pay_merchant_share ? round(gross * SSrogue_trade.middleman_cut / 100) : 0
	var/duty_on_gross = round(gross * duty_rate)
	var/duty_on_levy = round(levy * duty_rate)
	var/producer_net = max(0, gross - levy - (pay_taxes ? duty_on_gross : 0))
	var/merchant_net = max(0, levy - (pay_taxes ? duty_on_levy : 0))
	if(pay_taxes)
		var/duty = duty_on_gross + duty_on_levy
		if(duty > 0 && SSrogue_treasury.mint(SSrogue_treasury.crown_purse, duty, "[ROGUE_TAX_EXPORT] ([name])"))
			SSrogue_treasury.apply_concordat_tithe(gross + levy, ROGUE_TAX_EXPORT)
			SSrogue_trade.total_export_duty += duty
			duty_collected += duty
	else
		duty_evaded += duty_on_gross + duty_on_levy
	if(merchant_net > 0 && SSrogue_treasury.mint(SSrogue_treasury.get_fund(ROGUE_FUND_MERCHANT), merchant_net, "Merchant's levy ([name])"))
		levy_collected += merchant_net
	if(grants_favor)
		SSrogue_trade.adjust_favor(round(gross * rogue_value("machines_navigator_favor_share")))
	if(producer_net > 0)
		rogue_coins_out(producer_net, null, null, pad)

/// The Merchant's own navigator: duty paid, no levy (Ratwood navigator/private).
/obj/item/roguemachine/navigator/private
	motto = "NAVIGATOR - Proprietor's berth."
	pay_merchant_share = FALSE

/// The smugglers' navigator: no duty, no levy, half kept by the handler unless the bathhouse stands near (Ratwood navigator/blackmarket).
/obj/item/roguemachine/navigator/blackmarket
	motto = "NA?!G@#OR - FREEDOM OF TRANSACTION."
	pay_taxes = FALSE
	pay_merchant_share = FALSE
	grants_favor = FALSE
	profit_jobs = list()

/obj/item/roguemachine/navigator/blackmarket/Initialize(mapload)
	. = ..()
	handler_fee = rogue_value("machines_navigator_smuggler_fee")

/obj/item/roguemachine/navigator/blackmarket/examine(mob/user)
	. = ..()
	. += span_notice("The rates here are disastrous. Having a facilitator from the bathhouse nearby might improve them to 100%.")
	if(handler_fee <= 0)
		. += span_notice("A facilitator is present. Current handler's fee: none.")
	else
		. += span_warning("No facilitator present. Current handler's fee: [handler_fee * 100]%.")

/obj/item/roguemachine/navigator/blackmarket/airlift()
	handler_fee = rogue_value("machines_navigator_smuggler_fee")
	for(var/mob/living/carbon/human/facilitator in range(7, src))
		if(facilitator.stat != DEAD && rogue_bathhouse_staff(facilitator))
			handler_fee = 0
			break
	return ..()
