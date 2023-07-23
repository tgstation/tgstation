/**
 * Attaches to a hostile simplemob and plays that music while they have a target.
 */
/datum/component/boss_music
	///The soundloop to play while attacking.
	var/datum/looping_sound/boss_music

/datum/component/boss_music/Initialize(datum/looping_sound/boss_soundloop_type)
	. = ..()
	if(!ishostile(parent))
		return COMPONENT_INCOMPATIBLE
	boss_music = new boss_soundloop_type(parent, FALSE, FALSE)

/datum/component/boss_music/Destroy(force, silent)
	boss_music.stop(TRUE)
	QDEL_NULL(boss_music)
	return ..()

/datum/component/boss_music/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_FOUND_TARGET, PROC_REF(on_target_found))

/datum/component/boss_music/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_FOUND_TARGET)
	return ..()

///Handles giving the boss music to players.
///Null being passed as new_target means it is losing target, to remove the music.
/datum/component/boss_music/proc/on_target_found(atom/source, new_target)
	SIGNAL_HANDLER
	if(isnull(new_target))
		boss_music.stop()
		return
	if(boss_music.is_active())
		return
	boss_music.start()
