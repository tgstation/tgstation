TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT
	/// Biggest calculated char width. Used if character is not included in the list bellow. Includes all font sizes.
	var/list/max_char_width = list(0, 0, 0)
	/// List of most characters in the font. Do not varedit it in game.
	/// Format of it is as follows: character, size when normal, size when small, size when big.
	var/list/letters = list(
		//Special case, measuring " " returns 0 since it's empty string
		" " = list(2, 2, 2),
		"." = null,
		"," = null,
		"?" = null,
		"!" = null,
		"\"" = null,
		"/" = null,
		"$" = null,
		"(" = null,
		")" = null,
		"@" = null,
		"=" = null,
		":" = null,
		"'" = null,
		";" = null,
		"+" = null,
		"-" = null,
		"\\" = null,
		"<" = null,
		">" = null,
		"&" = null,
		"*" = null,
		"%" = null,
		"^" = null,
		"{" = null,
		"}" = null,
		"|" = null,
		"~" = null,
		"`" = null,
		"A" = null,
		"B" = null,
		"C" = null,
		"D" = null,
		"E" = null,
		"F" = null,
		"G" = null,
		"H" = null,
		"I" = null,
		"J" = null,
		"K" = null,
		"L" = null,
		"M" = null,
		"N" = null,
		"O" = null,
		"P" = null,
		"Q" = null,
		"R" = null,
		"S" = null,
		"T" = null,
		"U" = null,
		"V" = null,
		"W" = null,
		"X" = null,
		"Y" = null,
		"Z" = null,
		"a" = null,
		"b" = null,
		"c" = null,
		"d" = null,
		"e" = null,
		"f" = null,
		"g" = null,
		"h" = null,
		"i" = null,
		"j" = null,
		"k" = null,
		"l" = null,
		"m" = null,
		"n" = null,
		"o" = null,
		"p" = null,
		"q" = null,
		"r" = null,
		"s" = null,
		"t" = null,
		"u" = null,
		"v" = null,
		"w" = null,
		"x" = null,
		"y" = null,
		"z" = null
	)

/datum/controller/subsystem/timer/runechat/PreInit()
	. = ..()
	init_runechat_list()

/datum/controller/subsystem/timer/runechat/proc/init_runechat_list()
	if(!length(GLOB.clients))
		addtimer(CALLBACK(src, .proc/init_runechat_list), 1 SECONDS, null, src)
		return

	var/client/first_client = GLOB.clients[1]

	for(var/key in letters)
		if(!first_client)
			if(!length(GLOB.clients))
				addtimer(CALLBACK(src, .proc/init_runechat_list), 1 SECONDS, null, src)
				return
			first_client = GLOB.clients[1]
		if(length(letters[key]) == 3 || key == " ")
			continue

		letters[key] = list(null, null, null)
		letters[key][NORMAL_FONT_INDEX] = WXH_TO_WIDTH(first_client.MeasureText(MAPTEXT(key)))
		if(letters[key][NORMAL_FONT_INDEX] > max_char_width[NORMAL_FONT_INDEX])
			max_char_width[NORMAL_FONT_INDEX] = letters[key][NORMAL_FONT_INDEX]
		if(!first_client)
			if(!length(GLOB.clients))
				addtimer(CALLBACK(src, .proc/init_runechat_list), 1 SECONDS, null, src)
				return
			first_client = GLOB.clients[1]

		letters[key][SMALL_FONT_INDEX] = WXH_TO_WIDTH(first_client.MeasureText("<span class='small'>[key]</span>"))
		if(letters[key][SMALL_FONT_INDEX] > max_char_width[SMALL_FONT_INDEX])
			max_char_width[SMALL_FONT_INDEX] = letters[key][SMALL_FONT_INDEX]
		if(!first_client)
			if(!length(GLOB.clients))
				addtimer(CALLBACK(src, .proc/init_runechat_list), 1 SECONDS, null, src)
				return
			first_client = GLOB.clients[1]

		letters[key][BIG_FONT_INDEX] = WXH_TO_WIDTH(first_client.MeasureText("<span class='big'>[key]</span>"))
		if(letters[key][BIG_FONT_INDEX] > max_char_width[BIG_FONT_INDEX])
			max_char_width[BIG_FONT_INDEX] = letters[key][BIG_FONT_INDEX]
