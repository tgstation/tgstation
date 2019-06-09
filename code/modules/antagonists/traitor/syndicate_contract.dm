/datum/syndicate_contract
	var/id = 0
	var/status = CONTRACT_STATUS_INACTIVE
	var/datum/objective/contract/contract = new()

/datum/syndicate_contract/New(owner)
	generate(owner)
	RegisterSignal(src, COMSIG_CLOSET_STUFFED_INSIDE, .proc/enter_check)

/datum/syndicate_contract/proc/generate(owner)
	contract.owner = owner
	contract.find_target()

	// Balanced around being low numbers, with bringing the target back alive giving
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

/datum/syndicate_contract/proc/handle_extraction(var/mob/living/user)
	to_chat(user, "Handling extraction")

	if (contract.dropoff_check(user, contract.target.current))
		to_chat(user, "we're in")

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

		to_chat(user, "we've done our turf checks")
		
		// Need at least one free location.
		if (possible_drop_loc.len < 1)
			return FALSE

		to_chat(user, "we have one")

		var/pod_rand_loc = rand(1, possible_drop_loc.len)

		// We've got a valid location, launch.
		to_chat(user, "to launch")
		launch_extraction_pod(possible_drop_loc[pod_rand_loc])

		return 1
	return 0

/datum/syndicate_contract/proc/launch_extraction_pod(turf/empty_pod_turf)
	var/obj/structure/closet/supplypod/bluespacepod/empty_pod = new()
	
	RegisterSignal(empty_pod, COMSIG_ATOM_ENTERED, .proc/enter_check)

	empty_pod.setStyle(STYLE_SYNDICATE)
	empty_pod.stay_after_drop = TRUE
	empty_pod.reversing = TRUE
	empty_pod.explosionSize = list(0,0,2,1)

	new /obj/effect/DPtarget(empty_pod_turf, empty_pod)

/datum/syndicate_contract/proc/enter_check(datum/source, var/mob/living/M)
	to_chat(usr, "entercheck")

	if (istype(source, /obj/structure/closet/supplypod/bluespacepod))
		to_chat(usr, "ispod")

		var/obj/structure/closet/supplypod/bluespacepod/empty_pod = source

		empty_pod.depart(empty_pod)

		if (isliving(M))
			to_chat(usr, "isliving")
		else
			to_chat(usr, "isdead")

		// We send the pod back, and check if it was the target. If it wasn't, we send them a message

