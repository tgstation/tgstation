/datum/syndicate_contract
	var/id = 0
	var/status = CONTRACT_STATUS_INACTIVE
	var/datum/objective/contract/contract = new()

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

/datum/syndicate_contract/proc/handle_extraction(var/mob/living/user)
	to_chat(user, "Handling extraction")

	if (contract.dropoff_check(user, contract.target.current))
		to_chat(user, "we're in")

		var/list/turfs = RANGE_TURFS(3, user)
		var/list/possible_drop_loc = list()

		for(var/T in turfs)
			var/turf/found_turf = T
			var/area/turf_area = get_area(found_turf)

			if (isfloorturf(found_turf) && istype(turf_area, contract.dropoff))
				possible_drop_loc.Add(found_turf)

		to_chat(user, "we've done our turf checks")
		// Need at least two seperate locations
		if (possible_drop_loc.len < 2)
			return FALSE

		to_chat(user, "we have two")

		var/pod_1_rand_loc = rand(1, possible_drop_loc.len)
		var/pod_2_rand_loc = rand(1, possible_drop_loc.len)

		while (pod_2_rand_loc == pod_1_rand_loc)
			pod_2_rand_loc = rand(1, possible_drop_loc.len)

		// We've got two valid locations - call extraction
		to_chat(user, "to launch")
		launch_extraction_pods(pod_1_rand_loc, pod_2_rand_loc)

		return 1
	return 0

/datum/syndicate_contract/proc/launch_extraction_pods(agent_pod_turf, empty_pod_turf)
	var/obj/structure/closet/supplypod/bluespacepod/agent_pod = new()
	var/obj/structure/closet/supplypod/bluespacepod/empty_pod = new()

	agent_pod.setStyle(STYLE_SYNDICATE)
	empty_pod.setStyle(STYLE_SYNDICATE)

	agent_pod.explosionSize = list(0,0,0,0)
	empty_pod.explosionSize = list(0,0,0,0)

	var/mob/living/simple_animal/hostile/syndicate/space/stormtrooper/agent_mob = new
	var/obj/empty_obj = new

	agent_mob.forceMove(agent_pod)
	empty_obj.forceMove(empty_pod)

	to_chat(usr, "launching")

	new /obj/effect/DPtarget(agent_pod_turf, agent_pod)
	new /obj/effect/DPtarget(empty_pod_turf, empty_pod)
