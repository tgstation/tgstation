/datum/team/cult
	name = "\improper Cult"

	///The blood mark target
	var/atom/blood_target
	///Image of the blood mark target
	var/image/blood_target_image
	///Timer for the blood mark expiration
	var/blood_target_reset_timer

	///Has a vote been called for a leader?
	var/cult_vote_called = FALSE
	///The cult leader
	var/datum/antagonist/cult/cult_leader_datum
	///Has the mass teleport been used yet?
	var/reckoning_complete = FALSE
	///Has the cult risen, and gotten red eyes?
	var/cult_risen = FALSE
	///Has the cult ascended, and gotten halos?
	var/cult_ascendent = FALSE

	/// List that keeps track of which items have been unlocked after a heretic was sacked.
	var/list/unlocked_heretic_items = list(
		CURSED_BLADE_UNLOCKED = FALSE,
		CRIMSON_MEDALLION_UNLOCKED = FALSE,
		PROTEON_ORB_UNLOCKED = FALSE,
	)

	///Has narsie been summoned yet?
	var/narsie_summoned = FALSE
	///How large were we at max size.
	var/size_at_maximum = 0
	///list of cultists just before summoning Narsie
	var/list/true_cultists = list()

/datum/team/cult/proc/check_size()
	if(cult_ascendent)
		return

	// This proc is unnecessary clutter whilst running cult related unit tests
	// Remove this if, at some point, someone decides to test that halos and eyes are added at expected ratios
#ifndef UNIT_TESTS
	var/alive = 0
	var/cultplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(IS_CULTIST(M))
				++cultplayers
			else
				++alive

	ASSERT(cultplayers) //we shouldn't be here.
	var/ratio = alive ? cultplayers/alive : 1
	if(ratio > CULT_RISEN && !cult_risen)
		for(var/datum/mind/mind as anything in members)
			if(mind.current)
				SEND_SOUND(mind.current, 'sound/music/antag/bloodcult/bloodcult_eyes.ogg')
				to_chat(mind.current, span_cult_large(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
				mind.current.AddElement(/datum/element/cult_eyes)
		cult_risen = TRUE
		log_game("The blood cult has risen with [cultplayers] players.")

	if(ratio > CULT_ASCENDENT && !cult_ascendent)
		for(var/datum/mind/mind as anything in members)
			if(mind.current)
				SEND_SOUND(mind.current, 'sound/music/antag/bloodcult/bloodcult_halos.ogg')
				to_chat(mind.current, span_cult_large(span_warning("Your cult is ascendant and the red harvest approaches - you cannot hide your true nature for much longer!!")))
				mind.current.AddElement(/datum/element/cult_halo)
		cult_ascendent = TRUE
		log_game("The blood cult has ascended with [cultplayers] players.")
#endif

/datum/team/cult/add_member(datum/mind/new_member)
	. = ..()
	// A little hacky, but this checks that cult ghosts don't contribute to the size at maximum value.
	if(is_unassigned_job(new_member.assigned_role))
		return
	size_at_maximum++

/datum/team/cult/proc/make_image(datum/objective/sacrifice/sac_objective)
	var/datum/job/job_of_sacrifice = sac_objective.target.assigned_role
	var/datum/preferences/prefs_of_sacrifice = sac_objective.target.current.client.prefs
	var/icon/reshape = get_flat_human_icon(null, job_of_sacrifice, prefs_of_sacrifice, list(SOUTH))
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	sac_objective.sac_image = reshape

/datum/team/cult/proc/setup_objectives()
	var/datum/objective/sacrifice/sacrifice_objective = new
	sacrifice_objective.team = src
	sacrifice_objective.find_target()
	objectives += sacrifice_objective

	var/datum/objective/eldergod/summon_objective = new
	summon_objective.team = src
	objectives += summon_objective

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(O.check_completion() == CULT_NARSIE_KILLED)
			return CULT_NARSIE_KILLED
		else if(!O.check_completion())
			return CULT_LOSS
	return CULT_VICTORY

/datum/team/cult/roundend_report()
	var/list/parts = list()
	var/victory = check_cult_victory()

	if(victory == CULT_NARSIE_KILLED) // Epic failure, you summoned your god and then someone killed it.
		parts += "<span class='redtext big'>Nar'sie has been killed! The cult will haunt the universe no longer!</span>"
	else if(victory)
		parts += "<span class='greentext big'>The cult has succeeded! Nar'Sie has snuffed out another torch in the void!</span>"
	else
		parts += "<span class='redtext big'>The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!</span>"

	if(objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			parts += "<b>Objective #[count]</b>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
			count++

	if(members.len)
		parts += span_header("The cultists were:")
		if(length(true_cultists))
			parts += printplayerlist(true_cultists)
		else
			parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)

	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/// Sets a blood target for the cult.
/datum/team/cult/proc/set_blood_target(atom/new_target, mob/marker, duration = 90 SECONDS)
	if(QDELETED(new_target))
		CRASH("A null or invalid target was passed to set_blood_target.")

	if(duration != INFINITY && blood_target_reset_timer)
		return FALSE

	deltimer(blood_target_reset_timer)
	blood_target = new_target
	RegisterSignal(blood_target, COMSIG_QDELETING, PROC_REF(unset_blood_target_and_timer))
	var/area/target_area = get_area(new_target)

	blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', new_target, "glow", ABOVE_MOB_LAYER)
	blood_target_image.appearance_flags = RESET_COLOR
	blood_target_image.pixel_x = -new_target.pixel_x
	blood_target_image.pixel_y = -new_target.pixel_y

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		to_chat(cultist.current, span_bold(span_cult_large("[marker] has marked [blood_target] in \the [target_area] as the cult's top priority, get there immediately!")))
		SEND_SOUND(cultist.current, sound(SFX_HALLUCINATION_OVER_HERE, 0, 1, 75))
		cultist.current.client.images += blood_target_image

	if(duration != INFINITY)
		blood_target_reset_timer = addtimer(CALLBACK(src, PROC_REF(unset_blood_target)), duration, TIMER_STOPPABLE)
	return TRUE

/// Unsets out blood target, clearing the images from all the cultists.
/datum/team/cult/proc/unset_blood_target()
	blood_target_reset_timer = null

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		if(QDELETED(blood_target))
			to_chat(cultist.current, span_bold(span_cult_large("The blood mark's target is lost!")))
		else
			to_chat(cultist.current, span_bold(span_cult_large("The blood mark has expired!")))
		cultist.current.client.images -= blood_target_image

	UnregisterSignal(blood_target, COMSIG_QDELETING)
	blood_target = null

	QDEL_NULL(blood_target_image)

/// Unsets our blood target when they get deleted.
/datum/team/cult/proc/unset_blood_target_and_timer(datum/source)
	SIGNAL_HANDLER

	deltimer(blood_target_reset_timer)
	unset_blood_target()
