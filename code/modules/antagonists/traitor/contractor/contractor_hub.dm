/datum/contractor_hub
	///The current contract in progress, and can be null if no contract is in progress.
	var/datum/syndicate_contract/current_contract
	///List of all available syndicate contracts that can be taken.
	var/list/datum/syndicate_contract/assigned_contracts = list()

	///Reference to a contractor teammate, if one has been purchased.
	var/datum/antagonist/traitor/contractor_support/contractor_teammate

	///List of all people currently used as targets, to not roll doubles.
	var/list/assigned_targets = list()

	///Amount of contracts that have already been completed, for flavor in the UI & round-end logs.
	var/contracts_completed = 0
	///How much TC has been paid out, for flavor in the UI & round-end logs.
	var/contract_TC_payed_out = 0
	///How much TC we can cash out currently. Used when redeeming TC and for round-end logs.
	var/contract_TC_to_redeem = 0

/datum/contractor_hub/proc/create_contracts(datum/mind/owner)
	// 6 initial contracts
	var/list/to_generate = list(
		CONTRACT_PAYOUT_LARGE,
		CONTRACT_PAYOUT_MEDIUM,
		CONTRACT_PAYOUT_SMALL,
		CONTRACT_PAYOUT_SMALL,
		CONTRACT_PAYOUT_SMALL,
		CONTRACT_PAYOUT_SMALL
	)

	//What the fuck
	if(length(to_generate) > length(GLOB.manifest.locked))
		to_generate.Cut(1, length(GLOB.manifest.locked))

	// We don't want the sum of all the payouts to be under this amount
	var/lowest_TC_threshold = 30

	var/total = 0
	var/lowest_paying_sum = 0
	var/datum/syndicate_contract/lowest_paying_contract

	// Randomise order, so we don't have contracts always in payout order.
	to_generate = shuffle(to_generate)

	// Support contract generation happening multiple times
	var/start_index = 1
	if (assigned_contracts.len != 0)
		start_index = assigned_contracts.len + 1

	// Generate contracts, and find the lowest paying.
	for(var/i in 1 to to_generate.len)
		var/datum/syndicate_contract/contract_to_add = new(owner, assigned_targets, to_generate[i])
		var/contract_payout_total = contract_to_add.contract.payout + contract_to_add.contract.payout_bonus

		assigned_targets.Add(contract_to_add.contract.target)

		if (!lowest_paying_contract || (contract_payout_total < lowest_paying_sum))
			lowest_paying_sum = contract_payout_total
			lowest_paying_contract = contract_to_add

		total += contract_payout_total
		contract_to_add.id = start_index
		assigned_contracts.Add(contract_to_add)

		start_index++

	// If the threshold for TC payouts isn't reached, boost the lowest paying contract
	if (total < lowest_TC_threshold)
		lowest_paying_contract.contract.payout_bonus += (lowest_TC_threshold - total)
