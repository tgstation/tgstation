/**
 * Used for playing background music
 */
/datum/music
	/// The file played
	var/sound_file
	/// Whether the file loops - If false, the music automatically is removed once it reaches the end
	var/does_loop = FALSE
	/// Used for removing the song if it's non-looping - not necessary to set for loops
	var/length = 1200
	/// The base volume to play at, not accounting for fading
	var/base_volume = 65
	/// Higher priority music plays over lower priority ones. If a looping music is masked by a higher priority music, it will start playing once the higher priority ends if it hasn't been removed.
	var/priority = 0
	/// The fading adjustment to the volume
	var/fade_volume = 1
	/// The target for fading volume
	var/fade_volume_target = 1
	/// Rate at which we fade
	var/fade_rate = 0
	/// Whether or not we are in the process of fading
	var/is_fading = FALSE
	/// The target client of music
	var/client/target
	/// The sound datum playing
	var/sound/sound_datum

/datum/music/New(client/target, fade_volume = 1)
	..()
	target.active_music += src
	src.target = target
	src.fade_volume = fade_volume
	START_PROCESSING(SSprocessing, src)
	if((target.prefs.toggles & SOUND_INSTRUMENTS) && (!target.playing_music || target.playing_music.priority < priority || (target.playing_music.priority == priority && target.playing_music.does_loop && !does_loop)))
		unmask()
	else if(!does_loop)
		qdel(src)

/datum/music/Destroy()
	mask()
	if(is_fading)
		STOP_PROCESSING(SSfastprocess, src)
	else
		STOP_PROCESSING(SSprocessing, src)
	if(target)
		target.active_music -= src
		target.update_playing_music()
		target = null
	return ..()


/datum/music/proc/unmask()
	if(!target || target.playing_music == src)
		return
	if(target.playing_music)
		target.playing_music.mask()
	target.playing_music = src
	if(sound_datum || !target || !sound_file)
		return
	sound_datum = sound(sound_file, does_loop, 0, CHANNEL_JUKEBOX, base_volume * fade_volume)
	SEND_SOUND(target, sound_datum)

/datum/music/proc/mask()
	if(target)
		target.playing_music = null
		if(sound_datum)
			SEND_SOUND(target, sound(null, repeat = 0, wait = 0, channel = CHANNEL_JUKEBOX))
			sound_datum = null
	if(!does_loop)
		qdel(src)

/datum/music/proc/fade(target, time)
	fade_volume_target = target
	if(target == fade_volume)
		set_is_fading(FALSE)
		return
	if(time < 0.1)
		time = 0.1
	fade_rate = abs(fade_volume_target - fade_volume) / time
	set_is_fading(TRUE)

/datum/music/proc/fade_at_rate(target, rate)
	fade_volume_target = target
	if(target == fade_volume)
		set_is_fading(FALSE)
		return
	fade_rate = rate
	set_is_fading(TRUE)

/client/proc/update_playing_music()
	if(!(prefs.toggles & SOUND_INSTRUMENTS))
		if(playing_music)
			playing_music.mask()
	else if(!playing_music)
		var/datum/music/highest_priorty = null
		for(var/datum/music/as_music as anything in active_music)
			if(!highest_priorty || as_music.priority > highest_priorty.priority)
				highest_priorty = as_music
		if(highest_priorty)
			highest_priorty.unmask()

/datum/music/process(wait)
	if(!target)
		qdel(src)
		return PROCESS_KILL
	if(is_fading)
		if(fade_volume_target > fade_volume)
			fade_volume = min(fade_volume + wait * fade_rate, fade_volume_target)
		else if(fade_volume_target < fade_volume)
			fade_volume = max(fade_volume - wait * fade_rate, fade_volume_target)
		else
			set_is_fading(FALSE)
		if(sound_datum && target)
			sound_datum.status = SOUND_UPDATE
			sound_datum.volume = fade_volume * base_volume
			SEND_SOUND(target, sound_datum)
		if(fade_volume == 0 && fade_volume_target == 0)
			qdel(src)

/datum/music/proc/set_is_fading(new_is_fading)
	if(new_is_fading == is_fading)
		return
	is_fading = new_is_fading
	if(is_fading)
		STOP_PROCESSING(SSprocessing, src)
		START_PROCESSING(SSfastprocess, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
		START_PROCESSING(SSprocessing, src)

/datum/music/sourced
	/// The target mob we are playing the music to
	var/mob/target_mob
	/// List of music players we can play from
	var/list/datum/component/music_player/players = list()
	/// Range within which music will play at full volume
	var/full_range = 10
	/// Maximum range within which music will play, out of that range it will stop
	var/soft_range = 20
	/// Speed at which music will fade out while out of range
	var/range_fade_speed = 0.01

/datum/music/sourced/New(client/target, fade_volume)
	if(target)
		target_mob = target.mob
	..()

/datum/music/sourced/process()
	if(!target_mob || !target_mob.client)
		qdel(src)
		return
	var/closest_range_squared = soft_range*soft_range + 10
	for(var/datum/component/music_player/player as anything in players)
		var/atom/movable/atom = player.parent
		if(atom.z != target_mob.z)
			continue
		var/dx = atom.x-target_mob.x
		var/dy = atom.y-target_mob.y
		var/range_squared = dx*dx+dy*dy
		if(range_squared < closest_range_squared)
			closest_range_squared = range_squared
	var/closest_range = sqrt(closest_range_squared)
	var/target
	if(closest_range <= full_range)
		target = 1
	else if(closest_range >= soft_range)
		target = 0
	else
		target = (soft_range - closest_range) / (soft_range - full_range)
	if(!is_fading || fade_volume_target != target)
		fade_at_rate(target, range_fade_speed)
	return ..()

/datum/music/sourced/Destroy()
	. = ..()
	for(var/datum/component/music_player/player as anything in players)
		player.mob_players -= target_mob

/datum/component/music_player
	/// List of all the mobs the music is playing to
	var/list/mob_players = list()
	/// Path of the music being played
	var/music_path
	/// Whether new mobs will be added. To force mobs to stop playing this, use stop_all()
	var/enabled = TRUE
	/// Range within which music will start to play
	var/start_range = 7
	/// Time it starts for the music to fade in
	var/fade_in_time = 30
	/// Whether music of the same typepath is shared
	var/shared = TRUE

/datum/component/music_player/Initialize(music_path)
	if(music_path)
		src.music_path = music_path
	START_PROCESSING(SSprocessing, src)

/datum/component/music_player/proc/do_range_check(fade_time = fade_in_time)
	if(!music_path)
		return
	var/shared = FALSE
	for(var/mob/living/mob in range(start_range, parent))
		if(!mob.client)
			continue
		if(mob_players[mob])
			continue
		var/did_find = FALSE
		if(shared)
			for(var/datum/music/sourced/music as anything in mob.client.active_music)
				if(istype(music, music_path))
					mob_players[mob] = music
					music.players += src
					did_find = TRUE
					break
		if(!did_find)
			var/datum/music/sourced/music = new music_path(mob.client, fade_time > 0 ? 0 : 1)
			if(!music.gc_destroyed)
				mob_players[mob] = music
				music.players += src
				if(fade_time > 0)
					music.fade(1, fade_time)


/datum/component/music_player/proc/stop_all(fade_time = 0)
	for(var/mob/mob as anything in mob_players)
		var/datum/music/sourced/music = mob_players[mob]
		music.fade(0, fade_time)

/datum/component/music_player/proc/remove_all()
	for(var/mob/mob as anything in mob_players)
		if(!mob || !mob.client)
			continue
		var/datum/music/sourced/music = mob_players[mob]
		music.players -= src
	mob_players.Cut()

/datum/component/music_player/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)
	remove_all()
	mob_players = null

/datum/component/music_player/process()
	if(enabled)
		do_range_check()

/datum/component/music_player/battle/process()
	. = ..()
	var/mob/mob = parent
	var/should_be_enabled = !mob.stat && !mob.client
	if(enabled && !should_be_enabled)
		remove_all(fade_in_time)
	enabled = should_be_enabled

/datum/music/sourced/battle
	does_loop = TRUE

/datum/music/sourced/battle/miner
	sound_file = 'sound/lavaland/boss_music/miner.ogg'
	priority = 90

/datum/music/sourced/battle/ash_drake
	sound_file = 'sound/lavaland/boss_music/ashdrake.ogg'
	priority = 100

/datum/music/sourced/battle/colossus
	sound_file = 'sound/lavaland/boss_music/colossus.ogg'
	priority = 110

/datum/music/sourced/battle/hierophant
	sound_file = 'sound/lavaland/boss_music/hierophant.ogg'
	priority = 120

/datum/music/sourced/battle/bubblegum
	sound_file = 'sound/lavaland/boss_music/bubblegum.ogg'
	priority = 130

/datum/music/sourced/battle/wendigo
	sound_file = 'sound/lavaland/boss_music/wendigo.ogg'
	priority = 140

/datum/music/sourced/battle/legion
	sound_file = 'sound/lavaland/boss_music/legion.ogg'
	priority = 150
