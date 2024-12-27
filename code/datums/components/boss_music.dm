/**
 * Attaches to a hostile simplemob and plays that music while they have a target.
 */
/datum/component/boss_music
	///The music track we will play to players.
	var/boss_track
	///How long the track is, used to clear players out when the music is supposed to end.
	var/track_duration

	///List of all mobs listening to the boss music currently. Cleared on Destroy or after `track_duration`.
	var/list/datum/weakref/players_listening_refs = list()
	///List of callback timers, used to clear out mobs listening to boss music after `track_duration`.
	var/list/music_callbacks = list()

/datum/component/boss_music/Initialize(
	boss_track,
	track_duration,
)
	. = ..()
	if(!ishostile(parent))
		return COMPONENT_INCOMPATIBLE
	src.boss_track = boss_track
	src.track_duration = track_duration

/datum/component/boss_music/Destroy(force)
	. = ..()
	for(var/callback in music_callbacks)
		deltimer(callback)
	music_callbacks = null

	for(var/player_refs in players_listening_refs)
		clear_target(player_refs)
	players_listening_refs = null

/datum/component/boss_music/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_FOUND_TARGET, PROC_REF(on_target_found))

/datum/component/boss_music/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_FOUND_TARGET)
	return ..()

///Handles giving the boss music to a new target the fauna has received.
///Keeps track of them to not repeatedly overwrite its own track.
/datum/component/boss_music/proc/on_target_found(atom/source, mob/new_target)
	SIGNAL_HANDLER
	if(QDELETED(source) || !istype(new_target))
		return

	var/datum/weakref/new_ref = WEAKREF(new_target)
	if(new_ref in players_listening_refs)
		return

	players_listening_refs += new_ref
	RegisterSignal(new_target, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	music_callbacks += addtimer(CALLBACK(src, PROC_REF(clear_target), new_ref), track_duration, TIMER_STOPPABLE)
	new_target.playsound_local(new_target, boss_track, 200, FALSE, channel = CHANNEL_BOSS_MUSIC, pressure_affected = FALSE, use_reverb = FALSE)

///Called when a mob listening to boss music dies- ends their music early.
/datum/component/boss_music/proc/on_mob_death(mob/living/source)
	SIGNAL_HANDLER
	var/datum/weakref/player_ref = WEAKREF(source)
	clear_target(player_ref)

///Removes `old_target` from the list of players listening, and stops their music if it is still playing.
///This allows them to have music played again if they re-enter combat with this fauna.
/datum/component/boss_music/proc/clear_target(datum/weakref/old_ref)
	players_listening_refs -= old_ref

	var/mob/old_target = old_ref?.resolve()
	if(old_target)
		UnregisterSignal(old_target, COMSIG_LIVING_DEATH)
		old_target.stop_sound_channel(CHANNEL_BOSS_MUSIC)
