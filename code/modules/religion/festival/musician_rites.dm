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

/datum/religion_rites/song_tuner/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	user.AddComponent(/datum/component/smooth_tunes, src, repeats_okay)

/**
  * Perform the song effect.
  *
  * Arguments:
  * * arg1 - Atom (parent) of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
  */
/datum/religion_rites/song_tuner/proc/song_effect(atom/A, datum/song/S)
	return

/datum/religion_rites/song_tuner/evangelism
	name = "Evangelical Hymn"
	desc = "Spreads the word of your god, gaining favor for each non-holy listener."
	favor_cost = 0

/datum/religion_rites/song_tuner/evangelism/song_effect(atom/A, datum/song/S)
	if(!S || !GLOB.religious_sect)
		return
	for(var/i in S.hearing_mobs)
		if(i == A)
			continue
		if(!isliving(i))
			continue //stinky ghosts
		var/mob/living/L = i
		if(L.mind.holy_role)
			continue
		GLOB.religious_sect.adjust_favor(0.2)

/datum/religion_rites/song_tuner/sooth
	name = "Soothing Hymn"
	desc = "Sing a sweet song, healing bruises and burns around you."
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/sooth/song_effect(atom/A, datum/song/S)
	if(!S)
		return
	for(var/i in S.hearing_mobs)
		if(i == A)
			continue
		if(!isliving(i))
			continue
		var/mob/living/L = i
		var/healy_juice = 0.25
		if(L.mind.holy_role)
			healy_juice*=3
		L.adjustBruteLoss(-healy_juice)
		L.adjustFireLoss(-healy_juice)

/datum/religion_rites/song_tuner/pain
	name = "Sorrow Song"
	desc = "Sing a melancholic song, hurting those around you. Works less effectively on fellow priests."
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/pain/song_effect(atom/A, datum/song/S)
	if(!S)
		return
	for(var/i in S.hearing_mobs)
		if(i == A)
			continue
		if(!isliving(i))
			continue
		var/mob/living/L = i
		var/pain_juice = 0.5
		if(L.mind.holy_role)
			pain_juice*=0.5
		L.adjustBruteLoss(pain_juice)
		L.adjustFireLoss(pain_juice)

/datum/religion_rites/song_tuner/lullaby
	name = "Lullaby"
	desc = "Sing a lullaby, tiring those around you and eventually putting them to sleep. Does not work on fellow priests."
	favor_cost = 20
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/lullaby/song_effect(atom/A, datum/song/S)
	if(!S)
		return
	for(var/i in S.hearing_mobs)
		if(i == A)
			continue
		if(!isliving(i))
			continue
		var/mob/living/L = i
		if(L.mind.holy_role)
			continue
		L.drowsyness += 5
		if(L.drowsyness >= 100)
			L.AdjustSleeping(3 SECONDS)
