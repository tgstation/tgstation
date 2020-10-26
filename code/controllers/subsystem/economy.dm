SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME
	var/roundstart_paychecks = 5
	var/budget_pool = 35000
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/generated_accounts = list()
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	var/alive_humans_bounty = 50
	var/crew_safety_bounty = 1500
	var/monster_bounty = 150
	var/mood_bounty = 100
	var/techweb_bounty = 250
	var/civ_bounty_value = 25
	var/slime_bounty = list("grey" = 1,
							// tier 1
							"orange" = 10,
							"metal" = 10,
							"blue" = 10,
							"purple" = 10,
							// tier 2
							"dark purple" = 50,
							"dark blue" = 50,
							"green" = 50,
							"silver" = 50,
							"gold" = 50,
							"yellow" = 50,
							"red" = 50,
							"pink" = 50,
							// tier 3
							"cerulean" = 75,
							"sepia" = 75,
							"bluespace" = 75,
							"pyrite" = 75,
							"light pink" = 75,
							"oil" = 75,
							"adamantine" = 75,
							// tier 4
							"rainbow" = 100)
	/**
	  * List of normal (no department ones) accounts' identifiers with associated datum accounts, for big O performance.
	  * A list of sole account datums can be obtained with flatten_list(), another variable would be redundant rn.
	  */
	var/list/bank_accounts_by_id = list()
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
	var/market_crashing = FALSE

/datum/controller/subsystem/economy/Initialize(timeofday)
	var/budget_to_hand_out = round(budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		new /datum/bank_account/department(A, budget_to_hand_out)
	return ..()

/datum/controller/subsystem/economy/fire(resumed = 0)
	var/temporary_total = 0
	departmental_payouts()
	station_total = 0
	station_target_buffer += STATION_TARGET_BUFFER
	for(var/account in bank_accounts_by_id)
		var/datum/bank_account/bank_account = bank_accounts_by_id[account]
		if(bank_account?.account_job)
			temporary_total += (bank_account.account_job.paycheck * STARTING_PAYCHECKS)
		if(!istype(bank_account, /datum/bank_account/department))
			station_total += bank_account.account_balance
	station_target = max(round(temporary_total / max(bank_accounts_by_id.len * 2, 1)) + station_target_buffer, 1)
	if(!market_crashing)
		price_update()

/**
  * Handy proc for obtaining a department's bank account, given the department ID, AKA the define assigned for what department they're under.
  */
/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/**
  * Departmental income payments are kept static and linear for every department, and paid out once every 5 minutes, as determined by MAX_GRANT_DPT.
  * Iterates over every department account for the same payment.
  */
/datum/controller/subsystem/economy/proc/departmental_payouts()
	var/datum/bank_account/engine = get_dep_account(ACCOUNT_ENG)
	var/datum/bank_account/cargo = get_dep_account(ACCOUNT_CAR)
	var/datum/bank_account/service = get_dep_account(ACCOUNT_SRV)
	var/datum/bank_account/medical = get_dep_account(ACCOUNT_MED)
	var/datum/bank_account/security = get_dep_account(ACCOUNT_SEC)
	var/datum/bank_account/science = get_dep_account(ACCOUNT_SCI)
	var/datum/bank_account/civilian = get_dep_account(ACCOUNT_CIV)
	if(engine)
		engine.adjust_money(MAX_GRANT_DPT)
	if(cargo)
		cargo.adjust_money(MAX_GRANT_DPT)
	if(service)
		service.adjust_money(MAX_GRANT_DPT)
	if(medical)
		medical.adjust_money(MAX_GRANT_DPT)
	if(security)
		security.adjust_money(MAX_GRANT_DPT)
	if(science)
		science.adjust_money(MAX_GRANT_DPT)
	if(civilian)
		civilian.adjust_money(MAX_GRANT_DPT)

/**
  * Updates the prices of all station vendors with the inflation_value, increasing/decreasing costs across the station, and alerts the crew.
  *
  * Iterates over the machines list for vending machines, resets their regular and premium product prices (Not contraband), and sends a message to the newscaster network.
  **/
/datum/controller/subsystem/economy/proc/price_update()
	for(var/obj/machinery/vending/V in GLOB.machines)
		if(istype(V, /obj/machinery/vending/custom))
			continue
		if(!is_station_level(V.z))
			continue
		V.reset_prices(V.product_records, V.coin_records)
	earning_report = "Sector Economic Report<br /> Sector vendor prices is currently at [SSeconomy.inflation_value()*100]%.<br /> The station spending power is currently <b>[station_total] Credits</b>, and the crew's targeted allowance is at <b>[station_target] Credits</b>.<br /> That's all from the <i>Nanotrasen Economist Division</i>."
	GLOB.news_network.SubmitArticle(earning_report, "Station Earnings Report", "Station Announcements", null, update_alert = FALSE)

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
	inflation_value = max(round(((station_total / bank_accounts_by_id.len) / station_target), 0.1), 1.0)
	return inflation_value
