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
		launch_extraction_pods(possible_drop_loc[pod_1_rand_loc], possible_drop_loc[pod_2_rand_loc])

		return 1
	return 0

/datum/syndicate_contract/proc/launch_extraction_pods(turf/agent_pod_turf, turf/empty_pod_turf)
	var/obj/structure/closet/supplypod/bluespacepod/agent_pod = new()
	var/obj/structure/closet/supplypod/bluespacepod/empty_pod = new()

	agent_pod.setStyle(STYLE_SYNDICATE)
	empty_pod.setStyle(STYLE_SYNDICATE)

	agent_pod.stay_after_drop = TRUE
	empty_pod.stay_after_drop = TRUE

	agent_pod.explosionSize = list(0,0,1,1)
	empty_pod.explosionSize = list(0,0,1,1)

	var/mob/living/simple_animal/hostile/syndicate/space/stormtrooper/contract_agent/agent_mob = new
	var/obj/empty_obj = new

	// Agent should not care much about people around them, but will attack if they get too close.
	agent_mob.friends.Add(contract.owner.current)
	agent_mob.vision_range = 2
	agent_mob.aggro_vision_range = 3
	agent_mob.lose_patience_timeout = 15

	agent_mob.forceMove(agent_pod)
	empty_obj.forceMove(empty_pod)

	to_chat(usr, "launching")

	new /obj/effect/DPtarget(agent_pod_turf, agent_pod)
	new /obj/effect/DPtarget(empty_pod_turf, empty_pod)

	agent_logic(agent_mob, contract.target.current, agent_pod, empty_pod)

// We create some form of basic narrative with the mob. They quite blindly just pick up the target and put it in the pod. 
/datum/syndicate_contract/proc/agent_logic(agent_mob, var/mob/living/target_mob, var/obj/agent_pod, var/obj/empty_pod)
	var/mob/living/simple_animal/hostile/syndicate/space/stormtrooper/contract_agent/agent = agent_mob

	sleep(55) // We wait for the pod to land - it's just a fancy effect, so we need to do this to stop things messing up.

	agent.say("Good work agent. I'll take it from here - we need to be quick.")

	sleep(20)

	agent.Goto(target_mob, 3, 1)

	sleep(20)

	agent.start_pulling(target_mob)

	sleep(20)

	agent.Goto(empty_pod, 3, 1)

	sleep(20)

	target_mob.forceMove(empty_pod)

	sleep(20)

	agent.say("Alright - let's go.")

	agent.Goto(agent_pod, 3, 1)

	sleep(20)

	// TODO: Go to target - drag them to their pod. Place them. Close pod. Walk back to their pod. Face you. Tell them to get payment. After recieved, go in.
	// Can make this more fancy for special cases with if the caller of the evac isn't the same as the owner of contract, if enemies around, etc. 

	// Wait time for pod to land.
	// Keep trying to go to the target body if they're still in the area zone. Otherwise return to pod.
	// When close enough to body to grab, grab. If grabbing - return to empty pod, otherwise keep trying to get to body like above.
	// When next to pod, wait time, then force inside.
	// Return to own pod.
	// Return.
