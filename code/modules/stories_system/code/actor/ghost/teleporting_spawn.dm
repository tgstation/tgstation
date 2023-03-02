/datum/story_actor/ghost/teleporting_spawn
	name = "Teleporting Spawn template"
	/// What areas should we try to teleport the actor into?
	var/list/valid_areas = list(
		/area/station/cargo/lobby,
		/area/station/medical/treatment_center,
		/area/station/science/robotics,
		/area/station/command/bridge,
		/area/station/service/kitchen,
	)

/datum/story_actor/ghost/teleporting_spawn/send_them_in(mob/living/carbon/human/to_send_human)
	to_send_human.client?.prefs?.safe_transfer_prefs_to(to_send_human)
	. = ..()
	var/atom/spawn_location = get_turf(SSjob.get_last_resort_spawn_points())
	if(length(valid_areas))
		spawn_location = get_safe_random_station_turf(valid_areas)
	explosion(spawn_location, 0, 0, 3, 0, 5) // light explosion shouldn't breach the floor or nearby windows, but is for added effect
	new /obj/effect/temp_visual/emp/pulse(spawn_location)
	spawn_location.JoinPlayerHere(to_send_human, TRUE)

/datum/story_actor/ghost/teleporting_spawn/worldjumper
	name = "Worldjumper"
	actor_outfits = list(
		/datum/outfit/worldjumper,
	)
	actor_info = "The last thing you remember is a shining sky, the early dawning suns radiating a beautiful glow upon your home… and then came that brutal flash of light. \
	Now you're here. A cold husk of a vessel, floating in the dark void of the night. This place is strange. Alien. Not of your world, even if the inhabitants do seem to resemble you. \
	The very air itself seems to scratch and tear at your three lungs. You miss home. You miss the ones you left behind. Time for that later. For now, there is work to be done."
	actor_goal = "Find out what you can about this universe. Start thinking about a way home. Acquire clothing."

/datum/story_actor/ghost/teleporting_spawn/worldjumper/send_them_in(mob/living/carbon/human/to_send_human)
	. = ..()
	var/datum/story_type/somewhat_impactful/worldjumper/worldjumper_story = involved_story
	worldjumper_story.worldjumper_name = to_send_human.real_name
	worldjumper_story.worldjumper_human = to_send_human

/datum/story_actor/ghost/teleporting_spawn/second_jumper
	name = "Second Jumper"
	actor_outfits = list(
		/datum/outfit/worldjumper,
	)
	actor_info = "A brutal flash of light… and you've arrived.\n\n\
	You cough and splutter, but shove aside your pain for a moment. You've come here with a purpose. %WORLDJUMPERNAME%. Your old friend? Rival? Lover? That doesn't matter right now. \
	They're in this twisted place, and you're going to bring them back."
	actor_goal = "Find %WORLDJUMPERNAME% and convince them to return home."


/datum/story_actor/ghost/teleporting_spawn/second_jumper/handle_spawning(mob/picked_spawner, datum/story_type/current_story)
	var/datum/story_type/somewhat_impactful/worldjumper/worldjumper_story = current_story
	actor_info = replacetext(actor_info, "%WORLDJUMPERNAME%", worldjumper_story.worldjumper_name)
	actor_goal = replacetext(actor_goal, "%WORLDJUMPERNAME%", worldjumper_story.worldjumper_name)
	. = ..()

/datum/story_actor/ghost/teleporting_spawn/second_jumper/send_them_in(mob/living/carbon/human/to_send_human)
	. = ..()
	var/datum/story_actor/ghost/teleporting_spawn/worldjumper/worldjumper
	var/mob/living/carbon/human/worldjumper_human
	for(var/datum/mind/actor_mind as anything in involved_story.mind_actor_list)
		var/datum/story_actor/actor_datum = involved_story.mind_actor_list[actor_mind]
		switch(actor_datum.type)
			if(/datum/story_actor/ghost/teleporting_spawn/worldjumper)
				worldjumper_human = actor_mind.current
				worldjumper = actor_datum
	worldjumper.actor_info = "You've spent some time here now, growing just a little bit accustomed to this world. The air isn't as harsh, \
	and you feel like you understand this strange station just a little bit better…\n\n\
	Still, this isn't your home. Your thoughts turn to [to_send_human.real_name]. You hope they're doing well…\n\n\
	But as your thoughts linger on that world, a question burns away all else. Was that place ever really your home? Are you sure you want to go back?"
	worldjumper.actor_goal = "Either remain on the station or find a way home."
	worldjumper.ui_interact(worldjumper.actor_ref.current)
	var/obj/item/return_device/return_device = new(get_turf(to_send_human))
	return_device.worldjumper = worldjumper_human
	return_device.second_jumper = to_send_human
	to_send_human.put_in_hands(return_device, ignore_animation = TRUE)
