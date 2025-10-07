SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	runlevels = RUNLEVEL_GAME
	///How many paychecks should players start out the round with?
	var/roundstart_paychecks = 5
	///How many credits does the in-game economy have in circulation at round start? Divided up by 6 of the 7 department budgets evenly, where cargo starts with nothing.
	var/budget_pool = 35000
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/departmental_accounts = list()
	/**
	 * Enables extra money charges for things that normally would be free, such as sleepers/cryo/beepsky.
	 * Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	 */
	var/full_ancap = FALSE

	/// Departmental cash provided to science when a node is researched in specific configs.
	var/techweb_bounty = 250
	/**
	  * List of normal (no department ones) accounts' identifiers with associated datum accounts, for big O performance.
	  * A list of sole account datums can be obtained with flatten_list(), another variable would be redundant rn.
	  */
	var/list/bank_accounts_by_id = list()
	/// A list of bank accounts indexed by their assigned job typepath.
	var/list/bank_accounts_by_job = list()
	///List of the departmental budget cards in existence.
	var/list/dep_cards = list()
	/// A var that collects the total amount of credits owned in player accounts on station, reset and recounted on fire()
	var/station_total = 0
	/// A var that tracks how much money is expected to be on station at a given time. If less than station_total prices go up in vendors.
	var/station_target = 1
	/// A passively increasing buffer to help alliviate inflation later into the shift, but to a lesser degree.
	var/station_target_buffer = 0
	/// A var that displays the result of inflation_value for easier debugging and tracking.
	var/inflation_value = 1
	/// How many civilain bounties have been completed so far this shift? Affects civilian budget payout values.
	var/civ_bounty_tracker = 0
	/// Contains the message to send to newscasters about price inflation and earnings, updated on price_update()
	var/earning_report
	///The modifier multiplied to the value of bounties paid out.
	var/bounty_modifier = 1
	///The modifier multiplied to the value of cargo pack prices.
	var/pack_price_modifier = 1
	/**
	 * A list of strings containing a basic transaction history of purchases on the station.
	 * Added to any time when player accounts purchase something.
	 */
	var/list/audit_log = list()

	/// Number of mail items generated.
	var/mail_waiting = 0
	/// Mail Holiday: AKA does mail arrive today? Always blocked on Sundays.
	var/mail_blocked = FALSE
	/// List used to track partially completed processing steps
	/// Allows for proper yielding
	var/list/cached_processing
	/// Tracks what bit of processing we're on, so we can resume post yield in the right place
	var/processing_part
	/// Tracks a temporary sum of all money in the system
	/// We need this on the subsystem because of yielding and such
	var/temporary_total = 0
	/// Determines how many ticks it takes to restock mail
	var/ticks_per_mail = 2

/datum/controller/subsystem/economy/Initialize()
	//removes cargo from the split
	var/budget_to_hand_out = round(budget_pool / department_accounts.len -1)
	if(time2text(world.timeofday, "DDD") == SUNDAY)
		mail_blocked = TRUE
	for(var/dep_id in department_accounts)
		if(dep_id == ACCOUNT_CAR) //cargo starts with NOTHING
			new /datum/bank_account/department(dep_id, 0, player_account = FALSE)
			continue
		new /datum/bank_account/department(dep_id, budget_to_hand_out, player_account = FALSE)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/economy/Recover()
	departmental_accounts = SSeconomy.departmental_accounts
	bank_accounts_by_id = SSeconomy.bank_accounts_by_id
	dep_cards = SSeconomy.dep_cards

/// Processing step defines, to track what we've done so far
#define ECON_DEPARTMENT_STEP "econ_dpt_stp"
#define ECON_ACCOUNT_STEP "econ_act_stp"
#define ECON_PRICE_UPDATE_STEP "econ_prc_stp"

/datum/controller/subsystem/economy/fire(resumed = 0)
	var/seconds_per_tick = wait / (5 MINUTES)
	if(!resumed)
		temporary_total = 0
		processing_part = ECON_DEPARTMENT_STEP
		cached_processing = department_accounts.Copy()

	if(processing_part == ECON_DEPARTMENT_STEP)
		if(!departmental_payouts())
			return

		processing_part = ECON_ACCOUNT_STEP
		cached_processing = bank_accounts_by_id.Copy()
		station_total = 0
		station_target_buffer += STATION_TARGET_BUFFER

	if(processing_part == ECON_ACCOUNT_STEP)
		if(!issue_paydays())
			return

		processing_part = ECON_PRICE_UPDATE_STEP
		station_target = max(round(temporary_total / max(bank_accounts_by_id.len * 2, 1)) + station_target_buffer, 1)

	if(processing_part == ECON_PRICE_UPDATE_STEP)
		if(!HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING) && !price_update())
			return

	if(times_fired % ticks_per_mail == 0)
		var/effective_mailcount = round(living_player_count() / (inflation_value - 0.5)) //More mail at low inflation, and vis versa.
		mail_waiting += clamp(effective_mailcount, 1, ticks_per_mail * MAX_MAIL_PER_MINUTE * seconds_per_tick)

	SSstock_market.news_string = ""

/**
 * Handy proc for obtaining a department's bank account, given the department ID, AKA the define assigned for what department they're under.
 */
/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in departmental_accounts)
		if(D.department_id == dep_id)
			return D

/**
 * Departmental income payments are kept static and linear for every department, and paid out once every 5 minutes, as determined by MAX_GRANT_DPT.
 * Iterates over every department account for the same payment.
 */
/datum/controller/subsystem/economy/proc/departmental_payouts()
	// son sonic speed? cache? hot over in cold food why? (datum var accesses are slow, cache lists for sonic speed)
	var/list/cached_processing = src.cached_processing
	for(var/i in 1 to length(cached_processing))
		var/datum/bank_account/dept_account = get_dep_account(cached_processing[i])
		if(!dept_account)
			continue
		dept_account.adjust_money(MAX_GRANT_DPT)
		if(MC_TICK_CHECK)
			cached_processing.Cut(1, i + 1)
			return FALSE
	return TRUE

/**
 * Issues all our bank-accounts paydays, and gets an idea of how much money is in circulation
 */
/datum/controller/subsystem/economy/proc/issue_paydays()
	var/list/cached_processing = src.cached_processing
	for(var/i in 1 to length(cached_processing))
		var/datum/bank_account/bank_account = cached_processing[cached_processing[i]]
		if(bank_account?.account_job && !ispath(bank_account.account_job))
			temporary_total += (bank_account.account_job.paycheck * STARTING_PAYCHECKS)
		bank_account.payday(1, skippable = TRUE)
		station_total += bank_account.account_balance
		if(MC_TICK_CHECK)
			cached_processing.Cut(1, i + 1)
			return FALSE
	return TRUE

/**
 * Updates the the inflation_value, effecting newscaster alerts and the mail system.
 **/
/datum/controller/subsystem/economy/proc/price_update()
	var/fluff_string = ""
	if(!HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
		fluff_string = ", but company countermeasures protect <b>YOU</b> from being affected!"
	else
		fluff_string = ", and company countermeasures are failing to protect <b>YOU</b> from being affected. We're all doomed!"
	earning_report = "<b>Sector Economic Report</b><br><br> Sector vendor prices is currently at <b>[SSeconomy.inflation_value()*100]%</b>[fluff_string]<br><br> The station spending power is currently <b>[station_total] Credits</b>, and the crew's targeted allowance is at <b>[station_target] Credits</b>.<br><br>[SSstock_market.news_string]"
	var/update_alerts = FALSE
	if(HAS_TRAIT(SSstation, STATION_TRAIT_ECONOMY_ALERTS))
		var/datum/bank_account/moneybags
		var/static/list/typecache_bank = typecacheof(list(/datum/bank_account/department, /datum/bank_account/remote))
		for(var/i in bank_accounts_by_id)
			var/datum/bank_account/current_acc = bank_accounts_by_id[i]
			if(typecache_bank[current_acc.type])
				continue
			if(!moneybags || moneybags.account_balance < current_acc.account_balance)
				moneybags = current_acc
		if (moneybags)
			earning_report += "Our GMM Spotlight would like to alert you that <b>[moneybags.account_holder]</b> is your station's most affulent crewmate! They've hit it big with [moneybags.account_balance] credits saved. "
			update_alerts = TRUE
			inflict_moneybags(moneybags)
	earning_report += "That's all from the <i>Nanotrasen Economist Division</i>."
	GLOB.news_network.submit_article(earning_report, "Station Earnings Report", NEWSCASTER_STATION_ANNOUNCEMENTS, null, update_alert = update_alerts)
	return TRUE

/**
 * Proc that returns a value meant to shift inflation values in vendors, based on how much money exists on the station.
 *
 * If crew are somehow aquiring far too much money, this value will dynamically cause vendables across the station to skyrocket in price until some money is spent.
 * Additionally, civilain bounties will cost less, and cargo goodies will increase in price as well.
 * The goal here is that if you want to spend money, you'll have to get it, and the most efficient method is typically from other players.
 **/
/datum/controller/subsystem/economy/proc/inflation_value()
	if(!bank_accounts_by_id.len)
		return 1
	if(HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
		return inflation_value //early return instead of the actual check
	inflation_value = max(round(((station_total / bank_accounts_by_id.len) / station_target), 0.1), 1.0)
	return inflation_value

/**
 * Proc that adds a set of strings and ints to the audit log, tracked by the economy SS.
 *
 * * account: The bank account of the person purchasing the item.
 * * price_to_use: The cost of the purchase made for this transaction.
 * * vendor: The object or structure medium that is charging the user. For Vending machines that's the machine, for payment component that's the parent, cargo that's the crate, etc.
 */
/datum/controller/subsystem/economy/proc/add_audit_entry(datum/bank_account/account, price_to_use, vendor)
	if(isnull(account) || isnull(price_to_use) || !vendor)
		CRASH("Track purchases was missing an argument! (Account, Price, or Vendor.)")

	audit_log += list(list(
		"account" = "[account.account_holder]",
		"cost" = price_to_use,
		"vendor" = "[vendor]",
		"stationtime" = station_time_timestamp("hh:mm"),
	))

/**
 * Iterates over the machines list for vending machines, resets their regular and premium product prices (Not contraband), and sends a message to the newscaster network.
 */
/datum/controller/subsystem/economy/proc/update_vending_prices()
	var/list/obj/machinery/vending/prices_to_update = list()
	// Assoc list of "z level" -> if it's on the station
	// Hack, is station z level is too expensive to do for each machine, I hate this place
	var/list/station_z_status = list()
	for(var/obj/machinery/vending/vending_lad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/vending))
		if(istype(vending_lad, /obj/machinery/vending/custom))
			continue
		var/vending_level = vending_lad.z
		var/station_status = station_z_status["[vending_level]"]
		if(station_status == null)
			station_status = is_station_level(vending_level)
			station_z_status["[vending_level]"] = station_status
		if(!station_status)
			continue
		prices_to_update += vending_lad
	for(var/i in 1 to length(prices_to_update))
		var/obj/machinery/vending/vending = prices_to_update[i]
		vending.reset_prices(vending.product_records, vending.coin_records + vending.hidden_records)

/**
 * Reassign the prices of the vending machine as a result of the inflation value, as provided by SSeconomy
 *
 * This rebuilds both /datum/data/vending_products lists for premium and standard products based on their most relevant pricing values.
 * Arguments:
 * * recordlist - the list of standard product datums in the vendor to refresh their prices.
 * * premiumlist - the list of premium product datums in the vendor to refresh their prices.
 */
/obj/machinery/vending/proc/reset_prices(list/recordlist, list/premiumlist)
	var/inflation_value = HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING) ? SSeconomy.inflation_value() : 1
	default_price = round(initial(default_price) * inflation_value)
	extra_price = round(initial(extra_price) * inflation_value)

	for(var/datum/data/vending_product/record as anything in recordlist)
		var/obj/item/potential_product = record.product_path
		var/custom_price = round(initial(potential_product.custom_price) * inflation_value)
		record.price = custom_price | default_price
	for(var/datum/data/vending_product/premium_record as anything in premiumlist)
		var/obj/item/potential_product = premium_record.product_path
		var/premium_custom_price = round(initial(potential_product.custom_premium_price) * inflation_value)
		var/custom_price = initial(potential_product.custom_price)
		if(!premium_custom_price && custom_price) //For some ungodly reason, some premium only items only have a custom_price
			premium_record.price = extra_price + round(custom_price * inflation_value)
		else
			premium_record.price = premium_custom_price || extra_price

/datum/controller/subsystem/economy/proc/inflict_moneybags(datum/bank_account/moneybags)
	if(!moneybags)
		return FALSE
	var/mob/living/card_holder
	for(var/obj/card in moneybags?.bank_cards)
		if(isidcard(card))
			card_holder = recursive_loc_check(card, /mob/living)
	if(!isliving(card_holder)) //If on a living mob
		return FALSE
	card_holder.adjust_timed_status_effect(wait, /datum/status_effect/spotlight_light)
	return TRUE

#undef ECON_DEPARTMENT_STEP
#undef ECON_ACCOUNT_STEP
#undef ECON_PRICE_UPDATE_STEP
