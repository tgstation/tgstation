// roster.dm was getting really crowded, so i moved the battle royale helpers here

/datum/roster/proc/setup_battle_royale(mob/user)
	if(!LAZYLEN(active_contestants))
		CRASH("No contestants to make into battle royale team!")

	if(active_teams)
		var/list/options = list("Clear Existing", "Cancel")
		var/select = input(user, "There are still existing teams, you must clear them first! Proceed with clearing, or cancel?") as null|anything in options

		switch(select)
			if("Clear Existing")
				clear_teams(user)
			else
				return

	if(battle_royale_active)
		var/list/options = list("Clear Existing", "Cancel")
		var/select = input(user, "Seems Battle Royale is already active! Force disable the existing BR before starting the new one, or cancel?") as null|anything in options

		switch(select)
			if("Clear Existing")
				end_battle_royale(user)
			else
				return

	var/datum/event_team/suicide_squad = create_team()
	suicide_squad.battle_royale = TRUE
	battle_royale_active = TRUE

	for(var/datum/contestant/iter_contestant in active_contestants)
		suicide_squad.add_member(user, iter_contestant)

	message_admins("[key_name_admin(user)] has initialized a battle royale team with [LAZYLEN(suicide_squad.members)] members!")
	log_game("[key_name_admin(user)] has initialized a battle royale team with [LAZYLEN(suicide_squad.members)] members!")

/datum/roster/proc/spawn_battle_royale(mob/user)
	if(LAZYLEN(active_teams) != 1)
		CRASH("There should only be one active team to start battle royale!")

	var/successes = 0
	var/spawn_index = 1
	var/num_of_spawns = length(spawns_br)

	if(!num_of_spawns)
		CRASH("No battle royale spawns detected in spawns_br!")

	log_game("[key_name_admin(user)] has tried spawning battle royale!")

	for(var/datum/contestant/iter_contestant in active_contestants)
		var/obj/machinery/arena_spawn/iter_spawn = spawns_br[spawn_index]
		spawn_index = max((spawn_index + 1) % num_of_spawns, 1)
		if(iter_contestant.spawn_this_contestant(iter_spawn))
			iter_contestant.set_flag_on_death(TRUE)
			RegisterSignal(iter_contestant, COMSIG_MOB_STATCHANGE, .proc/check_br_elimination_stat)
			RegisterSignal(iter_contestant, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), .proc/check_br_elimination_dead)
			successes++

	message_admins("[key_name_admin(user)] has spawned [successes] out of [LAZYLEN(active_contestants)] contestants successfully!")
	log_game("[key_name_admin(user)] has spawned [successes] out of [LAZYLEN(active_contestants)] contestants successfully!")

/// Officially ends the battle royale nightmare
/datum/roster/proc/end_battle_royale(mob/user)
	battle_royale_active = FALSE
	priority_announce("Battle Royale complete!")
	
	if(user)
		message_admins("[key_name_admin(user)] has ended the BATTLE ROYALE mode.")
		log_game("[key_name_admin(user)] has ended the BATTLE ROYALE mode.")
	else
		message_admins("The battle royale has ended! Printing winners to game.txt")
		log_game("The battle royale has ended! Printing winners to game.txt")
		var/list/text_dump = list("BR winners:")

		for(var/datum/contestant/iter_contestant in live_contestants)
			iter_contestant.set_flag_on_death(FALSE)
			text_dump += "[iter_contestant.ckey]"

		text_dump.Join(", ")
		log_game(text_dump) // lol is this okay? maybe spit it out in its own file

	for(var/datum/contestant/iter_contestant in all_contestants)
		UnregisterSignal(iter_contestant, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
		iter_contestant.despawn()

/// A check for when a mob's stat changes, to see if we've fallen unconscious or worse, which is as good as dead.
/datum/roster/proc/check_br_elimination_stat(mob/living/loser, new_stat)
	SIGNAL_HANDLER

	if(new_stat < UNCONSCIOUS)
		return

	battle_royale_elimination(loser)

/// A check for when a mob's stat changes, to see if we've fallen unconscious or worse, which is as good as dead.
/datum/roster/proc/check_br_elimination_dead(mob/living/loser)
	SIGNAL_HANDLER

	battle_royale_elimination(loser)

/// For enabling/disabling random wounds
/datum/roster/proc/battle_royale_elimination(mob/living/loser)
	if(!istype(loser))
		CRASH("Something's gone wrong! Tried eliminating someone who's not there.")
	if(LAZYLEN(active_contestants))
		CRASH("Something's gone wrong! Tried eliminating someone when there's no active contestants.")

	var/loser_ckey = loser.ckey
	var/datum/contestant/loser_contestant = active_contestants[loser_ckey]
	if(!istype(loser_contestant))
		CRASH("Something's gone wrong! Tried eliminating someone who's not there.")

	var/remaining_contestants = LAZYLEN(live_contestants)
	loser_contestant.despawn()
	message_admins("[key_name_admin(loser)] has been eliminated! Place: [remaining_contestants].")
	log_game("[key_name_admin(loser)] has been eliminated! Place: [remaining_contestants].")
	UnregisterSignal(loser_contestant, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
	loser.dust()

	if(remaining_contestants % 5 == 0)
		for(var/mob/M in GLOB.player_list)
			to_chat(M, "[span_minorannounce("<font color = red>Battle Royale Update</font color><BR>[remaining_contestants] contestants remaining!")]<BR>")

	if(COOLDOWN_FINISHED(src, battle_royale_voice_cd))
		COOLDOWN_START(src, battle_royale_voice_cd, BATTLE_ROYALE_ELIMINATION_VOICE_DELAY)

		var/vol = 70
		var/sound/admin_sound = new()
		admin_sound.file = pick(br_elimination_voice_files)
		admin_sound.priority = 250
		admin_sound.channel = CHANNEL_ADMIN
		admin_sound.frequency = 1
		admin_sound.wait = 1
		admin_sound.repeat = FALSE
		admin_sound.status = SOUND_STREAM
		admin_sound.volume = vol

		for(var/mob/M in GLOB.player_list)
			if(!(M.client?.prefs.toggles & SOUND_MIDI))
				continue
			admin_sound.volume = vol * M.client.admin_music_volume
			SEND_SOUND(M, admin_sound)
			admin_sound.volume = vol

	if(remaining_contestants <= br_end_population)
		end_battle_royale()
