TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT
	/// List of most characters in the font. DO NOT CHANGE IT. ESPECIALLY VAREDIT.
	var/list/letters = list(
		//Special case, measuring " " returns 0 since it's empty string
		" " = 2,
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
		"z" = null,
		MAX_CHAR_WIDTH = 0
	)

/datum/controller/subsystem/timer/runechat/PreInit()
	. = ..()
	init_runechat_list()

/datum/controller/subsystem/timer/runechat/proc/init_runechat_list()
	if(!length(GLOB.clients))
		addtimer(CALLBACK(src, .proc/init_runechat_list), 1 SECONDS, null, src)
		return

	var/client/C = GLOB.clients[1]

	for(var/key in letters)
		if(!C)
			if(!length(GLOB.clients))
				addtimer(CALLBACK(src, .proc/init_runechat_list), 1 SECONDS, null, src)
				return
			C = GLOB.clients[1]
		if(letters[key] || key == " ")
			continue
		letters[key] = WXH_TO_WIDTH(C.MeasureText(MAPTEXT(key)))
		if(letters[key] > letters[MAX_CHAR_WIDTH])
			letters[MAX_CHAR_WIDTH] = letters[key]
