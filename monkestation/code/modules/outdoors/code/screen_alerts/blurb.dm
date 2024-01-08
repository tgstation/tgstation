//Based on code ported from Nebula. https://github.com/NebulaSS13/Nebula/pull/357

/**Shows a ticker reading out the given text on a client's screen.
targets = mob or list of mobs to show it to.
duration = how long it lingers after it finishes ticking.
message = the message to display. Due to using maptext it isn't very flexible format-wise. 11px font, up to 480 pixels per line.
Use \n for line breaks. Single-character HTML tags (<b>, <i>, <u> etc.) are handled correctly but others display strangely.
Note that maptext can display text macros in strange ways, ex. \improper showing as "ÿ". Lines containing only spaces,
including ones only containing "\improper ", don't display.
scroll_down = by default each line pushes the previous line upwards - this tells it to start high and scroll down.
Ticks on \n - does not autodetect line breaks in long strings.
screen_position = screen loc for the bottom-left corner of the blurb.
text_alignment = "right", "left", or "center"
text_color = colour of the text.
blurb_key = a key used for specific blurb types so they are not shown repeatedly. Ex. someone who joins as CLF repeatedly only seeing the mission blurb the first time.
ignore_key = used to skip key checks. Ex. a USCM ERT member shouldn't see the normal USCM drop message,
but should see their own spawn message even if the player already dropped as USCM.**/
/proc/show_blurb(list/mob/targets, duration = 3 SECONDS, message, scroll_down, screen_position = "LEFT+0:16,BOTTOM+1:16",\
	text_alignment = "left", text_color = "#FFFFFF", blurb_key, ignore_key = FALSE, speed = 1)
	set waitfor = FALSE
	if(!islist(targets))
		targets = list(targets)
	if(!length(targets))
		return

	var/style = "font-family: Fixedsys, monospace; -dm-text-outline: 1 black; font-size: 11px; text-align: [text_alignment]; color: [text_color];" //This font doesn't seem to respect pixel sizes.
	var/list/linebreaks = list() //Due to singular /'s making text disappear for a moment and for counting lines.

	var/linebreak = findtext(message, "\n")
	while(linebreak)
		linebreak++ //Otherwise it picks up the character immediately before the linebreak.
		linebreaks += linebreak
		linebreak = findtext(message, "\n", linebreak)

	var/list/html_tags = list()
	var/html_tag = findtext(message, regex("<.>"))
	var/opener = TRUE
	while(html_tag)
		html_tag++
		if(opener)
			html_tags += list(html_tag, html_tag + 1, html_tag + 2)
			html_tag = findtext(message, regex("<.>"), html_tag + 2)
			if(!html_tag)
				opener = FALSE
				html_tag = findtext(message, regex("</.>"))
		else
			html_tags += list(html_tag, html_tag + 1, html_tag + 2, html_tag + 3)
			html_tag = findtext(message, regex("</.>"), html_tag + 3)

	var/atom/movable/screen/text/T = new()
	T.screen_loc = screen_position
	switch(text_alignment)
		if("center")
			T.maptext_x = -(T.maptext_width * 0.5 - 16) //Centering the textbox.
		if("right")
			T.maptext_x = -(T.maptext_width - 32) //Aligning the textbox with the right edge of the screen object.
	if(scroll_down)
		T.maptext_y = length(linebreaks) * 14

	for(var/mob/M as anything in targets)
		if(blurb_key)
			if(!ignore_key && (M.key in GLOB.blurb_witnesses[blurb_key]))
				continue
			GLOB.blurb_witnesses[blurb_key] |= M.key
		M.client?.screen += T

	for(var/i in 1 to length(message) + 1)
		if(i in linebreaks)
			if(scroll_down)
				T.maptext_y -= 14 //Move the object to keep lines in the same place.
			continue
		if(i in html_tags)
			continue
		T.maptext = "<span style=\"[style]\">[copytext(message,1,i)]</span>"
		sleep(speed)

	addtimer(CALLBACK(GLOBAL_PROC, /proc/fade_blurb, targets, T), duration)

/proc/fade_blurb(list/mob/targets, obj/T)
	animate(T, alpha = 0, time = 0.5 SECONDS)
	sleep(5)
	for(var/mob/M as anything in targets)
		M.client?.screen -= T
	qdel(T)

/proc/show_blurb_all(duration = 3 SECONDS, message, scroll_down, screen_position = "LEFT+0:16,BOTTOM+1:16",\
	text_alignment = "left", text_color = "#FFFFFF", blurb_key, ignore_key = FALSE, speed = 1)
	show_blurb(GLOB.player_list, duration, message, scroll_down, screen_position, text_alignment, text_color, blurb_key, ignore_key, speed)
