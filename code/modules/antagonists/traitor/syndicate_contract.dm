/datum/syndicate_contract
	var/id = 0
	var/status = CONTRACT_STATUS_INACTIVE
	var/datum/objective/contract/contract = new()

/datum/syndicate_contract/New(owner)
	generate(owner)

/datum/syndicate_contract/proc/generate(owner)
	contract.owner = owner
	contract.find_target()

	// Balanced around being low numbers, with bringing the target back alive giving
	// a fairly significant bonus comparatively.
	// High payout
	if (prob(10))
		contract.payout_bonus = rand(6,8)
	else if (prob(50)) // Low payout
		contract.payout_bonus = rand(1,2)
	else // Medium payout
		contract.payout_bonus = rand(3,5)

	contract.payout = rand(0, 2)

	contract.generate_dropoff()

/datum/syndicate_contract/proc/handle_extraction(var/mob/living/user)
	if (contract.dropoff_check(user, contract.target.current))

		var/list/turfs = RANGE_TURFS(3, user)
		var/list/possible_drop_loc = list()

		for(var/T in turfs)
			var/turf/found_turf = T
			var/area/turf_area = get_area(found_turf)

			// We check if both the turf is a floor, and that it's actually in the area. 
			// We also want a location that's clear of any obstructions.
			var/location_clear = TRUE
			if (isfloorturf(found_turf) && istype(turf_area, contract.dropoff))
				for (var/content in found_turf.contents)
					if (istype(content, /obj/machinery) || istype(content, /obj/structure))
						location_clear = FALSE
				if (location_clear)
					possible_drop_loc.Add(found_turf)

		// Need at least one free location.
		if (possible_drop_loc.len < 1)
			return FALSE

		var/pod_rand_loc = rand(1, possible_drop_loc.len)

		// We've got a valid location, launch.
		launch_extraction_pod(possible_drop_loc[pod_rand_loc])
		return 1
	return 0

/datum/syndicate_contract/proc/launch_extraction_pod(turf/empty_pod_turf)
	var/obj/structure/closet/supplypod/extractionpod/empty_pod = new()
	
	RegisterSignal(empty_pod, COMSIG_ATOM_ENTERED, .proc/enter_check)

	empty_pod.stay_after_drop = TRUE
	empty_pod.reversing = TRUE
	empty_pod.explosionSize = list(0,0,2,1)
	empty_pod.leavingSound = 'sound/effects/podwoosh.ogg'

	new /obj/effect/DPtarget(empty_pod_turf, empty_pod)

/datum/syndicate_contract/proc/enter_check(datum/source, var/mob/living/M)
	if (istype(source, /obj/structure/closet/supplypod/extractionpod))
		if (isliving(M))
			var/datum/antagonist/traitor/traitor_data = contract.owner.has_antag_datum(/datum/antagonist/traitor)
			
			if (M == contract.target.current)
				traitor_data.contract_TC_to_redeem += contract.payout

				if (M.stat != DEAD)
					traitor_data.contract_TC_to_redeem += contract.payout_bonus

				status = CONTRACT_STATUS_COMPLETE

				if (traitor_data.current_contract == src) {
					traitor_data.current_contract = null
				}
			else
				status = CONTRACT_STATUS_ABORTED // Sending a target that wasn't even yours is as good as just aborting it
				
				if (traitor_data.current_contract == src) {
					traitor_data.current_contract = null
				}
