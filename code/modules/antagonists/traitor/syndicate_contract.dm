/datum/syndicate_contract
	var/datum/objective/contract/contract = new()

/datum/syndicate_contract/New(owner)
	generate(owner)

/datum/syndicate_contract/proc/generate(owner)
	contract.owner = owner
	contract.find_target()

	// Balanced around being low numbers - with bringing the target back alive giving
	// a fairly significant bonus comparatively.
	// High payout
	if (prob(20))
		contract.payout = rand(7,10)
	else if (prob(35)) // Low payout
		contract.payout = rand(1,3)
	else // Medium payout
		contract.payout = rand(4,6)

	contract.payout_bonus = rand(1, 5)

	contract.generate_dropoff()
