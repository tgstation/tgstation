

/datum/round_event_control/shuttle_insurance
	name = "Shuttle Insurance"
	typepath = /datum/round_event/shuttle_insurance
	weight = 200 //you're basically bound to get it
	max_occurrences = 1

/datum/round_event_control/shuttle_insurance/canSpawnEvent(players, gamemode)
	if(!SSeconomy.get_dep_account(ACCOUNT_CAR))
		return FALSE //They can't pay?
	if(SSshuttle.shuttle_purchased != SHUTTLEPURCHASE_FORCED)
		return FALSE //don't do it if there's nothing to insure
	if(EMERGENCY_AT_LEAST_DOCKED)
		return FALSE //catastrophes won't trigger so no point
	return ..()

/datum/round_event/shuttle_insurance
	var/ship_name = "\"In the Unlikely Event\""
	var/datum/comm_message/insurance_message
	var/insurance_evaluation = 0

/datum/round_event/shuttle_insurance/announce(fake)
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", SSstation.announcer.get_rand_report_sound())

/datum/round_event/shuttle_insurance/setup()
	ship_name = pick(strings(PIRATE_NAMES_FILE, "rogue_names"))
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(template.name == SSshuttle.emergency.name) //found you slackin
			insurance_evaluation = template.credit_cost/2
			break
	if(!insurance_evaluation)
		insurance_evaluation = 5000 //gee i dunno

/datum/round_event/shuttle_insurance/start()
	insurance_message = new("Shuttle Insurance", "Hey, pal, this is the [ship_name]. Can't help but notice you're rocking a wild and crazy shuttle there with NO INSURANCE! Crazy. What if something happened to it, huh?! We've done a quick evaluation on your rates in this sector and we're offering [insurance_evaluation] to cover for your shuttle in case of any disaster.", list("Purchase Insurance.","Reject Offer."))
	insurance_message.answer_callback = CALLBACK(src,.proc/answered)
	SScommunications.send_message(insurance_message, unique = TRUE)

/datum/round_event/shuttle_insurance/proc/answered()
	if(EMERGENCY_AT_LEAST_DOCKED)
		priority_announce("You are definitely too late to purchase insurance, my friends. Our agents don't work on site.",sender_override = ship_name)
	if(insurance_message && insurance_message.answered == 1)
		var/datum/bank_account/station_balance = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(!station_balance?.adjust_money(-insurance_evaluation))
			priority_announce("You didn't send us enough money for shuttle insurance. This, in the space layman's terms, is considered scamming. We're keeping your money, scammers!",sender_override = ship_name)
			return
		priority_announce("Thank you for purchasing shuttle insurance!",sender_override = ship_name)
		SSshuttle.shuttle_insurance = TRUE
