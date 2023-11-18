/datum/syndicate_contract
	///The 'id' of this particular contract. Used to keep track of statuses from TGUI.
	var/id
	///The current status of the contract. Starts off by default.
	var/status = CONTRACT_STATUS_INACTIVE
	///The related Objective datum for the contract, holding the target and such.
	var/datum/objective/contract/contract
	///The job position of the target.
	var/target_rank
	///How much we will pay out upon completion. This is not the TC completion, it's typically credits.
	var/ransom = 0
	///The level of payout, which affects the TC we get paid on completion.
	var/payout_type
	///Flavortext wanted message for the person we're after.
	var/wanted_message
	///List of everything found on the victim at the time of contracting, used to return their stuff afterwards.
	var/list/victim_belongings = list()

/datum/syndicate_contract/New(contract_owner, blacklist, type=CONTRACT_PAYOUT_SMALL)
	contract = new(src)
	contract.owner = contract_owner
	payout_type = type

	generate(blacklist)

/datum/syndicate_contract/proc/generate(blacklist)
	contract.find_target(null, blacklist)

	var/datum/record/crew/record
	if (contract.target)
		record = find_record(contract.target.name)

	if (record)
		target_rank = record.rank
	else
		target_rank = "Unknown"

	if (payout_type == CONTRACT_PAYOUT_LARGE)
		contract.payout_bonus = rand(9,13)
	else if (payout_type == CONTRACT_PAYOUT_MEDIUM)
		contract.payout_bonus = rand(6,8)
	else
		contract.payout_bonus = rand(2,4)

	contract.payout = rand(0, 2)
	contract.generate_dropoff()

	ransom = 100 * rand(18, 45)

	var/base = pick_list(WANTED_FILE, "basemessage")
	var/verb_string = pick_list(WANTED_FILE, "verb")
	var/noun = pick_list_weighted(WANTED_FILE, "noun")
	var/location = pick_list_weighted(WANTED_FILE, "location")
	wanted_message = "[base] [verb_string] [noun] [location]."

/datum/syndicate_contract/proc/handle_extraction(mob/living/user)
	if (contract.target && contract.dropoff_check(user, contract.target.current))

		var/turf/free_location = find_obstruction_free_location(3, user, contract.dropoff)

		if (free_location)
			// We've got a valid location, launch.
			launch_extraction_pod(free_location)
			return TRUE

	return FALSE

// Launch the pod to collect our victim.
/datum/syndicate_contract/proc/launch_extraction_pod(turf/empty_pod_turf)
	var/obj/structure/closet/supplypod/extractionpod/empty_pod = new()

	RegisterSignal(empty_pod, COMSIG_ATOM_ENTERED, PROC_REF(enter_check))

	empty_pod.stay_after_drop = TRUE
	empty_pod.reversing = TRUE
	empty_pod.explosionSize = list(0,0,0,1)
	empty_pod.leavingSound = 'sound/effects/podwoosh.ogg'

	new /obj/effect/pod_landingzone(empty_pod_turf, empty_pod)

/datum/syndicate_contract/proc/enter_check(datum/source, sent_mob)
	SIGNAL_HANDLER

	if(!istype(source, /obj/structure/closet/supplypod/extractionpod))
		return
	if(!isliving(sent_mob))
		return
	var/mob/living/person_sent = sent_mob
	var/datum/antagonist/traitor/traitor_data = contract.owner.has_antag_datum(/datum/antagonist/traitor)
	if(person_sent == contract.target.current)
		traitor_data.uplink_handler.contractor_hub.contract_TC_to_redeem += contract.payout
		traitor_data.uplink_handler.contractor_hub.contracts_completed++
		if(person_sent.stat != DEAD)
			traitor_data.uplink_handler.contractor_hub.contract_TC_to_redeem += contract.payout_bonus
		status = CONTRACT_STATUS_COMPLETE
		if(traitor_data.uplink_handler.contractor_hub.current_contract == src)
			traitor_data.uplink_handler.contractor_hub.current_contract = null
	else
		status = CONTRACT_STATUS_ABORTED // Sending a target that wasn't even yours is as good as just aborting it
		if(traitor_data.uplink_handler.contractor_hub.current_contract == src)
			traitor_data.uplink_handler.contractor_hub.current_contract = null

	if(iscarbon(person_sent))
		for(var/obj/item/person_contents in person_sent.gather_belongings())
			if(ishuman(person_sent))
				var/mob/living/carbon/human/human_sent = person_sent
				if(person_contents == human_sent.w_uniform)
					continue //So all they're left with are shoes and uniform.
				if(person_contents == human_sent.shoes)
					continue
			person_sent.transferItemToLoc(person_contents)
			victim_belongings.Add(WEAKREF(person_contents))

	var/obj/structure/closet/supplypod/extractionpod/pod = source
	// Handle the pod returning
	pod.startExitSequence(pod)

	if(ishuman(person_sent))
		var/mob/living/carbon/human/target = person_sent
		// After we remove items, at least give them what they need to live.
		target.dna.species.give_important_for_life(target)

	//we'll start the effects in a few seconds since it takes a moment for the pod to leave.
	addtimer(CALLBACK(src, PROC_REF(handle_victim_experience), person_sent), 3 SECONDS)

	// This is slightly delayed because of the sleep calls above to handle the narrative.
	// We don't want to tell the station instantly.
	var/points_to_check
	var/datum/bank_account/cargo_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(cargo_account)
		points_to_check = cargo_account.account_balance
	if(points_to_check >= ransom)
		cargo_account.adjust_money(-ransom)
	else
		cargo_account.adjust_money(-points_to_check)
	priority_announce(
		text = "One of your crew was captured by a rival organisation - we've needed to pay their ransom to bring them back. \
		As is policy we've taken a portion of the station's funds to offset the overall cost.",
		sender_override = "Nanotrasen Asset Protection")

	addtimer(CALLBACK(src, PROC_REF(finish_enter)), 3 SECONDS)

/datum/syndicate_contract/proc/finish_enter()
	// Pay contractor their portion of ransom
	if(status != CONTRACT_STATUS_COMPLETE)
		return
	var/obj/item/card/id/contractor_id = contract.owner.current?.get_idcard(TRUE)
	if(!contractor_id || !contractor_id.registered_account)
		return
	contractor_id.registered_account.adjust_money(ransom * 0.35)
	contractor_id.registered_account.bank_card_talk("We've processed the ransom, agent. \
		Here's your cut - your balance is now [contractor_id.registered_account.account_balance] cr.", TRUE)

#define VICTIM_EXPERIENCE_START 0
#define VICTIM_EXPERIENCE_FIRST_HIT 1
#define VICTIM_EXPERIENCE_SECOND_HIT 2
#define VICTIM_EXPERIENCE_THIRD_HIT 3
#define VICTIM_EXPERIENCE_LAST_HIT 4

/**
 * handle_victim_experience
 *
 * Handles the effects given to victims upon being contracted.
 * We heal them up and cause them immersive effects, just for fun.
 * Args:
 * victim - The person we're harassing
 * level - The current stage of harassement they are facing. This increases by itself, looping until finished.
 */
/datum/syndicate_contract/proc/handle_victim_experience(mob/living/victim, level = VICTIM_EXPERIENCE_START)
	// Ship 'em back - dead or alive, 4 minutes wait.
	// Even if they weren't the target, we're still treating them the same.
	if(!level)
		addtimer(CALLBACK(src, PROC_REF(return_victim), victim), (60 * 10) * 4)
	if(victim.stat == DEAD)
		return

	var/time_until_next
	switch(level)
		if(VICTIM_EXPERIENCE_START)
			// Heal them up - gets them out of crit/soft crit. If omnizine is removed in the future, this needs to be replaced with a
			// method of healing them, consequence free, to a reasonable amount of health.
			victim.reagents.add_reagent(/datum/reagent/medicine/omnizine, amount = 20)
			victim.flash_act()
			victim.adjust_confusion(1 SECONDS)
			victim.adjust_eye_blur(5 SECONDS)
			to_chat(victim, span_warning("You feel strange..."))
			time_until_next = 6 SECONDS
		if(VICTIM_EXPERIENCE_FIRST_HIT)
			to_chat(victim, span_warning("That pod did something to you..."))
			victim.adjust_dizzy(3.5 SECONDS)
			time_until_next = 6.5 SECONDS
		if(VICTIM_EXPERIENCE_SECOND_HIT)
			to_chat(victim, span_warning("Your head pounds... It feels like it's going to burst out your skull!"))
			victim.flash_act()
			victim.adjust_confusion(2 SECONDS)
			victim.adjust_eye_blur(3 SECONDS)
			time_until_next = 3 SECONDS
		if(VICTIM_EXPERIENCE_THIRD_HIT)
			to_chat(victim, span_warning("Your head pounds..."))
			time_until_next = 10 SECONDS
		if(VICTIM_EXPERIENCE_LAST_HIT)
			victim.flash_act()
			victim.Unconscious(200)
			to_chat(victim, span_hypnophrase("A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
				we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
				so it's only a matter of time before we ship you back...\"</i>"))
			victim.adjust_eye_blur(10 SECONDS)
			victim.adjust_dizzy(1.5 SECONDS)
			victim.adjust_confusion(2 SECONDS)

	level++ //move onto the next level.
	if(time_until_next)
		addtimer(CALLBACK(src, PROC_REF(handle_victim_experience), victim, level), time_until_next)

#undef VICTIM_EXPERIENCE_START
#undef VICTIM_EXPERIENCE_FIRST_HIT
#undef VICTIM_EXPERIENCE_SECOND_HIT
#undef VICTIM_EXPERIENCE_THIRD_HIT
#undef VICTIM_EXPERIENCE_LAST_HIT

// We're returning the victim
/datum/syndicate_contract/proc/return_victim(mob/living/victim)
	var/list/possible_drop_loc = list()

	for(var/turf/possible_drop in contract.dropoff.contents)
		if(!isspaceturf(possible_drop) && !isclosedturf(possible_drop))
			if(!possible_drop.is_blocked_turf())
				possible_drop_loc.Add(possible_drop)

	if(!possible_drop_loc.len)
		to_chat(victim, span_hypnophrase("A million voices echo in your head... \"Seems where you got sent here from won't \
			be able to handle our pod... You will die here instead.\""))
		if(iscarbon(victim))
			var/mob/living/carbon/carbon_victim = victim
			if(carbon_victim.can_heartattack())
				carbon_victim.set_heartattack(TRUE)
		return

	var/pod_rand_loc = rand(1, possible_drop_loc.len)
	var/obj/structure/closet/supplypod/return_pod = new()
	return_pod.bluespace = TRUE
	return_pod.explosionSize = list(0,0,0,0)
	return_pod.style = STYLE_SYNDICATE

	do_sparks(8, FALSE, victim)
	victim.visible_message(span_notice("[victim] vanishes..."))

	for(var/datum/weakref/belonging_ref in victim_belongings)
		var/obj/item/belonging = belonging_ref.resolve()
		if(!belonging)
			continue
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			//So all they're left with are shoes and uniform.
			if(belonging == human_victim.w_uniform)
				continue
			if(belonging == human_victim.shoes)
				continue
		belonging.forceMove(return_pod)

	for(var/obj/item/W in victim_belongings)
		W.forceMove(return_pod)

	victim.forceMove(return_pod)

	victim.flash_act()
	victim.adjust_eye_blur(3 SECONDS)
	victim.adjust_dizzy(3.5 SECONDS)
	victim.adjust_confusion(2 SECONDS)

	new /obj/effect/pod_landingzone(possible_drop_loc[pod_rand_loc], return_pod)
