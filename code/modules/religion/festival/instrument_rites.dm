/datum/religion_rites/holy_violin
	name = "Cogitandi Fidis"
	desc = "Creates a holy violin that can analyze songs played from it."
	ritual_length = 6 SECONDS
	ritual_invocations = list("A servant of jubilee is needed ...")
	invoke_msg = "... A great mind for musical matters!"
	favor_cost = 20 //you only need one

/datum/religion_rites/holy_violin/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/turf/tool_turf = get_turf(religious_tool)
	var/obj/item/instrument/violin/fidis = new /obj/item/instrument/violin/festival(get_turf(religious_tool))
	fidis.visible_message(span_notice("[fidis] appears!"))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)

/datum/religion_rites/portable_song_tuning
	name = "Portable Song Tuning"
	desc = "Empowers an instrument on the table to work as a portable altar for tuning songs. Will need to be recharged after 5 rites."
	ritual_length = 6 SECONDS
	ritual_invocations = list("Allow me to bring your holy inspirations ...")
	invoke_msg = "... And send them with the winds my tunes ride with!"
	favor_cost = 10
	///instrument to empower
	var/obj/item/instrument/instrument_target

/datum/religion_rites/portable_song_tuning/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/instrument/could_empower in get_turf(religious_tool))
		instrument_target = could_empower
		return ..()
	to_chat(user, span_warning("You need to place an instrument on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/portable_song_tuning/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/instrument/empower_target = instrument_target
	var/turf/tool_turf = get_turf(religious_tool)
	instrument_target = null
	if(QDELETED(empower_target) || !(tool_turf == empower_target.loc)) //check if the instrument is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	empower_target.visible_message(span_notice("[empower_target] glows for a moment."))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)
	var/list/allowed_rites_from_bible = subtypesof(/datum/religion_rites/song_tuner)
	empower_target.AddComponent( \
		/datum/component/religious_tool, \
		operation_flags = RELIGION_TOOL_INVOKE, \
		force_catalyst_afterattack = FALSE, \
		after_sect_select_cb = null, \
		catalyst_type = /obj/item/book/bible, \
		charges = 5, \
		rite_types_allowlist = allowed_rites_from_bible, \
	)
	return TRUE

///prototype for rites that tune a song.
/datum/religion_rites/song_tuner
	name = "Tune Song"
	desc = "this is a prototype."
	ritual_length = 10 SECONDS
	favor_cost = 10
	auto_delete = FALSE
	///if repeats count as continuations instead of a song's end, TRUE
	var/repeats_okay = TRUE
	///personal message sent to the chaplain as feedback for their chosen song
	var/song_invocation_message = "beep borp you forgot to fill in a variable report to git hub"
	///visible message sent to indicate a song will have special properties
	var/song_start_message
	///particle effect of playing this tune
	var/particles_path = /particles/musical_notes
	///what the instrument will glow when playing
	var/glow_color = COLOR_BLACK

/datum/religion_rites/song_tuner/invoke_effect(mob/living/user, obj/structure/altar_of_gods/altar)
	. = ..()
	to_chat(user, span_notice(song_invocation_message))
	user.AddComponent(/datum/component/smooth_tunes, src, repeats_okay, particles_path, glow_color)

/**
 * Song effect applied when the performer starts playing.
 *
 * Arguments:
 * * performer - A human starting the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/performer_start_effect(mob/living/carbon/human/performer, atom/song_source)
	return

/**
 * Perform the song effect.
 *
 * Arguments:
 * * listener - A mob, listening to the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/song_effect(mob/living/carbon/human/listener, atom/song_source)
	return

/**
 * When the song is long enough, it will have a special effect when it ends.
 *
 * If you want something that ALWAYS goes off regardless of song length, affix it to the Destroy proc. The rite is destroyed when smooth tunes is done.
 *
 * Arguments:
 * * listener - A mob, listening to the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	return

/datum/religion_rites/song_tuner/evangelism
	name = "Evangelical Hymn"
	desc = "Spreads the word of your god, gaining favor for each non-holy listener. At the end of the song, you'll bless all listeners, improving mood."
	particles_path = /particles/musical_notes/holy
	song_invocation_message = "You've prepared a holy song!"
	song_start_message = span_notice("This music sounds blessed!")
	glow_color = "#FEFFE0"
	favor_cost = 0

/datum/religion_rites/song_tuner/evangelism/song_effect(mob/living/carbon/human/listener, atom/song_source)
	// A ckey requirement is good to have for gaining favor, to stop monkey farms and such.
	if(!GLOB.religious_sect || listener.mind?.holy_role || !listener.ckey)
		return
	GLOB.religious_sect.adjust_favor(0.2)

/datum/religion_rites/song_tuner/evangelism/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	listener.add_mood_event("blessing", /datum/mood_event/blessing)

/datum/religion_rites/song_tuner/light
	name = "Illuminating Solo"
	desc = "Sing a bright song, lighting up the area around you. At the end of the song, you'll give some illumination to listeners."
	particles_path = /particles/musical_notes/light
	song_invocation_message = "You've prepared a bright song!"
	song_start_message = span_notice("This music simply glows!")
	glow_color = "#fcff44"
	repeats_okay = FALSE
	favor_cost = 0
	/// lighting object that makes chaplain glow
	var/obj/effect/dummy/lighting_obj/moblight/performer_light_obj

/datum/religion_rites/song_tuner/light/performer_start_effect(mob/living/carbon/human/performer, atom/song_source)
	performer_light_obj = performer.mob_light(8, 1.5, color = LIGHT_COLOR_DIM_YELLOW)

/datum/religion_rites/song_tuner/light/Destroy()
	QDEL_NULL(performer_light_obj)
	. = ..()

/datum/religion_rites/song_tuner/light/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	listener.apply_status_effect(/datum/status_effect/song/light)

/datum/religion_rites/song_tuner/nullwave
	name = "Nullwave Vibrato"
	desc = "Sing a dull song, protecting those who listen from magic."
	particles_path = /particles/musical_notes/nullwave
	song_invocation_message = "You've prepared an antimagic song!"
	song_start_message = span_nicegreen("This music makes you feel protected!")
	glow_color = "#a9a9b8"
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/nullwave/song_effect(mob/living/carbon/human/listener, atom/song_source)
	listener.apply_status_effect(/datum/status_effect/song/antimagic)

/datum/religion_rites/song_tuner/pain
	name = "Murderous Chord"
	desc = "Sing a sharp song, cutting those around you. Works less effectively on fellow priests. At the end of the song, you'll open the wounds of all listeners."
	particles_path = /particles/musical_notes/harm
	song_invocation_message = "You've prepared a painful song!"
	song_start_message = span_danger("This music cuts like a knife!")
	glow_color = "#FF4460"
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/pain/song_effect(mob/living/carbon/human/listener, atom/song_source)
	var/damage_dealt = 1
	if(listener.mind?.holy_role)
		damage_dealt *= 0.5

	listener.adjustBruteLoss(damage_dealt)

/datum/religion_rites/song_tuner/pain/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	var/obj/item/bodypart/sliced_limb = pick(listener.bodyparts)
	sliced_limb.force_wound_upwards(/datum/wound/slash/flesh/moderate/many_cuts)

/datum/religion_rites/song_tuner/lullaby
	name = "Spiritual Lullaby"
	desc = "Sing a lullaby, tiring those around you, making them slower. At the end of the song, you'll put people who are tired enough to sleep."
	particles_path = /particles/musical_notes/sleepy
	song_invocation_message = "You've prepared a sleepy song!"
	song_start_message = span_warning("This music's making you feel drowsy...")
	favor_cost = 40 //actually really strong
	glow_color = "#83F6FF"
	repeats_okay = FALSE
	///assoc list of weakrefs to who heard the song, for the finishing effect to look at.
	var/list/listener_counter = list()

/datum/religion_rites/song_tuner/lullaby/Destroy()
	listener_counter.Cut()
	return ..()

/datum/religion_rites/song_tuner/lullaby/song_effect(mob/living/carbon/human/listener, atom/song_source)
	if(listener.mind?.holy_role)
		return

	var/static/list/sleepy_messages = list(
		"The music is putting you to sleep...",
		"The music makes you nod off for a moment.",
		"You try to focus on staying awake through the song.",
	)

	if(prob(20))
		to_chat(listener, span_warning(pick(sleepy_messages)))
		listener.emote("yawn")
	listener.set_eye_blur_if_lower(4 SECONDS)

/datum/religion_rites/song_tuner/lullaby/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	to_chat(listener, span_danger("Wow, the ending of that song was... pretty..."))
	listener.AdjustSleeping(5 SECONDS)
