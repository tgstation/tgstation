///How much time after a fauna loses a target do they have until the music stops
///Allowing faunas who lose their target to not lose their music for some time, in case the miner returns
#define BOSS_MUSIC_STOP_DELAY (30 SECONDS)

/**
 * Attaches to a hostile simplemob and plays that music while they have a target.
 */
/datum/component/boss_music
	///The soundloop to play while attacking.
	var/datum/looping_sound/boss_music
	///The timer until the music stops itself, after losing a target.
	var/stop_music_timer

/datum/component/boss_music/Initialize(datum/looping_sound/soundloop_type)
	. = ..()
	if(!ishostile(parent))
		return COMPONENT_INCOMPATIBLE
	boss_music = new soundloop_type(parent, FALSE, FALSE)

/datum/component/boss_music/Destroy(force, silent)
	if(stop_music_timer)
		deltimer(stop_music_timer)
	if(boss_music)
		boss_music.stop(TRUE)
		QDEL_NULL(boss_music)
	return ..()

/datum/component/boss_music/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_FOUND_TARGET, PROC_REF(on_target_found))

/datum/component/boss_music/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_FOUND_TARGET)
	return ..()

///Handles giving the boss music to people around them, when gaining a new target.
///If there is a timer to delete the music, deletes it, allowing it to continue that one instead.
/datum/component/boss_music/proc/on_target_found(atom/source, new_target)
	SIGNAL_HANDLER
	if(QDELETED(source))
		return
	if(isnull(new_target))
		stop_music_timer = addtimer(CALLBACK(src, PROC_REF(stop_music)), BOSS_MUSIC_STOP_DELAY, TIMER_UNIQUE | TIMER_STOPPABLE)
		return
	if(stop_music_timer)
		deltimer(stop_music_timer)
	if(boss_music.is_active())
		return
	boss_music.start()

///Ends the music, called by a timer when a fauna loses their target, after a delay.
/datum/component/boss_music/proc/stop_music()
	if(boss_music && boss_music.is_active())
		boss_music.stop(TRUE)
		stop_music_timer = null

#undef BOSS_MUSIC_STOP_DELAY
