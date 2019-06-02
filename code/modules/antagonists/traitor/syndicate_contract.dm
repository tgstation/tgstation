/datum/syndicate_contract
	var/id = 0
	var/status = STATUS_INACTIVE
	var/datum/objective/contract/contract = new()
	var/const/STATUS_INACTIVE = 1
	var/const/STATUS_ACTIVE = 2
	var/const/STATUS_EXTRACTING = 3
	var/const/STATUS_COMPLETE = 4
	var/const/STATUS_ABORTED = 5

/datum/syndicate_contract/New(owner)
	generate(owner)

/datum/syndicate_contract/proc/generate(owner)
	contract.owner = owner
	contract.find_target()

	// Balanced around being low numbers - with bringing the target back alive giving
	// a fairly significant bonus comparatively.
	// High payout
	if (prob(10))
		contract.payout = rand(7,10)
	else if (prob(35)) // Low payout
		contract.payout = rand(1,3)
	else // Medium payout
		contract.payout = rand(4,6)

	contract.payout_bonus = rand(1, 5)

	contract.generate_dropoff()
