/datum/syndicate_contract
	var/datum/objective/contract/contract = new()

/datum/syndicate_contract/New()
	generate()

/datum/syndicate_contract/proc/generate()
	contract.find_target()

	// High payout
	if (prob(20))
		contract.payout = rand(13,18)
	else if (prob(20)) // Low payout
		contract.payout = rand(3,6)
	else // Medium payout
		contract.payout = rand(7,12)
		
	contract.generate_dropoff()
