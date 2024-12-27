/obj/item/instrument/violin/festival
	name = "Cogitandi Fidis"
	desc = "A violin that holds a special interest in the songs played from its strings."
	icon_state = "holy_violin"
	inhand_icon_state = "holy_violin"

/obj/item/instrument/violin/festival/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_INSTRUMENT_START, PROC_REF(on_instrument_start))

/// signal fired when the festival instrument starts to play.
/obj/item/instrument/violin/festival/proc/on_instrument_start(datum/source, datum/song/starting_song, atom/player)
	SIGNAL_HANDLER

	if(!starting_song || !isliving(player))
		return
	analyze_song(starting_song, player)

///Reports some relevant information when the song begins playing.
/obj/item/instrument/violin/festival/proc/analyze_song(datum/song/song, mob/living/playing_song)
	var/list/analysis = list()
	//check tempo and lines
	var/song_length = song.lines.len * song.tempo
	analysis += span_revenbignotice("[src] speaks to you...")
	analysis += span_revennotice("\"This song has <b>[song.lines.len]</b> lines and a tempo of <b>[song.tempo]</b>.\"")
	analysis += span_revennotice("\"Multiplying these together gives a song length of <b>[song_length]</b>.\"")
	analysis += span_revennotice("\"To get a bonus effect from [GLOB.deity] upon finishing a performance, you need a song length of <b>[FESTIVAL_SONG_LONG_ENOUGH]</b>.\"")

	to_chat(playing_song, analysis.Join("\n"))
