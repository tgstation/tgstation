/datum/ai_controller/basic_controller/bot/vibebot
	blackboard = list(
		BB_UNREACHABLE_LIST_COOLDOWN = 2 MINUTES,
		BB_VIBEBOT_HAPPY_SONG = VIBEBOT_CHEER_SONG,
		BB_VIBEBOT_GRIM_SONG = VIBEBOT_GRIM_MUSIC,
		BB_VIBEBOT_BIRTHDAY_SONG = VIBEBOT_HAPPY_BIRTHDAY,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/manage_unreachable_list,
		/datum/ai_planning_subtree/find_party_friends,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_VIBEBOT_PARTY_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
	ai_traits = PAUSE_DURING_DO_AFTER

/datum/ai_controller/basic_controller/bot/vibebot/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_VIBEBOT_PARTY_TARGET), PROC_REF(play_music))

/datum/ai_controller/basic_controller/bot/vibebot/proc/play_music(datum/source, blackboard_key)
	SIGNAL_HANDLER

	var/mob/living/basic/bot/living_bot = pawn
	var/obj/item/instrument/instrument = blackboard[BB_SONG_INSTRUMENT]
	if(isnull(instrument))
		return
	var/atom/target = blackboard[blackboard_key]
	var/datum/song/song = instrument.song
	song.stop_playing()
	var/song_lines
	if(living_bot.bot_access_flags & BOT_COVER_EMAGGED)
		song_lines = blackboard[BB_VIBEBOT_GRIM_SONG]
	else
		song_lines = HAS_TRAIT(target, TRAIT_BIRTHDAY_BOY) ? blackboard[BB_VIBEBOT_BIRTHDAY_SONG] : blackboard[BB_VIBEBOT_HAPPY_SONG]
	if(isnull(song_lines))
		return
	song.ParseSong(new_song = song_lines)
	song.start_playing(pawn)
	addtimer(CALLBACK(song, TYPE_PROC_REF(/datum/song, stop_playing)), 10 SECONDS) //in 10 seconds, stop playing music

///subtree we use to find party friends in general
/datum/ai_planning_subtree/find_party_friends

/datum/ai_planning_subtree/find_party_friends/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/static/list/type_to_search = typecacheof(list(/mob/living/carbon/human))
	if(!controller.blackboard_key_exists(BB_VIBEBOT_PARTY_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_search/party_friends, BB_VIBEBOT_PARTY_TARGET, type_to_search)
		return

	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/vibebot_party, BB_VIBEBOT_PARTY_ABILITY, BB_VIBEBOT_PARTY_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

///behavior we use to party with people
/datum/ai_behavior/targeted_mob_ability/and_clear_target/vibebot_party
	behavior_flags = AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/targeted_mob_ability/and_clear_target/vibebot_party/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/targeted_mob_ability/and_clear_target/vibebot_party/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	var/atom/target = controller.blackboard[target_key]
	controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)
	if(succeeded)
		var/mob/living/living_pawn = controller.pawn
		living_pawn.manual_emote("celebrates with [target]!")
		living_pawn.emote("flip")
	return ..()

///behavior that searches for party friends
/datum/ai_behavior/bot_search/party_friends
	action_cooldown = 5 SECONDS

/datum/ai_behavior/bot_search/party_friends/valid_target(datum/ai_controller/basic_controller/bot/controller, mob/living/carbon/human/my_target)
	if(my_target.stat != CONSCIOUS || isnull(my_target.mind))
		return FALSE
	return (my_target.mob_mood.mood_level < MOOD_LEVEL_NEUTRAL || HAS_TRAIT(my_target, TRAIT_BIRTHDAY_BOY))
