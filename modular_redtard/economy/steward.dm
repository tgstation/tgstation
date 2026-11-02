/**
 * Nerve master (Ratwood code/modules/roguetown/roguemachine/steward/steward.dm): the Steward's desk of the treasury. The steward's
 * key (or the lord's master key) locks it. Open, it shows the Crown's Purse, its ledger and its solvency, takes coins into the
 * Purse and pays the Purse out in coin, borrows from the trading company, sets the wage of every role (no lower than the
 * charters allow), the Crown's levies and the poll tax, grants and fines the subjects' accounts, holds back a subject's wages,
 * forgives the Crown's debtors and clears poll tax arrears, lists every loan and fund of the realm, opens the charters, and runs
 * the stockpile: prices, limits, what the Crown buys and sells, shipments abroad. Its trade pages (Ratwood StewardTrade) show
 * the market's events and blockades, the Burgher Pledge and the Right of Customs in Excess, trade with each region by hand,
 * order the Crown's imports and its standing imports, and petition the regions for orders.
 * The trade regions live in trade.dm, the crown imports in crown_imports.dm, the petitions in petitions.dm.
 */
/obj/structure/roguemachine/steward
	var/locked = FALSE
	/// Lockid of the key that locks it; the lord's master key works too.
	var/keycontrol = "steward"
	/// Roles never paid a wage, left out of the wage list (Ratwood excluded_jobs).
	var/static/list/unpaid_jobs = list(JOB_ROCKHILL_WRETCH, JOB_ROCKHILL_VAGABOND, JOB_ROCKHILL_ADVENTURER)

/obj/structure/roguemachine/steward/update_icon_state()
	icon_state = locked ? "steward_machine_off" : "steward_machine"
	return ..()

/obj/structure/roguemachine/steward/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		if(!rockhill_key_fits(tool, keycontrol, TRUE))
			to_chat(user, span_warning("Wrong key."))
			return ITEM_INTERACT_BLOCKING
		locked = !locked
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		update_appearance()
		if(locked)
			SStgui.close_uis(src)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		if(!rogue_coin_accepted(tool))
			return ITEM_INTERACT_BLOCKING
		var/value = tool.get_real_price()
		qdel(tool)
		SSrogue_treasury.mint(SSrogue_treasury.crown_purse, value, "NERVE MASTER deposit")
		playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/structure/roguemachine/steward/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	if(locked)
		to_chat(user, span_warning("It's locked."))
		return TRUE
	return ..()

/obj/structure/roguemachine/steward/ui_interact(mob/user, datum/tgui/ui)
	if(locked)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueStewardry", name)
		ui.open()

/obj/structure/roguemachine/steward/ui_data(mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/list/data = list()
	data["purse"] = treasury.crown_purse?.account_balance || 0
	data["floor"] = treasury.stockpile_purchase_floor
	data["ledger"] = rogue_ledger(treasury.crown_purse)
	data["totals"] = list(
		"rural_tax" = treasury.total_rural_tax,
		"tariff" = treasury.total_tariff,
		"poll_tax" = treasury.total_poll_tax,
		"poll_subsidy" = treasury.total_poll_subsidy,
		"fines" = treasury.total_fines,
		"tithe" = treasury.total_concordat_tithe,
		"wages" = treasury.total_wages,
		"export" = treasury.total_export,
		"import" = treasury.total_import,
		"trade" = treasury.economic_output,
		"contract_levy" = treasury.total_contract_levy,
		"royal_custom" = treasury.total_royal_custom,
		"banditry" = SSrogue_trade.total_banditry,
	)
	data["solvency"] = list(
		"state" = rogue_treasury_state_label(treasury.treasury_state),
		"sequestered" = treasury.treasury_state == ROGUE_TREASURY_SEQUESTERED,
		"debt" = treasury.treasury_debt,
		"wage_outlay" = treasury.expected_wage_outlay(),
		"ftc_blocker" = treasury.ftc_loan_blocker(),
		"ftc_min" = ROGUE_FTC_LOAN_MIN,
		"ftc_max" = ROGUE_FTC_LOAN_MAX,
		"ftc_interest" = round(ROGUE_FTC_LOAN_INTEREST * 100),
	)
	var/list/levies = list()
	for(var/levy in treasury.tax_rates)
		levies += list(list("name" = levy, "percent" = round(treasury.tax_rates[levy] * 100, 1)))
	data["levies"] = levies
	data["levy_locked"] = treasury.levy_changed_dawn == ROGUE_TREASURY_DAY
	data["poll"] = treasury.poll_projection()
	data["poll_locked"] = treasury.poll_changed_dawn == ROGUE_TREASURY_DAY
	data["poll_min"] = -ROGUE_POLL_MAX_SUBSIDY
	data["poll_max"] = ROGUE_POLL_MAX_RATE
	data["carta"] = treasury.decree_active(ROGUE_DECREE_MAGNA_CARTA)
	var/list/wages = list()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(!istype(job, /datum/job/roguetown) || (job.title in unpaid_jobs))
			continue
		wages += list(list("title" = job.title, "wage" = treasury.daily_payments[job.title] || 0, "floor" = treasury.wage_floor(job.title)))
	data["wages"] = wages
	var/list/accounts = list()
	for(var/datum/bank_account/rogue/account as anything in treasury.accounts)
		var/mob/living/owner = account.owner()
		accounts += list(list(
			"ref" = REF(account),
			"holder" = account.account_holder,
			"job" = account.job_title(),
			"balance" = account.account_balance,
			"estate" = account.estate_income,
			"suspended" = account.wages_suspended,
			"max_fine" = treasury.max_fine(account),
			"poll_owed" = account.poll_owed,
			"poll_overdue" = account.poll_overdue_days,
			"defaulter" = owner && HAS_TRAIT(owner, TRAIT_DEBTOR),
		))
	data["accounts"] = accounts
	var/list/loans = list()
	for(var/datum/rogue_loan/loan as anything in treasury.loans)
		loans += list(loan.ui_entry())
	data["loans"] = loans
	var/list/funds = list()
	for(var/fund_id in treasury.funds)
		var/datum/bank_account/rogue/fund = treasury.funds[fund_id]
		funds += list(list("id" = fund_id, "holder" = fund.account_holder, "balance" = fund.account_balance, "lent" = treasury.outstanding_principal(fund)))
	data["funds"] = funds
	var/list/stocks = list()
	for(var/datum/roguestock/stock as anything in treasury.stockpile_datums)
		var/list/entry = stock.ui_entry()
		entry["automatic"] = stock.automatic_price
		stocks += list(entry)
	data["stocks"] = stocks
	trade_ui_data(data)
	return data

/// The trade pages (Ratwood steward_trade_tgui.dm): pledge, charters of trade, market, regions, imports, petitions.
/obj/structure/roguemachine/steward/proc/trade_ui_data(list/data)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/datum/controller/subsystem/rogue_trade/trade = SSrogue_trade
	data["pledge"] = list(
		"balance" = treasury.burgher_pledge?.account_balance || 0,
		"renewal" = treasury.pledge_renewal(),
		"tribute" = treasury.pledge_arms_tribute(),
		"bull" = treasury.decree_active(ROGUE_DECREE_GOLDEN_BULL),
		"spent" = treasury.total_pledge_spent,
	)
	data["ordinance"] = treasury.bathhouse_ordinance
	data["custom"] = list(
		"unlocked" = treasury.royal_custom_unlocked,
		"active" = treasury.royal_custom_in_force(),
		"margin" = treasury.royal_custom_margin,
		"threshold" = treasury.royal_custom_threshold,
		"volume" = treasury.economic_output,
	)
	var/list/events = list()
	for(var/datum/rogue_economic_event/event as anything in trade.events)
		events += list(event.ui_entry())
	var/list/blockades = list()
	for(var/datum/rogue_blockade/blockade as anything in trade.blockades)
		blockades += list(blockade.ui_entry())
	data["market"] = list(
		"events" = events,
		"blockades" = blockades,
		"banditry_debt" = treasury.banditry_debt,
		"banditry_losses" = trade.banditry_losses(),
		"blockade_days" = rogue_value("trade_blockade_days"),
	)
	var/list/regions = list()
	for(var/region_id in trade.regions)
		var/datum/rogue_trade_region/region = trade.regions[region_id]
		regions += list(list(
			"id" = region_id,
			"name" = region.name,
			"subtitle" = region.subtitle,
			"blockaded" = region.blockaded,
			"imports" = region.trade_lines(TRUE),
			"exports" = region.trade_lines(FALSE),
		))
	data["regions"] = regions
	data["region_trade_max"] = rogue_value("trade_region_trade_max")
	var/list/crown_imports = list()
	for(var/datum/rogue_crown_import/crown_import as anything in trade.crown_imports)
		if(crown_import.available())
			crown_imports += list(crown_import.ui_entry())
	data["crown_imports"] = crown_imports
	data["auto_imports"] = treasury.auto_import_ui_data()
	data["petitions"] = trade.petition_ui_data()

/obj/structure/roguemachine/steward/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || locked)
		return
	var/mob/living/user = ui.user
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	switch(action)
		if("withdraw")
			var/amount = tgui_input_number(user, "Pay how many mammons out of the Crown's Purse?", name, 0, min(treasury.crown_purse.account_balance, ROGUE_TRANSFER_MAX), 0)
			if(!amount || !still_usable(user) || !treasury.burn(treasury.crown_purse, amount, "Withdrawn by [user.real_name]"))
				return TRUE
			rogue_coins_out(amount, user, null, src)
			log_game("TREASURY: [key_name(user)] withdrew [amount]m from the Crown's Purse")
		if("set_floor")
			var/floor = tgui_input_number(user, "The Crown buys nothing at the stockpile while the Purse holds less than:", name, treasury.stockpile_purchase_floor, ROGUE_TRANSFER_MAX, 0)
			if(!isnull(floor) && still_usable(user))
				treasury.stockpile_purchase_floor = floor
		if("set_levy")
			var/levy = params["name"]
			if(!(levy in treasury.tax_rates))
				return TRUE
			var/percent = tgui_input_number(user, "New [levy], in percent:", name, round(treasury.tax_rates[levy] * 100, 1), 100, 0)
			if(!isnull(percent) && still_usable(user))
				treasury.set_tax_rate(levy, percent, user)
		if("set_poll")
			var/list/rates = params["rates"]
			if(islist(rates))
				treasury.set_poll_rates(rates, user)
		if("ftc_loan")
			var/blocker = treasury.ftc_loan_blocker()
			if(blocker)
				to_chat(user, span_warning("Loan refused: [blocker]"))
				return TRUE
			var/amount = tgui_input_number(user, "Borrow how many mammons from the Ferentian Trading Company, at [round(ROGUE_FTC_LOAN_INTEREST * 100)]% interest? The next payroll the Purse cannot meet will put the realm under sequestration.", name, ROGUE_FTC_LOAN_MIN, ROGUE_FTC_LOAN_MAX, ROGUE_FTC_LOAN_MIN)
			if(amount && still_usable(user))
				treasury.take_ftc_loan(amount, user)
		if("charters")
			treasury.charters_panel.ui_interact(user)
		if("set_wage")
			var/title = params["title"]
			var/datum/job/roguetown/job = SSjob.get_job(title)
			if(!istype(job))
				return TRUE
			var/floor_wage = treasury.wage_floor(title)
			var/prompt = floor_wage ? "Daily wage of the [title] (no lower than [floor_wage]m by Charter):" : "Daily wage of the [title] (0 to remove):"
			var/wage = tgui_input_number(user, prompt, name, treasury.daily_payments[title] || floor_wage, 500, 0)
			if(isnull(wage) || !still_usable(user))
				return TRUE
			if(treasury.set_wage(title, wage) > wage)
				say("By Charter, the [title]'s wage may not fall below [floor_wage]m. Payment set to the floor.")
		if("forgive")
			var/datum/rogue_loan/loan = locate(params["ref"]) in treasury.loans
			if(loan && tgui_alert(user, "Forgive [loan.debtor_name] the [loan.remaining_due()]m they owe the Crown?", name, list("Forgive", "Cancel")) == "Forgive" && still_usable(user))
				treasury.forgive_loan(loan, user)
		if("set_custom_margin")
			if(!treasury.royal_custom_unlocked)
				return TRUE
			var/percent = tgui_input_number(user, "Royal Custom margin on direct imports, in percent:", name, treasury.royal_custom_margin, rogue_value("treasury_custom_margin_max"), 0)
			if(!isnull(percent) && still_usable(user))
				treasury.set_royal_custom_margin(percent, user)
		if("crown_import")
			var/datum/rogue_crown_import/crown_import = locate(params["ref"]) in SSrogue_trade.crown_imports
			if(crown_import && SSrogue_trade.order_crown_import(crown_import, user, get_turf(src)))
				say("Rockhill imports [crown_import.name]. It will be left at the warehouse.")
				playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
		if("auto_import")
			var/good_id = "[params["id"]]"
			treasury.set_auto_import(good_id, !treasury.auto_import_active(good_id))
		if("auto_import_stop")
			treasury.stop_auto_imports()
		if("auto_import_floor")
			var/floor = tgui_input_number(user, "The standing imports buy nothing while the Purse holds less than:", name, treasury.auto_import_floor, ROGUE_TRANSFER_MAX, 0)
			if(!isnull(floor) && still_usable(user))
				treasury.auto_import_floor = round(floor)
		if("region_trade")
			trade_with_region(user, SSrogue_trade.regions["[params["region"]]"], SSrogue_trade.goods["[params["good"]]"], params["mode"] == "import")
		if("petition")
			SSrogue_trade.petition(user, SSrogue_trade.regions["[params["region"]]"], "[params["category"]]")
	if(action in list("grant", "fine", "toggle_wages", "clear_arrears"))
		var/datum/bank_account/rogue/account = locate(params["ref"]) in treasury.accounts
		if(!account)
			return TRUE
		switch(action)
			if("grant")
				var/amount = tgui_input_number(user, "Grant [account.account_holder] how many mammons from the Crown's Purse?", name, 0, min(treasury.crown_purse.account_balance, ROGUE_TRANSFER_MAX), 0)
				if(amount && still_usable(user))
					treasury.give_money(account, amount, "Crown's grant")
			if("fine")
				var/most = treasury.max_fine(account)
				if(most <= 0)
					to_chat(user, span_warning("[account.account_holder] has already been fined today, is shielded by a charter, or has nothing to take."))
					return TRUE
				var/amount = tgui_input_number(user, "Fine [account.account_holder] how many mammons? (at most [most]m)", name, 0, most, 0)
				if(!amount || !still_usable(user))
					return TRUE
				var/reason = tgui_input_text(user, "For what?", name, "Fine", max_length = MAX_NAME_LEN)
				if(!still_usable(user))
					return TRUE
				if(!treasury.fine(account, amount, reason || "Fine"))
					to_chat(user, span_warning("[account.account_holder] has already been fined today, is shielded by a charter, or has nothing to take."))
			if("toggle_wages")
				account.wages_suspended = !account.wages_suspended
			if("clear_arrears")
				if(account.poll_owed <= 0 && account.poll_overdue_days <= 0)
					return TRUE
				log_game("POLL TAX CLEARED: [key_name(user)] cleared [account.poll_owed]m poll tax arrears of [account.account_holder]")
				treasury.clear_poll_arrears(account)
				account.bank_card_talk("The Stewardry has cleared your poll tax arrears. The Crown's ledger on your head is wiped clean.")
	if(action in list("stock_payout", "stock_withdraw", "stock_auto", "stock_limit", "stock_accept", "stock_lock", "stock_autoexport", "stock_export"))
		var/datum/roguestock/stock = locate(params["ref"]) in treasury.stockpile_datums
		if(!stock)
			return TRUE
		switch(action)
			if("stock_payout")
				var/price = tgui_input_number(user, "The Crown pays sellers of [stock.name]:", name, stock.payout_price, ROGUE_TRANSFER_MAX, 0)
				if(!isnull(price) && still_usable(user))
					stock.payout_price = price
					stock.automatic_price = FALSE
			if("stock_withdraw")
				var/price = tgui_input_number(user, "The stockpile sells [stock.name] for:", name, stock.withdraw_price, ROGUE_TRANSFER_MAX, 1)
				if(!isnull(price) && still_usable(user))
					stock.withdraw_price = max(1, price)
					stock.automatic_price = FALSE
			if("stock_auto")
				stock.automatic_price = TRUE
				stock.reprice()
			if("stock_limit")
				var/limit = tgui_input_number(user, "The stockpile keeps at most this much [stock.name]:", name, stock.stockpile_limit, 500, 1)
				if(!isnull(limit) && still_usable(user))
					stock.stockpile_limit = max(1, limit)
			if("stock_accept")
				stock.accept_toggle_enabled = !stock.accept_toggle_enabled
			if("stock_lock")
				stock.withdraw_disabled = !stock.withdraw_disabled
			if("stock_autoexport")
				stock.autoexport_disabled = !stock.autoexport_disabled
			if("stock_export")
				var/revenue = 0
				var/list/quote = stock.trade_good ? SSrogue_trade.export_quote(stock.trade_good) : null
				if(quote)
					var/datum/rogue_trade_region/region = quote["region"]
					revenue = SSrogue_trade.region_export(region, stock.trade_good, min(stock.importexport_amt, stock.stockpile_amount), user)
				else if(!stock.trade_good)
					revenue = treasury.export_stock(stock, stock.importexport_amt)
				if(revenue)
					say("Exported [stock.name] for [revenue] mammons.")
	return TRUE

/**
 * The Steward trades with a region by hand (Ratwood handle_trade_import(), handle_trade_export()): buys units of a good it
 * produces into the stockpile, or ships units the stockpile holds to a region that wants them.
 */
/obj/structure/roguemachine/steward/proc/trade_with_region(mob/living/user, datum/rogue_trade_region/region, datum/rogue_trade_good/good, importing)
	if(!region || !good?.stock)
		return
	var/list/trade = importing ? region.produces : region.demands
	if(!trade[good.id])
		to_chat(user, span_warning("[region.name] does not [importing ? "produce" : "demand"] [good.name]."))
		return
	var/most = round(rogue_value("trade_region_trade_max"))
	if(!importing)
		most = min(most, good.stock.stockpile_amount)
	if(most < 1)
		to_chat(user, span_warning("The stockpile holds no [good.name]."))
		return
	var/units = tgui_input_number(user, "How many [good.name] to [importing ? "import from" : "export to"] [region.name]? (next unit [importing ? region.import_unit_cost(good) : region.export_unit_price(good)]m)", name, 1, most, 1)
	if(!units || !still_usable(user))
		return
	if(importing)
		var/spent = SSrogue_trade.region_import(region, good, units, user)
		if(spent)
			say("Rockhill imports [units] [good.name] from [region.name] for [spent] mammon.")
			playsound(src, ROGUE_SOUND_COIN_INSERT, 100, FALSE, -1)
	else
		var/gained = SSrogue_trade.region_export(region, good, units, user)
		if(gained)
			say("Rockhill exports [units] [good.name] to [region.name] for [gained] mammon.")
			playsound(src, ROGUE_SOUND_COIN_DISPENSE, 60, FALSE, -1)

/// The desk is still open and within reach after a prompt.
/obj/structure/roguemachine/steward/proc/still_usable(mob/living/user)
	return !locked && !QDELETED(src) && user.can_perform_action(src)
