/// Ratwood's Crown fiscal officers (has_fiscal_authority()): they run the stockpile and the nerve master.
/proc/rogue_fiscal_authority(mob/user)
	return user?.mind?.assigned_role?.title in list(JOB_ROCKHILL_STEWARD, JOB_ROCKHILL_CLERK, JOB_ROCKHILL_GRAND_DUKE)

/**
 * The treasury of the realm on medieval maps (Ratwood code/controllers/subsystem/rogue/treasury.dm, SStreasury): the Crown's Purse
 * and the funds of the Church, the merchants, the bathhouse and the tavern; the NERVELOCK accounts of the subjects; the Crown's
 * levies and fines, the poll tax and the charters that bound them; loans and indentures; the dawn payouts (rural tax, estate
 * incomes, wages the Steward sets), the Burgher Pledge (burgher_pledge.dm) and the Crown's solvency; and the stockpile, which
 * the Crown tops up from the regions and whose surplus it ships to them every treasury tick (crown_imports.dm). The trade
 * regions live in trade.dm; Ratwood's rumors are not ported.
 */
SUBSYSTEM_DEF(rogue_treasury)
	name = "Treasury"
	wait = ROGUE_TREASURY_TICK
	runlevels = RUNLEVEL_GAME
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	/// The treasury of the realm (Ratwood discretionary_fund).
	var/datum/bank_account/rogue/crown/crown_purse
	/// Institution id -> its fund, the Crown's Purse included (Ratwood resolve_fund_by_id()).
	var/list/funds = list()
	/// Every NERVELOCK account opened this round.
	var/list/datum/bank_account/rogue/accounts = list()
	/// Levy name -> rate (Ratwood tax_rates).
	var/list/tax_rates = list(ROGUE_TAX_IMPORT = 0.15)
	/// The dawn the Steward last changed a levy; levies change once a day (Ratwood levy_rates_changed_day).
	var/levy_changed_dawn = -1
	/// Job title -> mammons paid at every dawn from the Crown's Purse (Ratwood daily_payments of the nerve master).
	var/list/daily_payments = list()
	/// Subjects fined since dawn; each may be fined once a day (Ratwood fined_today_names).
	var/list/fined_today = list()
	/// Every good of the stockpile.
	var/list/datum/roguestock/stockpile_datums = list()
	/// Below this the Crown buys nothing at the stockpile (Ratwood stockpile_purchase_floor).
	var/stockpile_purchase_floor = 1000
	/// Share of a good's limit the Crown keeps before it ships the surplus abroad; sequestration lowers it (Ratwood autoexport_percentage).
	var/autoexport_share = ROGUE_AUTOEXPORT_SHARE
	/// Mammons of goods the realm traded through the stockpile (Ratwood economic_output).
	var/economic_output = 0
	var/total_export = 0
	var/total_import = 0
	var/total_rural_tax = 0
	var/total_wages = 0
	var/total_tariff = 0
	var/total_fines = 0
	var/total_poll_tax = 0
	var/total_poll_subsidy = 0
	var/total_concordat_tithe = 0
	/// The Purse has had its share for the players present at round start.
	var/seeded_players = FALSE
	/// Wages were paid once at round start (Ratwood initial_payment_done).
	var/initial_wages_paid = FALSE
	/// Shares of mammons the Concordat owes the Church that did not yet make a whole coin (Ratwood concordat_tithe_debt).
	var/concordat_tithe_debt = 0

/datum/controller/subsystem/rogue_treasury/Initialize()
	if(!rogue_economy_enabled())
		can_fire = FALSE
		return SS_INIT_NO_NEED
	stockpile_purchase_floor = CONFIG_GET(number/rogue_stockpile_floor)
	tax_rates[ROGUE_TAX_IMPORT] = CONFIG_GET(number/rogue_import_tariff) / 100
	tax_rates[ROGUE_TAX_CONTRACT] = rogue_value("treasury_contract_levy") / 100
	auto_import_floor = round(rogue_value("trade_auto_import_purse_floor"))
	crown_purse = new("Crown's Purse")
	funds[ROGUE_FUND_CROWN] = crown_purse
	mint(crown_purse, CONFIG_GET(number/rogue_crown_purse) + rand(500, 1500), "Treasury of the realm")
	for(var/datum/bank_account/rogue/fund/fund_type as anything in subtypesof(/datum/bank_account/rogue/fund))
		var/datum/bank_account/rogue/fund/fund = new fund_type(initial(fund_type.account_holder))
		funds[fund.fund_id] = fund
		mint(fund, fund.founding_endowment(), "Founding endowment")
	for(var/datum/roguestock/stock_type as anything in subtypesof(/datum/roguestock/stockpile))
		if(initial(stock_type.item_type))
			stockpile_datums += new stock_type
	setup_poll_tax()
	setup_funds()
	setup_pledge()
	init_decrees()
	setup_default_payments()
	enforce_wage_floors()
	update_jawbanks()
	RegisterSignal(SSdcs, COMSIG_GLOB_ROCKHILL_TIME_OF_DAY, PROC_REF(on_time_of_day))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/rogue_treasury/stat_entry(msg)
	msg = "Purse: [crown_purse?.account_balance || 0]m, accounts: [length(accounts)], loans: [length(loans)]"
	return ..()

/datum/controller/subsystem/rogue_treasury/fire(resumed)
	if(!seeded_players)
		seeded_players = TRUE
		mint(crown_purse, length(GLOB.alive_player_list) * CONFIG_GET(number/rogue_crown_purse_per_player), "Treasury of the realm")
		setup_royal_custom()
	if(!initial_wages_paid)
		initial_wages_paid = TRUE
		evaluate_solvency()
		pay_wages()
	auto_export()
	run_auto_imports()
	check_royal_custom()
	update_jawbanks()

/// Ratwood's Rockhill wages (setup_default_payments() of the nerve master), mammons per dawn.
/datum/controller/subsystem/rogue_treasury/proc/setup_default_payments()
	daily_payments = list(
		JOB_ROCKHILL_KNIGHT_CAPTAIN = 40,
		JOB_ROCKHILL_KNIGHT = 40,
		JOB_ROCKHILL_MAN_AT_ARMS = 30,
		JOB_ROCKHILL_FOREST_WARDEN = 20,
		JOB_ROCKHILL_DUNGEONEER = 25,
		JOB_ROCKHILL_WATCH_CAPTAIN = 35,
		JOB_ROCKHILL_MASTER_WARDEN = 35,
		JOB_ROCKHILL_SERGEANT = 40,
		JOB_ROCKHILL_CITY_GUARD = 30,
		JOB_ROCKHILL_VANGUARD = 10,
		JOB_ROCKHILL_ROOKIE = 15,
		JOB_ROCKHILL_VETERAN = 20,
		JOB_ROCKHILL_SQUIRE = 10,
		JOB_ROCKHILL_HEAD_PHYSICIAN = 40,
		JOB_ROCKHILL_APOTHECARY = 15,
		JOB_ROCKHILL_COURT_MAGICIAN = 40,
		JOB_ROCKHILL_COURT_CHAPLAIN = 30,
		JOB_ROCKHILL_SENESCHAL = 40,
		JOB_ROCKHILL_SERVANT = 20,
		JOB_ROCKHILL_ARCHIVIST = 10,
		JOB_ROCKHILL_MAGICIANS_ASSOCIATE = 10,
		JOB_ROCKHILL_JESTER = 6,
	)

/// Sets a role's wage; while a charter floors it, it cannot go lower (Ratwood steward.dm, "Set daily payment"). Returns the wage set.
/datum/controller/subsystem/rogue_treasury/proc/set_wage(title, wage)
	wage = max(round(wage), wage_floor(title))
	if(wage > 0)
		daily_payments[title] = wage
	else
		daily_payments -= title
	return wage

/// Raises every wage a standing charter floors to that floor (Ratwood enforce_wage_floors()).
/datum/controller/subsystem/rogue_treasury/proc/enforce_wage_floors()
	for(var/title in wage_floored_titles())
		var/floor_wage = wage_floor(title)
		if(floor_wage > (daily_payments[title] || 0))
			daily_payments[title] = floor_wage

// Money. Mint creates mammons (coins melted into an account, taxes, estates), burn destroys them (coins paid out, imports),
// transfer moves them between accounts; all go through TG's adjust_money()/transfer_money() and their ledger.

/datum/controller/subsystem/rogue_treasury/proc/mint(datum/bank_account/account, amount, reason)
	amount = min(round(amount), ROGUE_TRANSFER_MAX)
	if(!account || amount <= 0)
		return FALSE
	if(!account.adjust_money(amount, reason))
		return FALSE
	on_income(account, amount)
	return TRUE

/datum/controller/subsystem/rogue_treasury/proc/burn(datum/bank_account/account, amount, reason)
	amount = round(amount)
	if(!account || amount <= 0)
		return FALSE
	return account.adjust_money(-amount, reason)

/datum/controller/subsystem/rogue_treasury/proc/transfer(datum/bank_account/payer, datum/bank_account/payee, amount, reason)
	amount = min(round(amount), ROGUE_TRANSFER_MAX)
	if(!payer || !payee || payer == payee || amount <= 0)
		return FALSE
	if(!payee.transfer_money(payer, amount, reason))
		return FALSE
	on_income(payee, amount)
	return TRUE

/**
 * Money came into an account. Income of the Crown's Purse first pays what the raiders cost on the held roads, then the Crown's
 * debt to the trading company (Ratwood skim_for_banditry_debt(), skim_for_treasury_debt()); income of a subject first pays the
 * poll tax they are behind on.
 */
/datum/controller/subsystem/rogue_treasury/proc/on_income(datum/bank_account/account, amount)
	if(account == crown_purse)
		skim_for_treasury_debt(skim_for_banditry_debt(amount))
		return
	var/datum/bank_account/rogue/subject = account
	if(istype(subject) && !subject.fund_id && subject.poll_owed > 0)
		collect_poll_arrears(subject)

/// The fund of an institution (Ratwood resolve_fund_by_id()).
/datum/controller/subsystem/rogue_treasury/proc/get_fund(fund_id)
	return funds[fund_id]

/datum/controller/subsystem/rogue_treasury/proc/get_account(mob/target)
	return target?.mind?.rogue_account

/datum/controller/subsystem/rogue_treasury/proc/get_balance(mob/target)
	var/datum/bank_account/rogue/account = get_account(target)
	return account ? account.account_balance : 0

/datum/controller/subsystem/rogue_treasury/proc/get_tax_rate(levy)
	return tax_rates[levy] || 0

/**
 * Opens the subject's NERVELOCK account (Ratwood create_bank_account()), with an endowment and an estate income if the role has
 * them; the estate pays at once, with Ratwood's starter bonus. Returns the account, or the one the subject already has.
 */
/datum/controller/subsystem/rogue_treasury/proc/open_account(mob/living/carbon/human/owner, deposit = 0, estate = 0)
	var/datum/mind/mind = owner?.mind
	if(!mind || !crown_purse)
		return null
	if(mind.rogue_account)
		return mind.rogue_account
	var/datum/bank_account/rogue/account = new(owner.real_name, mind.assigned_role)
	account.owner_mind = WEAKREF(mind)
	mind.rogue_account = account
	accounts += account
	if(deposit > 0)
		mint(account, deposit, "Initial endowment")
	if(estate > 0)
		account.estate_income = estate
		grant_estate_income(account, starter = TRUE)
	return account

/// Ratwood grant_estate_income(): the estate (the trading company, for a merchant) pays its holder; outlaws get nothing.
/datum/controller/subsystem/rogue_treasury/proc/grant_estate_income(datum/bank_account/rogue/account, starter = FALSE)
	var/mob/living/owner = account.owner()
	if(!account.estate_income || (owner && HAS_TRAIT(owner, TRAIT_OUTLAW)))
		return FALSE
	var/source = account.job_title() == JOB_ROCKHILL_MERCHANT ? "Ferentian Trading Company" : "Noble Estate"
	var/payout = account.estate_income + (starter ? ROGUE_ESTATE_STARTER_BONUS : 0)
	if(!mint(account, payout, source))
		return FALSE
	account.bank_card_talk("You received [payout]m. ([source])")
	return TRUE

/// Ratwood give_money_account(): the Crown pays a subject from the Purse.
/datum/controller/subsystem/rogue_treasury/proc/give_money(datum/bank_account/rogue/account, amount, reason)
	if(!account || !transfer(crown_purse, account, amount, reason))
		return FALSE
	account.bank_card_talk("You received [amount]m. ([reason])")
	log_game("CROWN GRANT: [key_name(usr)] granted [amount]m to [account.account_holder] via [reason]")
	return TRUE

/**
 * The most the Crown may fine a subject now (Ratwood get_max_fine_for() and get_daily_fine_remaining()): once a day, at most
 * a share of the balance, less for those a charter shields, nothing for those a charter exempts. Outlaws have no such limits.
 */
/datum/controller/subsystem/rogue_treasury/proc/max_fine(datum/bank_account/rogue/account)
	if(!account || account.account_balance <= 0)
		return 0
	var/mob/living/payer = account.owner()
	if(payer && HAS_TRAIT(payer, TRAIT_OUTLAW))
		return account.account_balance
	if(fined_today[account] || (payer && tax_exempt(payer)))
		return 0
	var/cap = ROGUE_FINE_RATE_CAP
	var/most_today = account.account_balance
	if(payer)
		for(var/id in decrees)
			var/datum/rogue_decree/decree = decrees[id]
			if(!decree.active)
				continue
			cap = decree.rate_cap(payer, cap)
			most_today = decree.fine_cap(payer, most_today)
	return max(0, min(floor(account.account_balance * cap), most_today))

/// Ratwood's fine: the Crown takes what the charters allow into the Purse, once a day per subject. Returns the mammons taken.
/datum/controller/subsystem/rogue_treasury/proc/fine(datum/bank_account/rogue/account, amount, reason)
	if(!account || amount <= 0)
		return 0
	amount = min(round(amount), max_fine(account))
	if(amount <= 0 || !transfer(account, crown_purse, amount, "Fine ([reason])"))
		return 0
	var/mob/living/payer = account.owner()
	if(!payer || !HAS_TRAIT(payer, TRAIT_OUTLAW))
		fined_today[account] = TRUE
	total_fines += amount
	account.bank_card_talk("You were fined [amount]m. ([reason])")
	log_game("FINE: [key_name(usr)] fined [account.account_holder] [amount]m via [reason]")
	return amount

/// A new day dawns on Rockhill. The dawn's business may proclaim things, so it runs outside the signal.
/datum/controller/subsystem/rogue_treasury/proc/on_time_of_day(datum/source, datum/rockhill_clock_step/phase/old_phase, datum/rockhill_clock_step/phase/new_phase)
	SIGNAL_HANDLER
	if(new_phase?.name != ROCKHILL_DAWN || !crown_purse)
		return
	INVOKE_ASYNC(src, PROC_REF(new_day))

/**
 * The Crown's business at dawn, in Ratwood's order (code/__HELPERS/time.dm settod()): the rural tax, the estates, the payroll
 * after the Crown checks it can meet it, the loans that fall due, the Burgher Pledge, then the poll tax.
 */
/datum/controller/subsystem/rogue_treasury/proc/new_day()
	fined_today.Cut()
	bathhouse_drawn.Cut()
	var/rural_tax = CONFIG_GET(number/rogue_rural_tax)
	if(mint(crown_purse, rural_tax, "Rural Tax Collection"))
		total_rural_tax += rural_tax
	for(var/datum/bank_account/rogue/account as anything in accounts)
		grant_estate_income(account)
	evaluate_solvency()
	pay_wages()
	tick_loans()
	tick_burgher_pledge()
	tick_poll_tax()

/// Mammons the day's wages will cost the Purse (Ratwood get_expected_wage_outlay()).
/datum/controller/subsystem/rogue_treasury/proc/expected_wage_outlay()
	var/total = 0
	for(var/datum/bank_account/rogue/account as anything in accounts)
		var/wage = daily_payments[account.job_title()]
		if(wage && !account.wages_suspended && account.owner())
			total += wage
	return total

/// Ratwood distribute_daily_payments(): every subject whose role has a wage is paid from the Purse while it has the money; under sequestration nobody is.
/datum/controller/subsystem/rogue_treasury/proc/pay_wages()
	if(treasury_state == ROGUE_TREASURY_SEQUESTERED)
		return
	for(var/datum/bank_account/rogue/account as anything in accounts)
		var/wage = daily_payments[account.job_title()]
		if(!wage || account.wages_suspended || !account.owner())
			continue
		if(!crown_purse.has_money(wage))
			account.bank_card_talk("The Crown's Purse cannot pay your wage today.")
			continue
		if(transfer(crown_purse, account, wage, "Daily Wage"))
			total_wages += wage
			account.bank_card_talk("You received [wage]m. (Daily Wage)")

/// The stockpile good this item is sold as: its exact good first, then any good it is a kind of (Ratwood's list order).
/datum/controller/subsystem/rogue_treasury/proc/stock_for(obj/item/thing)
	for(var/datum/roguestock/stock as anything in stockpile_datums)
		if(thing.type == stock.item_type)
			return stock.accepts(thing) ? stock : null
	for(var/datum/roguestock/stock as anything in stockpile_datums)
		if(stock.accepts(thing))
			return stock
	return null

/// The stockpile's imports of a treasury tick: the Crown's standing imports from the regions (Ratwood run_auto_import_tick(),
/// which replaced the passive import of goods from afar; crown_imports.dm). Kept under its old name for the economic panel.
/datum/controller/subsystem/rogue_treasury/proc/passive_import()
	run_auto_imports()

/**
 * Ratwood auto_export() and mass_export_surplus(): a good of the regions' trade kept above its share of the limit ships its
 * surplus to the region that pays best today, as much as that region still wants; a good the Steward priced by hand stays.
 * Other goods ship a load abroad at their export price. The Crown's Purse takes the price.
 */
/datum/controller/subsystem/rogue_treasury/proc/auto_export()
	for(var/datum/roguestock/stock as anything in stockpile_datums)
		if(stock.autoexport_disabled || stock.importexport_amt <= 0)
			continue
		var/datum/rogue_trade_good/good = stock.trade_good
		if(!good)
			if(stock.stockpile_amount > autoexport_share * stock.stockpile_limit && stock.stockpile_amount >= stock.importexport_amt)
				export_stock(stock, stock.importexport_amt)
			continue
		if(!stock.automatic_price)
			continue
		var/keep = round(autoexport_share * stock.stockpile_limit)
		if(auto_import_active(good.id))
			keep = max(keep, rogue_value("trade_auto_import_floor"))
		var/surplus = stock.stockpile_amount - keep
		var/list/quote = surplus > 0 ? SSrogue_trade.export_quote(good) : null
		if(!quote)
			continue
		var/datum/rogue_trade_region/region = quote["region"]
		var/wanted = region.demands_today[good.id] || 0
		if(wanted > 0)
			SSrogue_trade.region_export(region, good, min(surplus, wanted))

/// Ships units of a good abroad at its export price into the Crown's Purse (Ratwood do_export()).
/datum/controller/subsystem/rogue_treasury/proc/export_stock(datum/roguestock/stock, units)
	units = min(units, stock.stockpile_amount)
	if(units <= 0)
		return 0
	var/revenue = units * stock.export_price
	stock.stockpile_amount -= units
	mint(crown_purse, revenue, "Exported [units] [stock.name]")
	total_export += revenue
	economic_output += revenue
	return revenue

/// Changes a levy, once a day, and proclaims it (Ratwood apply_rate_adjustments()). The Concordat keeps every levy at its tithe or above.
/datum/controller/subsystem/rogue_treasury/proc/set_tax_rate(levy, percent, mob/user)
	if(!(levy in tax_rates))
		return FALSE
	if(levy_changed_dawn == ROGUE_TREASURY_DAY)
		to_chat(user, span_warning("Crown levies have already been adjusted today - come back tomorrow."))
		return FALSE
	if(decree_active(ROGUE_DECREE_MAGNA_CARTA))
		to_chat(user, span_warning("The Magna Carta stands: the Crown levies nothing while it is in force."))
		return FALSE
	var/old_percent = round(tax_rates[levy] * 100)
	percent = clamp(round(percent), 0, 100)
	var/tithe_percent = round(ROGUE_CONCORDAT_TITHE * 100)
	if(decree_active(ROGUE_DECREE_CONCORDAT) && percent < tithe_percent)
		to_chat(user, span_warning("The Concordat of Zenitstadt forbids any levy below [tithe_percent]% while in force - the Church's tithe must be honoured."))
		return FALSE
	if(percent == old_percent)
		return FALSE
	tax_rates[levy] = percent / 100
	levy_changed_dawn = ROGUE_TREASURY_DAY
	var/raised = percent > old_percent
	var/text = "The [levy] has been [raised ? "raised" : "reduced"] from [old_percent]% to [percent]%."
	if(decree_active(ROGUE_DECREE_CONCORDAT))
		text += " By the Concordat of Zenitstadt, [tithe_percent]% of every taxed transaction is tithed to the Church of the Ten, drawn from the Crown's share."
	priority_announce(text, raised ? "The Crown Demands More" : "The Crown Is Generous", ROGUE_SOUND_DECREE)
	log_game("TAX RATES: [key_name(user)] changed the [levy] from [old_percent]% to [percent]%")
	return TRUE

/**
 * Ratwood apply_concordat_tithe(): while the Zenitstadt Concordat stands, a share of every sale the Crown taxed goes from the
 * Purse to the Church Fund; fines are never tithed. Machines that collect a levy pass the sale it was taken on. Returns the tithe.
 */
/datum/controller/subsystem/rogue_treasury/proc/apply_concordat_tithe(base_amount, levy)
	var/datum/bank_account/rogue/church = funds[ROGUE_FUND_CHURCH]
	if(base_amount <= 0 || levy == ROGUE_TAX_FINE || !church || !decree_active(ROGUE_DECREE_CONCORDAT))
		return 0
	concordat_tithe_debt += base_amount * ROGUE_CONCORDAT_TITHE
	var/tithe = floor(concordat_tithe_debt)
	if(tithe <= 0 || !transfer(crown_purse, church, tithe, "Concordat tithe ([levy])"))
		return 0
	concordat_tithe_debt -= tithe
	total_concordat_tithe += tithe
	return tithe
