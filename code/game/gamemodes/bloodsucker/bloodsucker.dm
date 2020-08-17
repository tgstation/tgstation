
/datum/game_mode
	var/list/datum/mind/bloodsuckers = list() 		// List of minds belonging to this game mode.
	var/list/datum/mind/vassals = list() 			// List of minds that have been turned into Vassals.
	var/list/datum/mind/vamphunters = list() 		// List of minds hunting vampires.
	var/obj/effect/sunlight/bloodsucker_sunlight	// Sunlight Timer. Created on first Bloodsucker assign. Destroyed on last removed Bloodsucker.

	// LISTS //
	var/list/vassal_allowed_antags = list(/datum/antagonist/brother, /datum/antagonist/traitor, /datum/antagonist/traitor/internal_affairs, /datum/antagonist/survivalist, \
										  /datum/antagonist/rev, /datum/antagonist/nukeop, /datum/antagonist/pirate, /datum/antagonist/cult, /datum/antagonist/abductee)
	// The antags you're allowed to be if turning Vassal.

/datum/game_mode/bloodsucker
	name = "bloodsucker"
	config_tag = "bloodsucker"
	report_type = "traitor"
	traitor_name = "Bloodsucker"//Nanotrasen Internal Affairs Agent"
	antag_flag = ROLE_BLOODSUCKER
	false_report_weight = 1
	restricted_jobs = list("AI","Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Deputy")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 7

	announce_span = "danger"
	announce_text = "Filthy, bloodsucking vampires are crawling around disguised as crewmembers!\n\
	<span class='danger'>Bloodsuckers</span>: The crew are cattle, while you are both shepherd and slaughterhouse.\n\
	<span class='notice'>Crew</span>: Put an end to the undead infestation before the station is overcome!"



// Seems to be run by game ONCE, and finds all potential players to be antag.
/datum/game_mode/bloodsucker/pre_setup()

	// Set Restricted Jobs
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	// Set number of Vamps
	recommended_enemies = clamp(round(num_players()/10), 1, 6);

	// Select Antags
	for(var/i = 0, i < recommended_enemies, i++)
		if (!antag_candidates.len)
			break
		var/datum/mind/bloodsucker = pick(antag_candidates)
		// Can we even BE a bloodsucker?
		//if (can_make_bloodsucker(bloodsucker, display_warning=FALSE))
		bloodsuckers += bloodsucker
		bloodsucker.restricted_roles = restricted_jobs
		log_game("[bloodsucker.key] (ckey) has been selected as a Bloodsucker.")
		antag_candidates.Remove(bloodsucker) // Apparently you can also write antag_candidates -= bloodsucker

	// FULPSTATION: Assign Hunters (as many as monsters, plus one)
	assign_monster_hunters(bloodsuckers.len, TRUE, bloodsuckers)	// FULP

	// Do we have enough vamps to continue?
	return bloodsuckers.len >= required_enemies


// Gamemode is all done being set up. We have all our Vamps. We now pick objectives and let them know what's happening.
/datum/game_mode/bloodsucker/post_setup()

	// Sunlight (Creating Bloodsuckers manually will check to create this, too)
	check_start_sunlight()

	// Vamps
	for(var/datum/mind/bloodsucker in bloodsuckers)
		// spawn() --> Run block of code but game continues on past it.
		// sleep() --> Run block of code and freeze code there (including whoever called us) until it's resolved.

		//Clean Bloodsucker Species (racist?)
		//clean_invalid_species(bloodsucker)
		// 			TO-DO !!!

		// Add Bloodsucker Antag Datum (or remove from list on Fail)
		if (!make_bloodsucker(bloodsucker))
			bloodsuckers -= bloodsucker

	// NOTE: Hunters are done in ..() parent proc

	return ..()

// Checking for ACTUALLY Dead Vamps
/datum/game_mode/bloodsucker/are_special_antags_dead()
	// Bloodsucker not Final Dead
	for(var/datum/mind/bloodsucker in bloodsuckers)
		if(!bloodsucker.AmFinalDeath())
			return FALSE
	return TRUE


// Init Sunlight (called from datum_bloodsucker.on_gain(), in case game mode isn't even Bloodsucker
/datum/game_mode/proc/check_start_sunlight()
	// Already Sunlight (and not about to cancel)
	if (istype(bloodsucker_sunlight) && !bloodsucker_sunlight.cancel_me)
		return
	bloodsucker_sunlight = new ()

// End Sun (last bloodsucker removed)
/datum/game_mode/proc/check_cancel_sunlight()
	// No Sunlight
	if (!istype(bloodsucker_sunlight))
		return
	if (bloodsuckers.len <= 0)
		bloodsucker_sunlight.cancel_me = TRUE
		qdel(bloodsucker_sunlight)
		bloodsucker_sunlight = null

/datum/game_mode/proc/is_daylight()
	return istype(bloodsucker_sunlight) && bloodsucker_sunlight.amDay

//////////////////////////////////////////////////////////////////////////////


/datum/game_mode/proc/can_make_bloodsucker(datum/mind/bloodsucker, datum/mind/creator, display_warning=TRUE) // Creator is just here so we can display fail messages to whoever is turning us.
	// No Mind
	if(!bloodsucker || !bloodsucker.key) // KEY is client login?
		//if(creator) // REMOVED. You wouldn't see their name if there is no mind, so why say anything?
		//	to_chat(creator, "<span class='danger'>[bloodsucker] isn't self-aware enough to be raised as a Bloodsucker!</span>")
		return FALSE
	// Current body is invalid
	if(!ishuman(bloodsucker.current))// && !ismonkey(bloodsucker.current))
		if(display_warning && creator)
			to_chat(creator, "<span class='danger'>[bloodsucker] isn't evolved enough to be raised as a Bloodsucker!</span>")
		return FALSE
	// Species Must have a HEART (Sorry Plasmabois)
	var/mob/living/carbon/human/H = bloodsucker.current
	if(NOBLOOD in H.dna.species.species_traits)
		if(display_warning && creator)
			to_chat(creator, "<span class='danger'>[bloodsucker]'s DNA isn't compatible!</span>")
		return FALSE
	// Already a Non-Human Antag
	if(bloodsucker.has_antag_datum(/datum/antagonist/abductor) || bloodsucker.has_antag_datum(/datum/antagonist/devil) || bloodsucker.has_antag_datum(/datum/antagonist/changeling))
		return FALSE
	// Already a vamp
	if(bloodsucker.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		if(display_warning && creator)
			to_chat(creator, "<span class='danger'>[bloodsucker] is already a Bloodsucker!</span>")
		return FALSE
	// Not High Enough
	if(creator)
		var/datum/antagonist/bloodsucker/creator_bloodsucker = creator.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if(!istype(creator_bloodsucker) || creator_bloodsucker.vamplevel < BLOODSUCKER_LEVEL_TO_EMBRACE)
			to_chat(creator, "<span class='danger'>Your blood is too thin to turn this corpse!</span>")
			return FALSE
	return TRUE


/datum/game_mode/proc/make_bloodsucker(datum/mind/bloodsucker, datum/mind/creator = null) // NOTE: This is a game_mode/proc, NOT a game_mode/bloodsucker/proc! We need to access this function despite the game mode.
	if (!can_make_bloodsucker(bloodsucker))
		return FALSE

	// Create Datum: Fledgling
	var/datum/antagonist/bloodsucker/A

	// [FLEDGLING]
	if (creator)
		A = new ANTAG_DATUM_BLOODSUCKER(bloodsucker)
		A.creator = creator
		bloodsucker.add_antag_datum(A)
		// Log
		message_admins("[bloodsucker] has become a Bloodsucker, and was created by [creator].")
		log_admin("[bloodsucker] has become a Bloodsucker, and was created by [creator].")

	// [MASTER]
	else
		A = bloodsucker.add_antag_datum(ANTAG_DATUM_BLOODSUCKER)


	return TRUE


/datum/game_mode/proc/remove_bloodsucker(datum/mind/bloodsucker)
	bloodsucker.remove_antag_datum(ANTAG_DATUM_BLOODSUCKER)


/datum/game_mode/proc/clean_invalid_species(datum/mind/bloodsucker)
	// Only checking for Humans here
	if (!ishuman(bloodsucker.current) || !bloodsucker.current.client)
		return
	var/am_valid = TRUE
	var/mob/living/carbon/human/H = bloodsucker.current

	// Check if PLASMAMAN?
	if(NOBLOOD in H.dna.species.species_traits)
		am_valid = FALSE

	// PROBLEM:
	//
	// Setting species leaves clothes on. If you were a plasmaman, we need to reassign your entire outfit. Otherwise
	// everyone will wonder why you're a human with Plasma clothes (jk they'll know you're antag)

	// Convert to HUMAN (along with ID and PDA)
	if (!am_valid)
		H.set_species(/datum/species/human)
		H.real_name = H.client.prefs.custom_names["human"]
		if (H.wear_id)
			var/obj/item/card/id/our_id = H.wear_id.GetID()
			our_id.registered_name = H.real_name
			our_id.update_label()


/datum/game_mode/proc/can_make_vassal(mob/living/target, datum/mind/creator, display_warning=TRUE)//, check_antag_or_loyal=FALSE)
	// Not Correct Type: Abort
	if (!iscarbon(target) || !creator)
		return FALSE
	if (target.stat > UNCONSCIOUS)
		return FALSE
				// Check Overdose: Am I even addicted to blood? Do I even have any in me?
				//if (!target.reagents.addiction_list || !target.reagents.reagent_list)
					//message_admins("DEBUG2: can_make_vassal() Abort: No reagents")
				//	return 0
				// Check Overdose: Did my current volume go over the Overdose threshold?
				//var/am_addicted = 0
				//for (var/datum/reagent/blood/vampblood/blood in target.reagents.addiction_list) // overdosed is tracked in reagent_list, not addiction_list.
					//message_admins("DEBUG3: can_make_vassal() Found Blood! [blood] [blood.overdose]")
					//if (blood.overdosed)
				//	am_addicted = 1 // Blood is present in addiction? That's all we need.
				//	break

				//if (!am_addicted)
					//message_admins("DEBUG4: can_make_vassal() Abort: No Blood")
				//	return 0
	// No Mind!
	if (!target.mind || !target.mind.key)
		if (display_warning)
			to_chat(creator, "<span class='danger'>[target] isn't self-aware enough to be made into a Vassal.</span>")
		return FALSE
	// Already MY Vassal
	var/datum/antagonist/vassal/V = target.mind.has_antag_datum(ANTAG_DATUM_VASSAL)
	if (istype(V) && V.master)
		if (V.master.owner == creator)
			if (display_warning)
				to_chat(creator, "<span class='danger'>[target] is already your loyal Vassal!</span>")
		else
			if (display_warning)
				to_chat(creator, "<span class='danger'>[target] is the loyal Vassal of another Bloodsucker!</span>")
		return FALSE
	// Already Antag or Loyal (Vamp Hunters count as antags)
	if (target.mind.enslaved_to || AmInvalidAntag(target.mind)) //!VassalCheckAntagValid(target.mind, check_antag_or_loyal)) // HAS_TRAIT(target, TRAIT_MINDSHIELD, "implant") ||
		if (display_warning)
			to_chat(creator, "<span class='danger'>[target] resists the power of your blood to dominate their mind!</span>")
		return FALSE
	return TRUE


/datum/game_mode/proc/AmValidAntag(datum/mind/M)
	// No List?
	if(!islist(M.antag_datums) || M.antag_datums.len == 0)
		return FALSE

	// Am I NOT an invalid Antag?    NOTE: We already excluded non-antags above. Don't worry about the "No List?" check in AmInvalidIntag()
	return !AmInvalidAntag(M)

/datum/game_mode/proc/AmInvalidAntag(datum/mind/M)
	// No List?
	if(!islist(M.antag_datums) || M.antag_datums.len == 0)
		return FALSE

	// Does even ONE antag appear in this mind that isn't in the list? Then FAIL!
	for(var/datum/antagonist/antag_datum in M.antag_datums)
		if (!(antag_datum.type in vassal_allowed_antags))  // vassal_allowed_antags is a list stored in the game mode, above.
			//message_admins("DEBUG VASSAL: Found Invalid: [antag_datum] // [antag_datum.type]")
			return TRUE

	//message_admins("DEBUG VASSAL: Valid Antags! (total of [M.antag_datums.len])")
	// WHEN YOU DELETE THE ABOVE: Remove the 3 second timer on converting the vassal too.
	return FALSE


/datum/game_mode/proc/make_vassal(mob/living/target, datum/mind/creator)
	if (!can_make_vassal(target,creator))
		return FALSE
	// Make Vassal
	var/datum/antagonist/vassal/V = new ANTAG_DATUM_VASSAL(target.mind)
	var/datum/antagonist/bloodsucker/B = creator.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	V.master = B
	target.mind.add_antag_datum(V, V.master.get_team())
	// Update Bloodsucker Title (we're a daddy now)
	B.SelectTitle(am_fledgling = FALSE) // Only works if you have no title yet.

	// Log
	message_admins("[target] has become a Vassal, and is enslaved to [creator].")
	log_admin("[target] has become a Vassal, and is enslaved to [creator].")

	return TRUE

/datum/game_mode/proc/remove_vassal(datum/mind/vassal)
	vassal.remove_antag_datum(ANTAG_DATUM_VASSAL)
