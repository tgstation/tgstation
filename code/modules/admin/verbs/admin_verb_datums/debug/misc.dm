ADMIN_VERB(debug_stat_panel, "Debug Stat Panel", "Toggles debugging the stat panel locally.", NONE, VERB_CATEGORY_DEBUG)
	user.stat_panel.send_message("create_debug")

ADMIN_VERB(display_sendmaps, "Send Maps Profile", "View the current cost of sendmaps.", R_DEBUG, VERB_CATEGORY_DEBUG)
	user << link("?debug=profile&type=sendmaps&window=test")

ADMIN_VERB(spawn_debug_full_crew, "Spawn Debug Full Crew", "Creates a full crew for the station, filling up datacore and assigning jobs/minds. Don't run on live.", R_DEBUG, VERB_CATEGORY_DEBUG)
	var/mob/admin = user.mob
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(admin, "You should only be using this after a round has setup and started.")
		return

	// Two input checks here to make sure people are certain when they're using this.
	if(tgui_alert(admin, "This command will create a bunch of dummy crewmembers with minds, job, and datacore entries, which will take a while and fill the manifest.", "Spawn Crew", list("Yes", "Cancel")) != "Yes")
		return

	if(tgui_alert(admin, "I sure hope you aren't doing this on live. Are you sure?", "Spawn Crew (Be certain)", list("Yes", "Cancel")) != "Yes")
		return

	// Find the observer spawn, so we have a place to dump the dummies.
	var/obj/effect/landmark/observer_start/observer_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	var/turf/destination = get_turf(observer_point)
	if(!destination)
		to_chat(admin, "Failed to find the observer spawn to send the dummies.")
		return

	// Okay, now go through all nameable occupations.
	// Pick out all jobs that have JOB_CREW_MEMBER set.
	// Then, spawn a human and slap a person into it.
	var/number_made = 0
	for(var/rank in SSjob.name_occupations)
		var/datum/job/job = SSjob.GetJob(rank)

		// JOB_CREW_MEMBER is all jobs that pretty much aren't silicon
		if(!(job.job_flags & JOB_CREW_MEMBER))
			continue

		// Create our new_player for this job and set up its mind.
		var/mob/dead/new_player/new_guy = new()
		new_guy.mind_initialize()
		new_guy.mind.name = "[rank] Dummy"

		// Assign the rank to the new player dummy.
		if(!SSjob.AssignRole(new_guy, job))
			qdel(new_guy)
			to_chat(admin, "[rank] wasn't able to be spawned.")
			continue

		// It's got a job, spawn in a human and shove it in the human.
		var/mob/living/carbon/human/character = new(destination)
		character.name = new_guy.mind.name
		new_guy.mind.transfer_to(character)
		qdel(new_guy)

		// Then equip up the human with job gear.
		SSjob.EquipRank(character, job)
		job.after_latejoin_spawn(character)

		// Finally, ensure the minds are tracked and in the manifest.
		SSticker.minds += character.mind
		if(ishuman(character))
			GLOB.manifest.inject(character)

		number_made++
		CHECK_TICK

	to_chat(admin, "[number_made] crewmembers have been created.")
