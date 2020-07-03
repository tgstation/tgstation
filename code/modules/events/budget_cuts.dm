/datum/round_event_control/market_crash
	name = "Market Crash"
	typepath = /datum/round_event/market_crash
	weight = 10

/datum/round_event/market_crash
	var/market_dip = 0

/datum/round_event/market_crash/setup()
	startWhen = 2
	endWhen = startWhen + 1
	announceWhen = 1

/datum/round_event/market_crash/announce(fake)
	var/list/poss_reasons = list("The Alignment of the Moon and the Sun", "some risky housing market outcomes", "The B.E.P.I.S. team's untimely downfall", "speculative Terragov grants")
	var/reason = pick(poss_reasons)
	priority_announce("Based on [reason], prices for on-station vendors will be increased for a short period.", "Nanotrasen Accounting Division")

/datum/round_event/market_crash/start()
	var/num_accounts = 0
	for(var/A in SSeconomy.bank_accounts)
		num_accounts += 1
	market_dip = rand(100,1000) * num_accounts
	SSeconomy.station_target -= market_dip
	SSeconomy.station_target = min(SSeconomy.station_target, 0)

/datum/round_event/market_crash/end()
	. = ..()
	SSeconomy.station_target += market_dip
	priority_announce("Prices for on-station vendors have now stabilized.", "Nanotrasen Accounting Division")

