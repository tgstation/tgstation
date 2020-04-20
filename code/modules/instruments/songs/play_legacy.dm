/**
  * Proc used for playing legacy instruments - None of the "advanced" like sound reservations and decay are invoked.
  * We just parse it, line by line, play the note, and move on, without handling anything else.
  * Legacy mode is kept due to the so called "legacy" instruments having a different sound to them, that can't
  * easily be replicated by synthesized ones yet.
  */
/datum/song/proc/do_play_lines_legacy(mob/user)
	while(repeat >= 0)
		var/cur_oct[7]
		var/cur_acc[7]
		for(var/i = 1 to 7)
			cur_oct[i] = 3
			cur_acc[i] = "n"

		for(var/line in lines)
			for(var/beat in splittext(lowertext(line), ","))
				if(should_stop_playing(user))
					return
				var/list/notes = splittext(beat, "/")
				if(length(notes))		//because some jack-butts are going to do ,,,, to symbolize 3 rests instead of something reasonable like ,/1.
					for(var/note in splittext(notes[1], "-"))
						if(length(note) == 0)
							continue
						var/cur_note = text2ascii(note) - 96
						if(cur_note < 1 || cur_note > 7)
							continue
						for(var/i=2 to length(note))
							var/ni = copytext(note,i,i+1)
							if(!text2num(ni))
								if(ni == "#" || ni == "b" || ni == "n")
									cur_acc[cur_note] = ni
								else if(ni == "s")
									cur_acc[cur_note] = "#" // so shift is never required
							else
								cur_oct[cur_note] = text2num(ni)
						playnote_legacy(cur_note, cur_acc[cur_note], cur_oct[cur_note], user)
				if(notes.len >= 2 && text2num(notes[2]))
					sleep(sanitize_tempo(tempo / text2num(notes[2])))
				else
					sleep(tempo)
		if(should_stop_playing(user))
			return
		repeat--
		updateDialog()
	repeat = 0

/**
  * Proc to play a legacy note. Just plays the sound to hearing mobs (and does hearcheck if necessary), no fancy channel/sustain/management.
  *
  * Arguments:
  * * note is a number from 1-7 for A-G
  * * acc is either "b", "n", or "#"
  * * oct is 1-8 (or 9 for C)
  */
/datum/song/proc/playnote_legacy(note, acc as text, oct, mob/user)
	// handle accidental -> B<>C of E<>F
	if(acc == "b" && (note == 3 || note == 6)) // C or F
		if(note == 3)
			oct--
		note--
		acc = "n"
	else if(acc == "#" && (note == 2 || note == 5)) // B or E
		if(note == 2)
			oct++
		note++
		acc = "n"
	else if(acc == "#" && (note == 7)) //G#
		note = 1
		acc = "b"
	else if(acc == "#") // mass convert all sharps to flats, octave jump already handled
		acc = "b"
		note++

	// check octave, C is allowed to go to 9
	if(oct < 1 || (note == 3 ? oct > 9 : oct > 8))
		return

	// now generate name
	var/soundfile = "sound/instruments/[cached_legacy_dir]/[ascii2text(note+64)][acc][oct].[cached_legacy_ext]"
	soundfile = file(soundfile)
	// make sure the note exists
	if(!fexists(soundfile))
		return
	// and play
	var/turf/source = get_turf(parent)
	if((world.time - MUSICIAN_HEARCHECK_MINDELAY) > last_hearcheck)
		do_hearcheck()
	var/sound/music_played = sound(soundfile)
	for(var/i in hearing_mobs)
		var/mob/M = i
		if(user && HAS_TRAIT(user, TRAIT_MUSICIAN) && isliving(M))
			var/mob/living/L = M
			L.apply_status_effect(STATUS_EFFECT_GOOD_MUSIC)
		if(!(M?.client?.prefs?.toggles & SOUND_INSTRUMENTS))
			continue
		M.playsound_local(source, null, volume * using_instrument.volume_multiplier, falloff = 5, S = music_played)
		// Could do environment and echo later but not for now
