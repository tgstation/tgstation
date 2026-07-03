#define AUTO_UNISON_RADIUS 5

/datum/song
	var/auto_unison_enabled = FALSE
	var/last_unison_check = 0
	var/list/multi_tracks = list()
	var/multi_sync_enabled = FALSE
	var/ignore_play_checks = FALSE

/datum/song/proc/ds_per_beat()
	return max(1, round(600 / max(1, bpm)))

/datum/song/proc/force_start_playing()
	ignore_play_checks = TRUE
	start_playing(parent)

/datum/song/proc/transmit_song_to(datum/song/other)
	if(!istype(other))
		return

	other.lines = islist(lines) ? lines.Copy() : list()
	other.tempo = tempo
	other.bpm = bpm
	other.max_repeats = max_repeats
	other.compile_chords()

/datum/song/proc/receive_song_from(datum/song/master)
	if(!istype(master))
		return

	lines = islist(master.lines) ? master.lines.Copy() : list()
	tempo = master.tempo
	bpm = master.bpm
	max_repeats = master.max_repeats
	compile_chords()

/datum/song/proc/songs_by_id(target_id as text, require_in_view = TRUE)
	var/list/out = list()
	if(!istext(target_id) || !length(target_id))
		return out

	for(var/datum/song/S as anything in SSinstruments.songs)
		if(S == src)
			continue
		if(S.id != target_id)
			continue
		if(require_in_view)
			var/atom/other_player = S.find_sync_player()
			if(isnull(other_player) || !(other_player in view(parent)))
				continue
		out += S
	return out

/datum/song/proc/try_auto_unison_once()
	if(playing)
		return

	var/turf/src_turf = get_turf(parent)
	if(!src_turf)
		return

	var/datum/song/master

	for(var/datum/song/S as anything in SSinstruments.songs)
		if(S == src)
			continue
		if(!S.playing)
			continue
		if(S.auto_unison_enabled)
			continue
		var/turf/obj_turf = get_turf(S.parent)
		if(!obj_turf)
			continue
		if(get_dist(src_turf, obj_turf) > AUTO_UNISON_RADIUS)
			continue
		master = S
		break

	if(!master)
		return

	receive_song_from(master)
	force_start_playing()

	if(!playing)
		return

	current_chord = clamp(master.current_chord, 1, length(compiled_chords))
	elapsed_delay = 0
	delay_by = 0

/datum/song/handheld/should_stop_playing(atom/player)
	if(ignore_play_checks)
		return NONE

	. = ..()

	if(. == STOP_PLAYING || . == IGNORE_INSTRUMENT_CHECKS)
		return

	var/obj/item/instrument/I = parent
	return I.can_play(player) ? NONE : STOP_PLAYING

/datum/song/stationary/should_stop_playing(atom/player)
	if(ignore_play_checks)
		return NONE

	. = ..()

	if(. == STOP_PLAYING || . == IGNORE_INSTRUMENT_CHECKS)
		return TRUE

	var/obj/structure/musician/M = parent
	return M.can_play(player) ? NONE : STOP_PLAYING

/datum/song/ui_data(mob/user)
	var/list/data = ..()
	data["auto_unison_enabled"] = auto_unison_enabled
	data["multi_sync_enabled"] = multi_sync_enabled
	var/list/out = list()
	for(var/i in 1 to multi_tracks.len)
		var/list/T = multi_tracks[i]
		out += list(list("target_id" = T["target_id"], "delay_beats" = T["delay_beats"]))

	data["multi_tracks"] = out
	return data

/datum/song/ui_act(action, list/params)
	switch(action)
		if("toggle_auto_unison")
			auto_unison_enabled = !auto_unison_enabled
			if(auto_unison_enabled)
				START_PROCESSING(SSinstruments, src)
			return TRUE
		if("toggle_multi_sync")
			multi_sync_enabled = !multi_sync_enabled
			return TRUE
		if("ms_add")
			multi_tracks += list(list("target_id"=null, "delay_beats"=0))
			return TRUE
		if("ms_del")
			var/idx = max(1, round(text2num(params["idx"])))
			if(idx <= multi_tracks.len)
				multi_tracks.Cut(idx, idx+1)
			return TRUE
		if("ms_set")
			var/idx2 = max(1, round(text2num(params["idx"])))
			if(idx2 > multi_tracks.len) return FALSE
			var/list/T = multi_tracks[idx2]
			var/field = "[params["field"]]"
			if(field == "target_id")
				var/t = isnull(params["value"]) ? "" : "[params["value"]]"
				T["target_id"] = length(t) ? t : null
				return TRUE
			if(field == "delay_beats")
				T["delay_beats"] = max(0, round(text2num(params["value"])))
				return TRUE
			return FALSE

		if("set_instrument_id")
			var/new_id = "[params["id"]]"
			new_id = trim(new_id)
			id = length(new_id) ? new_id : ""
			return TRUE

	return ..()

/datum/song/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InstrumentEditor220", parent.name) // BANDASTATION EDIT - New Instrument Synchronisation
		ui.open()
