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
	else if (prob(40)) // Low payout
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

// Launch the pod to collect our victim.
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
		UnregisterSignal(source, COMSIG_ATOM_ENTERED) // Takes a while for the pod to vanish - we don't want another person put in
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
			
			handleVictimExperience(M)

// They're off to holding - handle the return timer and give some text about what's going on.
/datum/syndicate_contract/proc/handleVictimExperience(var/mob/living/M)
	// Ship 'em back - dead or alive, it depends on if the Syndicate get paid... 5 minutes wait.
	// Even if they weren't the target, we're still treating them the same.
	addtimer(CALLBACK(src, .proc/returnVictim, M), (60 * 10) * 5)

	if (M.stat != DEAD)
		M.flash_act()
		M.confused += 10
		M.blur_eyes(10)
		to_chat(M, "<span class='warning'>You feel strange...</span>")
		sleep(60)
		to_chat(M, "<span class='warning'>That pod did something to you...</span>")
		M.Dizzy(35)
		sleep(65)
		to_chat(M, "<span class='warning'>Your head pounds... It feels like it's going to burst out your skull!</span>")
		M.flash_act()
		M.confused += 20
		M.blur_eyes(15)
		sleep(30)
		to_chat(M, "<span class='warning'>Your head pounds... It feels like it's going to burst out your skull!</span>")
		sleep(100)
		M.flash_act()
		M.Unconscious(200)
		to_chat(M, "<span class='reallybig hypnophrase'>A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
					we thank you for providing them. Your value is expended, should your station not pay for your return, we'll have no further \
					use for you. Whatever their decision, in five minutes, you're going home - but their choice might lead it to be without a beating \
					heart...\"</i></span>")
		M.blur_eyes(80)

/datum/syndicate_contract/proc/returnVictim(var/mob/living/M)
	var/list/possible_drop_loc = list()

	for (var/turf/possible_drop in contract.dropoff.contents)
		var/location_clear = TRUE
		// We don't care as much about what we land on than we did for sending the pod down.
		if (!isspaceturf(possible_drop))
			for (var/content in possible_drop.contents)
				if (istype(content, /obj/machinery) || istype(content, /obj/structure))
					location_clear = FALSE
			if (location_clear)
				possible_drop_loc.Add(possible_drop)

	if (possible_drop_loc.len > 0)
		var/pod_rand_loc = rand(1, possible_drop_loc.len)
		
		var/obj/structure/closet/supplypod/return_pod = new()
		return_pod.bluespace = TRUE
		return_pod.explosionSize = list(0,0,0,0)
		return_pod.style = STYLE_SYNDICATE

		do_sparks(8, FALSE, M)
		M.visible_message("<span class='notice'>[M] vanishes...</span>")
		M.forceMove(return_pod)

		new /obj/effect/DPtarget(possible_drop_loc[pod_rand_loc], return_pod)
	else
		to_chat(M, "<span class='reallybig hypnophrase'>A million voices echo in your head... <i>\"Seems where you got sent here from won't \
		            be able to handle our pod... This jail will be your tomb.\"</i></span>")
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.can_heartattack())
				var/datum/disease/D = new /datum/disease/heart_failure()
				C.ForceContractDisease(D, FALSE, TRUE)
