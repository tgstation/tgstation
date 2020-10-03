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
	var/list/bank_accounts = list() //List of normal accounts (not department accounts)
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
	eng_payout()
	sci_payout()
	secmedsrv_payout()
	civ_payout()
	car_payout()
	station_total = 0
	station_target_buffer += STATION_TARGET_BUFFER
	for(var/account in bank_accounts)
		if(bank_account && bank_account.account_job)
			temporary_total += (bank_account.account_job.paycheck * STARTING_PAYCHECKS)
		if(!istype(bank_account, /datum/bank_account/department))
			station_total += bank_account.account_balance
	station_target = max(round(temporary_total / max(bank_accounts.len * 2, 1)) + station_target_buffer, 1)
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
  * How much does the engineering department make in passive income?
  * Payout used to be based on power generated, but power generated at batshit insane rates, so we'll just go with 1000 credits per supermatter on the map.
  */
/datum/controller/subsystem/economy/proc/eng_payout()
	///How much do we reward per supermatter on the map?
	var/cash_per_shard = 1000
	var/datum/bank_account/D = get_dep_account(ACCOUNT_ENG)
	if(D)
		for(var/obj/machinery/power/supermatter_crystal/temp in GLOB.machines)
			D.adjust_money(cash_per_shard)

/**
  * Cargo's natural income generation.
  * Naturally lower than all other departments because they LITERALLY print money.
  */
/datum/controller/subsystem/economy/proc/car_payout()
	var/cargo_cash = 500
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(cargo_cash)

/**
  * Payout based on crew safety, health, and mood.
  * Checks through the full list of living players, and obtains their mood. Mood increases departmental earnings.
  * Then, pays medical based on their percentage of total health, times the alive_human_bounty.
  * Finally, security is paid based on the number of living crew alive/total crew, multiplied by the crew_safety_bounty.
  */
/datum/controller/subsystem/economy/proc/secmedsrv_payout()
	var/crew
	var/alive_crew
	var/cash_to_grant
	for(var/mob/m in GLOB.mob_list)
		if(isnewplayer(m))
			continue
		if(m.mind)
			if(isbrain(m) || iscameramob(m))
				continue
			if(ishuman(m))
				var/mob/living/carbon/human/H = m
				crew++
				if(H.stat != DEAD)
					alive_crew++
					var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
					var/medical_cash = (H.health / H.maxHealth) * alive_humans_bounty
					if(mood)
						var/datum/bank_account/D = get_dep_account(ACCOUNT_SRV)
						if(D)
							var/mood_dosh = (mood.mood_level / 9) * mood_bounty
							D.adjust_money(mood_dosh)
						medical_cash *= (mood.sanity / 100)
					var/datum/bank_account/D = get_dep_account(ACCOUNT_MED)
					if(D)
						D.adjust_money(medical_cash)
		CHECK_TICK
	var/living_ratio = alive_crew / crew
	cash_to_grant = (crew_safety_bounty * living_ratio)
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SEC)
	if(D)
		D.adjust_money(min(cash_to_grant, MAX_GRANT_SECMEDSRV))

/**
  * Science is paid for the number of slimes living at a given time. Remind me to make this something less rudimentry when science has experiments. ~Arcane.
  */
/datum/controller/subsystem/economy/proc/sci_payout()
	var/science_bounty = 0
	for(var/mob/living/simple_animal/slime/S in GLOB.mob_list)
		if(S.stat == DEAD)
			continue
		science_bounty += slime_bounty[S.colour]
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SCI)
	if(D)
		D.adjust_money(min(science_bounty, MAX_GRANT_SCI))

/** Payout based on Effort and market ebb/flow.
  *	For every civilian bounty completed, they make 100 credits plus a random 500-1000.
  * Rewards participation towards the rest of the crew getting resources, as the control of this budget is the HOP.
  */
/datum/controller/subsystem/economy/proc/civ_payout()
	var/civ_cash = ((rand(1,2) * 500) + (civ_bounty_tracker * 100))
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CIV)
	if(D)
		D.adjust_money(civ_cash, MAX_GRANT_CIV)


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
	if(!bank_accounts.len)
		return 1
	inflation_value = max(round(((station_total / bank_accounts.len) / station_target), 0.1), 1.0)
	return inflation_value
