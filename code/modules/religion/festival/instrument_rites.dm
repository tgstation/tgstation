///prototype for rites that tune a song.
/datum/religion_rites/song_tuner
	name = "Tune Song"
	desc = "this is a prototype."
	ritual_length = 10 SECONDS
	favor_cost = 10
	///if repeats count as continuations instead of a song's end, TRUE
	var/repeats_okay = TRUE
	///personal message sent to the chaplain as feedback for their chosen song
	var/song_invocation_message = "beep borp you forgot to fill in a variable report to git hub"
	///visible message sent to indicate a song will have special properties
	var/song_start_message
	///particle effect of playing this tune
	var/particles_path = /particles/musical_notes
	///what the instrument will glow when playing
	var/glow_color = "#000000"

/datum/religion_rites/song_tuner/invoke_effect(mob/living/user, obj/structure/altar_of_gods/altar)
	. = ..()
	to_chat(user, span_notice(song_invocation_message))
	user.AddComponent(/datum/component/smooth_tunes, src, repeats_okay, particles_path, glow_color)

/**
 * Perform the song effect.
 *
 * Arguments:
 * * song_player - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 * * song_datum - Datum song being played
 */
/datum/religion_rites/song_tuner/proc/song_effect(atom/song_player, datum/song/song_datum)
	return

/**
 * When the song is long enough, it will have a special effect when it ends.
 *
 * Arguments:
 * * song_player - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 * * song_datum - Datum song being played
 */
/datum/religion_rites/song_tuner/proc/finish_effect(atom/song_player, datum/song/song_datum)
	return

/datum/religion_rites/song_tuner/evangelism
	name = "Evangelical Hymn"
	desc = "Spreads the word of your god, gaining favor for each non-holy listener. At the end of the song, you'll bless all listeners, improving mood."
	particles_path = /particles/musical_notes/holy
	song_invocation_message = "You've prepared a holy song!"
	song_start_message = span_notice("This music sounds blessed!")
	glow_color = "#FEFFE0"
	favor_cost = 0

/datum/religion_rites/song_tuner/evangelism/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum || !GLOB.religious_sect)
		return
	for(var/mob/living/carbon/human/listener in song_datum.hearing_mobs)
		if(listener == song_player || listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		if(listener.mind?.holy_role)
			continue
		if(!listener.ckey) //good requirement to have for favor, trust me
			continue
		GLOB.religious_sect.adjust_favor(0.2)

/datum/religion_rites/song_tuner/evangelism/finish_effect(atom/song_player, datum/song/song_datum)
	for(var/mob/living/carbon/human/listener in song_datum.hearing_mobs)
		SEND_SIGNAL(listener, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)

/datum/religion_rites/song_tuner/sooth
	name = "Mending Chord"
	desc = "Sing a sweet song, healing bruises and burns around you. At the end of a song, you'll seal one wound."
	particles_path = /particles/musical_notes/heal
	song_invocation_message = "You've prepared a healing song!"
	song_start_message = span_nicegreen("This music is closing your wounds!")
	glow_color = "#44FF84"
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/sooth/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		var/healy_juice = 0.6
		if(listener.mind?.holy_role)
			healy_juice*=3
		listener.adjustBruteLoss(-healy_juice)
		listener.adjustFireLoss(-healy_juice)

/datum/religion_rites/song_tuner/sooth/finish_effect(atom/song_player, datum/song/song_datum)
	for(var/mob/living/carbon/human/listener in song_datum.hearing_mobs)
		if(!listener.all_wounds.len)
			continue
		var/datum/wound/soothed_wound = pick(listener.all_wounds)
		soothed_wound.remove_wound()

/datum/religion_rites/song_tuner/pain
	name = "Murderous Chord"
	desc = "Sing a sharp song, cutting those around you. Works less effectively on fellow priests. At the end of the song, you'll open the wounds of all listeners."
	particles_path = /particles/musical_notes/harm
	song_invocation_message = "You've prepared a painful song!"
	song_start_message = span_danger("This music cuts like a knife!")
	glow_color = "#FF4460"
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/pain/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		var/pain_juice = 1
		if(listener.mind?.holy_role)
			pain_juice *= 0.5
		listener.adjustBruteLoss(pain_juice)

/datum/religion_rites/song_tuner/pain/finish_effect(atom/song_player, datum/song/song_datum)
	for(var/mob/living/carbon/human/listener in song_datum.hearing_mobs)
		var/obj/item/bodypart/sliced_limb = pick(listener.bodyparts)
		sliced_limb.force_wound_upwards(/datum/wound/slash/moderate/many_cuts)

/datum/religion_rites/song_tuner/lullaby
	name = "Spiritual Lullaby"
	desc = "Sing a lullaby, tiring those around you, making them slower. At the end of the song, you'll put people who are tired enough to sleep."
	particles_path = /particles/musical_notes/sleepy
	song_invocation_message = "You've prepared a sleepy song!"
	song_start_message = span_warning("This music's making you feel drowsy...")
	favor_cost = 40 //actually really strong
	glow_color = "#83F6FF"
	repeats_okay = FALSE
	///assoc list of weakrefs to who heard the song and
	var/list/listener_counter = list()

/datum/religion_rites/song_tuner/lullaby/Destroy()
	QDEL_NULL(listener_counter)
	. = ..()

/datum/religion_rites/song_tuner/lullaby/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		if(listener.mind?.holy_role)
			continue
		if(prob(20))
			to_chat(listener, span_warning(pick("The music is putting you to sleep...", "The music makes you nod off for a moment.", "You try to focus on staying awake through the song.")))
		listener.blur_eyes(2)
		listener_counter[WEAKREF(listener)] += 5

/datum/religion_rites/song_tuner/lullaby/finish_effect(atom/song_player, datum/song/song_datum)
	for(var/datum/weakref/listener_weakref in listener_counter)
		var/mob/living/listener = listener_weakref.resolve()
		if(!listener)
			continue
		if(listener_counter[listener_weakref] >= 100)
			listener.AdjustSleeping(10 SECONDS)

/datum/religion_rites/song_tuner/power
	name = "Power Chord"
	desc = "Sing a powerful tune, speeding up listeners. At the end of the song, Ethereals fully recharge."
	particles_path = /particles/musical_notes/power
	song_invocation_message = "You've prepared a powerful song!"
	song_start_message = span_warning("This music's making you feel excited!")
	favor_cost = 20
	glow_color = "#E8E822"
	repeats_okay = FALSE
	///after each process, the song's listeners are recorded so people who are
	var/list/last_hearers = list()

/datum/religion_rites/song_tuner/power/song_effect(atom/song_player, datum/song/song_datum)
	if(!song_datum)
		return
	for(var/mob/living/last_listener as anything in last_hearers)
		if(!(last_listener in song_datum.hearing_mobs))
			last_listener.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/power_chord)
			last_listener.remove_actionspeed_modifier(/datum/actionspeed_modifier/power_chord)
	for(var/mob/living/listener in song_datum.hearing_mobs)
		if(listener.anti_magic_check(magic = FALSE, holy = TRUE))
			continue
		if(listener.mind?.holy_role)
			continue
		if(prob(20))
			to_chat(listener, span_warning(pick("The music is hyping you up!", "The music makes you feel amp'd up.", "This song is electric!")))
		if(listener in last_hearers)
			listener.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/power_chord)
			listener.add_actionspeed_modifier(/datum/actionspeed_modifier/power_chord)
	last_hearers = song_datum.hearing_mobs

/datum/religion_rites/song_tuner/power/finish_effect(atom/song_player, datum/song/song_datum)
	for(var/mob/living/carbon/human/listener in song_datum.hearing_mobs)
		var/obj/item/organ/stomach/ethereal/stomach = listener.getorganslot(ORGAN_SLOT_STOMACH)
		if(!istype(stomach))
			continue
		stomach.crystal_charge = ETHEREAL_CHARGE_FULL

/datum/religion_rites/song_tuner/power/Destroy()
	QDEL_NULL(last_hearers)
	. = ..()
