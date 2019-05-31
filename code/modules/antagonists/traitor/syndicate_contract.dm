/datum/syndicate_contract
	var/target
	var/reward = 0 // In TC
	var/dropoff

/datum/syndicate_contract/New()
	generate()

/datum/syndicate_contract/proc/generate()
	target = "First Surname"
	reward = rand(6,15)
	dropoff = "Dorm " + num2text(rand(1, 6))
