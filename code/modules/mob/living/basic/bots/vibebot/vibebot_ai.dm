/datum/ai_controller/basic_controller/bot/vibebot
	behavior_tree_json = "code/modules/mob/living/basic/bots/vibebot/vibebot.bt.json"
	blackboard = list(
		BB_UNREACHABLE_LIST_COOLDOWN = 2 MINUTES,
		BB_VIBEBOT_HAPPY_SONG = VIBEBOT_CHEER_SONG,
		BB_VIBEBOT_GRIM_SONG = VIBEBOT_GRIM_MUSIC,
		BB_VIBEBOT_BIRTHDAY_SONG = VIBEBOT_HAPPY_BIRTHDAY,
	)
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_VIBEBOT_PARTY_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

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


/// Valid if the target is a conscious human who's in a bad mood or having a birthday — someone who could use cheering up.
/datum/targeting_strategy/conscious_human/party_friend/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/human_target = target
	return human_target.mob_mood?.mood_level < MOOD_LEVEL_NEUTRAL || HAS_TRAIT(human_target, TRAIT_BIRTHDAY_BOY)

/datum/bt_node/ai_behavior/vibebot_party
	var/ability_key
	var/target_key

/datum/bt_node/ai_behavior/vibebot_party/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, living_target) > 1)
		return AI_BEHAVIOR_INSTANT
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(ability)
		INVOKE_ASYNC(ability, TYPE_PROC_REF(/datum/action, Trigger), living_target)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.manual_emote("celebrates with [living_target]!")
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), "flip")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/vibebot_party/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(!isnull(target))
		controller.add_to_blacklist(target)
	controller.clear_blackboard_key(target_key)
