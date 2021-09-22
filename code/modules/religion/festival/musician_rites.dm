///prototype for rites that tune a song.
/datum/religion_rites/song_tuner
	name = "Tune Song"
	desc = "this is a base."
	ritual_length = 10 SECONDS
	favor_cost = 10
	///if repeats count as continuations instead of a song's end, TRUE
	var/repeats_okay = TRUE
	///visible message sent to indicate a song will have special properties
	var/visible_message

/datum/religion_rites/song_tuner/invoke_effect(mob/living/user, obj/structure/altar_of_gods/altar)
	. = ..()
	user.AddComponent(/datum/component/smooth_tunes, src, repeats_okay)

/**
  * Perform the song effect.
  *
  * Arguments:
  * * arg1 - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
  * * song_datum - Datum song being played
  */
/datum/religion_rites/song_tuner/proc/song_effect(atom/song_player, datum/song/song_datum)
	return

/datum/religion_rites/song_tuner/evangelism
	name = "Evangelical Hymn"
	desc = "Spreads the word of your god, gaining favor for each non-holy listener."
	favor_cost = 0

/datum/religion_rites/song_tuner/evangelism/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum || !GLOB.religious_sect)
		return
	for(var/mob/living/carbon/human/listener in song_datum.hearing_mobs)
		if(listener == song_player || listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		if(listener.mind.holy_role)
			continue
		if(!listener.ckey) //good requirement to have for favor, trust me
			continue
		GLOB.religious_sect.adjust_favor(0.2)

/datum/religion_rites/song_tuner/sooth
	name = "Soothing Hymn"
	desc = "Sing a sweet song, healing bruises and burns around you."
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/sooth/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener == song_player || listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		var/healy_juice = 0.25
		if(listener.mind.holy_role)
			healy_juice*=3
		listener.adjustBruteLoss(-healy_juice)
		listener.adjustFireLoss(-healy_juice)

/datum/religion_rites/song_tuner/pain
	name = "Sorrow Song"
	desc = "Sing a melancholic song, hurting those around you. Works less effectively on fellow priests."
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/pain/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener == song_player || listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		var/pain_juice = 0.5
		if(listener.mind.holy_role)
			pain_juice*=0.5
		listener.adjustBruteLoss(pain_juice)
		listener.adjustFireLoss(pain_juice)

/datum/religion_rites/song_tuner/lullaby
	name = "Lullaby"
	desc = "Sing a lullaby, tiring those around you and eventually putting them to sleep. Does not work on fellow priests."
	favor_cost = 20
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/lullaby/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener == song_player || listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		if(listener.mind.holy_role)
			continue
		listener.drowsyness += 5
		if(listener.drowsyness >= 100)
			listener.AdjustSleeping(3 SECONDS)
