/**
 * Economic Panel (Ratwood code/modules/admin/verbs/economic_panel.dm) in Rogue Systems: the admin's view of the realm's money
 * on medieval maps. The treasury - the Crown's Purse and the institutions' funds, the levies, the wages, solvency and the
 * Crown's ledger - with minting and burning, levies set at once, and every dawn business fired by hand; the subjects' accounts
 * with their poll tax, advances, loans and wages; the charters; the goods of the stockpile with their categories, stock and
 * prices; the trade goods' prices; and the ships offshore. Ratwood's blockades, City Assembly, foreign pools and pricing
 * engine audits belong to systems not ported here.
 */
ADMIN_VERB(rogue_economic_panel, R_ADMIN, "Economic Panel", "Inspect and edit the treasury, the funds, the accounts, the charters, the prices and the goods.", ADMIN_CATEGORY_ROGUE)
	if(!rogue_economy_enabled() || !SSrogue_treasury.crown_purse)
		to_chat(user, span_warning("The money of the realm runs only on medieval maps."), confidential = TRUE)
		return
	GLOB.rogue_economic_panel.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Economic Panel")

GLOBAL_DATUM_INIT(rogue_economic_panel, /datum/rogue_economic_panel, new)

/datum/rogue_economic_panel

/datum/rogue_economic_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/rogue_economic_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RogueEconomicPanel", "Economic Panel")
		ui.open()

/// Ratwood admin_log_fiscal(): every change is logged and told to the admins.
/datum/rogue_economic_panel/proc/log_fiscal(mob/user, detail)
	log_admin("[key_name(user)] [detail]")
	message_admins(span_adminnotice("[key_name_admin(user)] [detail]."))

/datum/rogue_economic_panel/ui_data(mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/list/data = list()
	data["day"] = ROGUE_TREASURY_DAY
	data["state"] = rogue_treasury_state_label(treasury.treasury_state)
	data["debt"] = treasury.treasury_debt
	data["bankruptcies"] = treasury.bankruptcy_count
	data["floor"] = treasury.stockpile_purchase_floor
	data["autoexport"] = round(treasury.autoexport_share * 100)
	data["wage_outlay"] = treasury.expected_wage_outlay()
	data["hoard_paid"] = SSrogue_hoard.total_paid
	data["totals"] = list(
		"Economic output" = treasury.economic_output,
		"Exports" = treasury.total_export,
		"Imports" = treasury.total_import,
		"Rural tax" = treasury.total_rural_tax,
		"Wages" = treasury.total_wages,
		"Import tariff" = treasury.total_tariff,
		"Fines" = treasury.total_fines,
		"Poll tax" = treasury.total_poll_tax,
		"Poll subsidies" = treasury.total_poll_subsidy,
		"Concordat tithe" = treasury.total_concordat_tithe,
		"Export duty" = SSrogue_trade.total_export_duty,
		"Ship sales" = SSrogue_trade.total_ship_sales,
	)
	var/list/funds = list()
	for(var/fund_id in treasury.funds)
		var/datum/bank_account/rogue/fund = treasury.funds[fund_id]
		funds += list(list("id" = fund_id, "name" = fund.account_holder, "balance" = fund.account_balance))
	data["funds"] = funds
	var/list/levies = list()
	for(var/levy in treasury.tax_rates)
		levies += list(list("name" = levy, "percent" = round(treasury.tax_rates[levy] * 100)))
	data["levies"] = levies
	var/list/wages = list()
	for(var/title in treasury.daily_payments)
		wages += list(list("job" = title, "wage" = treasury.daily_payments[title]))
	data["wages"] = wages
	var/list/accounts = list()
	for(var/datum/bank_account/rogue/account as anything in treasury.accounts)
		var/mob/living/owner = account.owner()
		var/datum/rogue_loan/loan = treasury.loan_for(account)
		accounts += list(list(
			"ref" = REF(account),
			"name" = account.account_holder,
			"job" = account.job_title() || "",
			"alive" = owner && owner.stat != DEAD,
			"poll_class" = owner ? (treasury.poll_class(owner) || "untaxed") : "absent",
			"balance" = account.account_balance,
			"estate" = account.estate_income,
			"poll_owed" = account.poll_owed,
			"advance" = account.poll_advance_days,
			"wages_suspended" = account.wages_suspended,
			"loan" = loan ? loan.remaining_due() : 0,
			"defaulted" = loan?.defaulted || FALSE,
		))
	data["accounts"] = accounts
	var/list/charters = list()
	for(var/id in treasury.decrees)
		var/datum/rogue_decree/decree = treasury.decrees[id]
		charters += list(list("id" = id, "name" = decree.name, "active" = decree.active, "suspended" = decree.bankruptcy_suspended))
	data["charters"] = charters
	var/list/stock = list()
	var/list/categories = list()
	for(var/datum/roguestock/entry as anything in treasury.stockpile_datums)
		categories |= entry.category
		stock += list(list(
			"ref" = REF(entry),
			"name" = entry.name,
			"category" = entry.category,
			"amount" = entry.stockpile_amount,
			"limit" = entry.stockpile_limit,
			"base_price" = entry.base_price || 0,
			"payout" = entry.payout_price,
			"withdraw" = entry.withdraw_price,
			"export" = entry.export_price,
			"passive" = entry.passive_generation,
			"accepting" = entry.accept_toggle_enabled,
			"autoexport" = !entry.autoexport_disabled,
		))
	data["stock"] = stock
	data["stock_categories"] = categories
	var/list/goods = list()
	for(var/id in SSrogue_trade.goods)
		var/datum/rogue_trade_good/good = SSrogue_trade.goods[id]
		goods += list(list("id" = id, "name" = good.name, "base_price" = good.base_price, "mod" = good.global_price_mod, "stocked" = !!good.stock))
	data["goods"] = goods
	data["ships"] = length(SSrogue_trade.ships)
	data["hails"] = SSrogue_trade.hails_left
	data["orders"] = length(SSrogue_trade.orders)
	data["ledger"] = rogue_ledger(treasury.crown_purse)
	return data

/datum/rogue_economic_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !check_rights(R_ADMIN))
		return
	var/mob/user = ui.user
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	var/amount = text2num(params["amount"])
	switch(action)
		if("mint_fund", "burn_fund")
			var/datum/bank_account/rogue/fund = treasury.get_fund(params["id"])
			if(!fund || !isnum(amount) || amount <= 0)
				return TRUE
			if(action == "mint_fund" ? treasury.mint(fund, amount, "Divine Intervention") : treasury.burn(fund, min(amount, fund.account_balance), "Lost in Transit"))
				log_fiscal(user, "[action == "mint_fund" ? "minted [amount]m into" : "burned [amount]m from"] [fund.account_holder]")
		if("mint_account", "burn_account")
			var/datum/bank_account/rogue/account = locate(params["ref"]) in treasury.accounts
			if(!account || !isnum(amount) || amount <= 0)
				return TRUE
			if(action == "mint_account" ? treasury.mint(account, amount, "Divine Intervention") : treasury.burn(account, min(amount, account.account_balance), "Lost in Transit"))
				log_fiscal(user, "[action == "mint_account" ? "minted [amount]m to" : "burned [amount]m from"] [account.account_holder]")
		if("clear_debt")
			var/datum/bank_account/rogue/account = locate(params["ref"]) in treasury.accounts
			if(account)
				treasury.clear_poll_arrears(account)
				log_fiscal(user, "cleared the poll tax debt of [account.account_holder]")
		if("advance")
			var/datum/bank_account/rogue/account = locate(params["ref"]) in treasury.accounts
			if(account && isnum(amount))
				account.poll_advance_days = max(0, account.poll_advance_days + round(amount))
				log_fiscal(user, "set the poll tax advance of [account.account_holder] to [account.poll_advance_days] days")
		if("toggle_wages")
			var/datum/bank_account/rogue/account = locate(params["ref"]) in treasury.accounts
			if(account)
				account.wages_suspended = !account.wages_suspended
				log_fiscal(user, "[account.wages_suspended ? "suspended" : "restored"] the wages of [account.account_holder]")
		if("set_levy")
			var/levy = params["name"]
			if((levy in treasury.tax_rates) && isnum(amount))
				treasury.tax_rates[levy] = clamp(round(amount), 0, 100) / 100
				log_fiscal(user, "set the [levy] to [round(treasury.tax_rates[levy] * 100)]%")
		if("set_wage")
			var/title = params["job"]
			if(title && isnum(amount))
				log_fiscal(user, "set the wage of [title] to [treasury.set_wage(title, amount)]m")
		if("set_floor")
			if(isnum(amount))
				treasury.stockpile_purchase_floor = max(0, round(amount))
				log_fiscal(user, "set the stockpile purchase floor to [treasury.stockpile_purchase_floor]m")
		if("toggle_charter")
			var/datum/rogue_decree/decree = treasury.decrees[params["id"]]
			if(decree?.set_state(!decree.active))
				log_fiscal(user, "[decree.active ? "restored" : "revoked"] the charter [decree.name]")
		if("advance_day")
			GLOB.rockhill_dawns++
			treasury.new_day()
			SSrogue_trade.new_day()
			log_fiscal(user, "advanced the realm's day to [ROGUE_TREASURY_DAY] (full dawn business)")
		if("fire")
			fire_tick(params["tick"], user)
		if("force_arrears")
			if(treasury.enter_arrears(treasury.expected_wage_outlay()))
				log_fiscal(user, "forced the Crown into arrears")
		if("force_sequestration")
			if(treasury.enter_sequestration())
				log_fiscal(user, "forced the Crown into sequestration")
		if("force_recovery")
			if(treasury.treasury_state != ROGUE_TREASURY_SOLVENT || treasury.treasury_debt > 0)
				treasury.treasury_debt = 0
				treasury.clear_treasury_debt_state()
				log_fiscal(user, "cleared the Crown's debt and restored solvency")
		if("set_stock")
			var/datum/roguestock/entry = locate(params["ref"]) in treasury.stockpile_datums
			if(entry)
				set_stock(entry, params["field"], params["value"], user)
		if("set_good")
			var/datum/rogue_trade_good/good = SSrogue_trade.goods[params["id"]]
			if(good && isnum(amount) && amount > 0)
				if(params["field"] == "mod")
					good.global_price_mod = round(amount, 0.01)
				else
					good.base_price = round(amount)
				good.stock?.set_prices(good.base_price * good.global_price_mod)
				log_fiscal(user, "set the trade price of [good.name] to [good.base_price]m x[good.global_price_mod]")
		if("reroll_ships")
			SSrogue_trade.expire_offshore_ships()
			SSrogue_trade.roll_ships()
			log_fiscal(user, "rerolled the ships offshore")
		if("clear_ships")
			for(var/datum/rogue_trade_ship/ship as anything in SSrogue_trade.ships.Copy())
				SSrogue_trade.ships -= ship
				qdel(ship)
			log_fiscal(user, "cleared every trade ship")
		if("refill_hails")
			SSrogue_trade.hails_left = rogue_value("trade_hails_per_day")
			log_fiscal(user, "refilled the merchant's hails")
	return TRUE

/// One piece of the dawn business, fired by hand (Ratwood fire_*_tick).
/datum/rogue_economic_panel/proc/fire_tick(tick, mob/user)
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	switch(tick)
		if("rural")
			var/rural_tax = CONFIG_GET(number/rogue_rural_tax)
			if(treasury.mint(treasury.crown_purse, rural_tax, "Rural Tax Collection"))
				treasury.total_rural_tax += rural_tax
		if("estates")
			for(var/datum/bank_account/rogue/account as anything in treasury.accounts)
				treasury.grant_estate_income(account)
		if("payroll")
			treasury.evaluate_solvency()
			treasury.pay_wages()
		if("loans")
			treasury.tick_loans()
		if("poll")
			treasury.tick_poll_tax()
		if("stockpile")
			treasury.passive_import()
			treasury.auto_export()
		if("trade")
			SSrogue_trade.new_day()
		if("hoard")
			SSrogue_hoard.pay_interest()
		else
			return
	log_fiscal(user, "fired the [tick] tick")

/datum/rogue_economic_panel/proc/set_stock(datum/roguestock/entry, field, value, mob/user)
	var/number = text2num(value)
	switch(field)
		if("category")
			var/category = trim(copytext_char(sanitize(value), 1, MAX_NAME_LEN))
			if(!category)
				return
			entry.category = category
		if("amount")
			if(!isnum(number))
				return
			entry.stockpile_amount = max(0, round(number))
		if("limit")
			if(!isnum(number))
				return
			entry.stockpile_limit = max(0, round(number))
		if("base_price")
			if(!isnum(number) || number <= 0)
				return
			entry.base_price = round(number)
			entry.set_prices(entry.base_price)
		if("payout")
			if(!isnum(number) || number < 0)
				return
			entry.payout_price = round(number)
		if("withdraw")
			if(!isnum(number) || number < 0)
				return
			entry.withdraw_price = round(number)
		if("export")
			if(!isnum(number) || number < 0)
				return
			entry.export_price = round(number)
		if("passive")
			if(!isnum(number))
				return
			entry.passive_generation = max(0, round(number))
		if("accepting")
			entry.accept_toggle_enabled = !entry.accept_toggle_enabled
		if("autoexport")
			entry.autoexport_disabled = !entry.autoexport_disabled
		else
			return
	log_fiscal(user, "set [field] of the stockpile's [entry.name] ([entry.category]) - now [entry.stockpile_amount]/[entry.stockpile_limit], [entry.payout_price]/[entry.withdraw_price]/[entry.export_price]m")
