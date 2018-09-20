SUBSYSTEM_DEF(goldmansachs)
	name = "Economy"
	flags = SS_NO_INIT
	var/paycheck_interval = 5 MINUTES
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
	var/datum/station_state/engineering_check = new /datum/station_state()
	var/alive_humans_bounty = 100
	var/crew_safety_bounty = 1500
	var/monster_bounty = 150
	var/mood_bounty = 100
	var/techweb_bounty = 250
	var/slime_bounty = list("grey" = 10,
							// tier 1
							"orange" = 100,
							"metal" = 100,
							"blue" = 100,
							"purple" = 100,
							// tier 2
							"dark purple" = 500,
							"dark blue" = 500,
							"green" = 500,
							"silver" = 500,
							"gold" = 500,
							"yellow" = 500,
							"red" = 500,
							"pink" = 500,
							// tier 3
							"cerulean" = 750,
							"sepia" = 750,
							"bluespace" = 750,
							"pyrite" = 750,
							"light pink" = 750,
							"oil" = 750,
							"adamantine" = 750,
							// tier 4
							"rainbow" = 1000)

/datum/controller/subsystem/goldmansachs/fire(resumed = 0)
	var/budget_to_hand_out = round(budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		var/datum/bank_account/department/D = new /datum/bank_account/department(src)
		D.department_id = A
		D.account_holder = department_accounts[A]
		D.account_balance = budget_to_hand_out
		generated_accounts += D
	for(var/A in GLOB.dep_cards)
		var/obj/item/card/id/departmental_budget/C = A
		var/datum/bank_account/B = get_dep_account(C.department_ID)
		if(B)
			C.registered_account = B
			if(!B.bank_cards.Find(C))
				B.bank_cards += C
			C.name = "departmental card ([C.department_name])"
			C.desc = "Provides access to the [C.department_name]."
	addtimer(CALLBACK(src, .proc/its_payday_fellas), paycheck_interval)
	flags |= SS_NO_FIRE


/datum/controller/subsystem/goldmansachs/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/datum/controller/subsystem/goldmansachs/proc/its_payday_fellas()
	boring_eng_payout()
	boring_sci_payout()
	boring_secmedsrv_payout()
	boring_civ_payout()
	for(var/A in GLOB.bank_accounts)
		var/datum/bank_account/B = A
		B.i_need_my_payday_too(1)
	addtimer(CALLBACK(src, .proc/its_payday_fellas), paycheck_interval)

/datum/controller/subsystem/goldmansachs/proc/boring_eng_payout()
	var/engineering_cash = 3000
	engineering_check.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(engineering_check)), 100)
	station_integrity *= 0.01
	engineering_cash *= station_integrity
	var/datum/bank_account/D = get_dep_account(ACCOUNT_ENG)
	if(D)
		D.adjust_money(engineering_cash)

/datum/controller/subsystem/goldmansachs/proc/boring_secmedsrv_payout()
	var/crew
	var/alive_crew
	var/dead_monsters
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
					GET_COMPONENT_FROM(mood, /datum/component/mood, H)
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
		if(ishostile(m))
			var/mob/living/simple_animal/hostile/H = m
			if(H.stat == DEAD && H.z in SSmapping.levels_by_trait(ZTRAIT_STATION))
				dead_monsters++
		CHECK_TICK
	var/fuck = alive_crew / crew
	cash_to_grant = (crew_safety_bounty * fuck) + (monster_bounty * dead_monsters)
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SEC)
	if(D)
		D.adjust_money(cash_to_grant)

/datum/controller/subsystem/goldmansachs/proc/boring_sci_payout()
	var/science_bounty = 0
	for(var/mob/living/simple_animal/slime/S in GLOB.mob_list)
		if(S.stat == DEAD)
			continue
		science_bounty += slime_bounty[S.colour]
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SCI)
	if(D)
		D.adjust_money(science_bounty)

/datum/controller/subsystem/goldmansachs/proc/boring_civ_payout()
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CIV)
	if(D)
		D.adjust_money((rand(1,5) * 500))