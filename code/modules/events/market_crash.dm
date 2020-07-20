/**
  * An event which decreases the station target temporarily, causing the inflation var to increase heavily.
  *
  * Done by decreasing the station_target by a high value per crew member, resulting in the station total being much higher than the target, and causing artificial inflation.
  */
/datum/round_event_control/market_crash
	name = "Market Crash"
	typepath = /datum/round_event/market_crash
	weight = 10

/datum/round_event/market_crash
	var/market_dip = 0

/datum/round_event/market_crash/setup()
	startWhen = 1
	endWhen = rand(25, 50)
	announceWhen = 2

/datum/round_event/market_crash/announce(fake)
	var/list/poss_reasons = list("the alignment of the moon and the sun",\
		"some risky housing market outcomes",\
		"The B.E.P.I.S. team's untimely downfall",\
		"speculative Terragov grants backfiring",\
		"greatly exaggerated reports of Nanotrasen accountancy personnel committing mass suicide")
	var/reason = pick(poss_reasons)
	priority_announce("Due to [reason], prices for on-station vendors will be increased for a short period.", "Nanotrasen Accounting Division")

///This does not work and I could use some help morking this one out further.
/datum/round_event/market_crash/start()
	. = ..()
	var/num_accounts = 0
	for(var/A in SSeconomy.bank_accounts)
		num_accounts += 1
	market_dip = rand(1000,10000) * num_accounts
	SSeconomy.station_target -= market_dip
	SSeconomy.station_target = max(SSeconomy.station_target, 1)
	SSeconomy.price_update()

/datum/round_event/market_crash/end()
	. = ..()
	SSeconomy.station_target += market_dip
	SSeconomy.price_update()
	priority_announce("Prices for on-station vendors have now stabilized.", "Nanotrasen Accounting Division")
