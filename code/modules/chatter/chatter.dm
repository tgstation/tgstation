/proc/chatter(message, phomeme, atom/speaker)
	// We want to transform any message into a list of numbers
	// and punctuation marks
	// For example:
	// "Hi." -> [2, '.']
	// "HALP GEROGE MELLONS, that swine, is GRIFFIN ME!"
	// -> [4, 6, 7, ',', 4, 5, ',', '2', 7, 2, '!']
	// "fuck,thissentenceissquashed" -> [4, ',', 21]

	var/regex/R = regex("(\[\\l\\d]*)(\[^\\l\\d\\s])?", "g")
	var/list/letter_count = list()
	while(R.Find(message) != 0)
		if(R.group[1])
			letter_count += length(R.group[1])
		if(R.group[2])
			letter_count += R.group[2]
	chatter_speak(speaker, letter_count, phomeme)

///We're going to take a list that dictates the pace of speech, and a sentence fragment to say
///Then say() that fragment at that pace
/proc/chatter_speak(atom/speaker, list/letter_count, phomeme)
	var/static/list/punctuation = list(",",":",";",".","?","!","\'","-")
	var/delay = 0
	for(var/i in 1 to length(letter_count))
		var/item = letter_count[i]
		if (item in punctuation)
			// simulate pausing in talking
			// ignore semi-colons because of their use in HTML escaping
			if (item in list(",", ":"))
				delay += 0.3 SECONDS
			if (item in list("!", "?", "."))
				delay += 0.6 SECONDS
			continue

		if(!isnum(item))
			continue
		letter_count.Cut(1, i + 1)
		var/list/current_context =  letter_count

		var/length = min(item, 10)
		if (length == 0)
			// "verbalise" long spaces
			delay += 0.1 SECONDS

		if(delay)
			addtimer(CALLBACK(null, /proc/chatter_speak_word, speaker, letter_count, phomeme, length), delay)
			return
		chatter_speak_word(speaker, current_context, phomeme, length)
		return

/proc/chatter_speak_word(atom/speaker, list/letter_count, phomeme, length)
	var/path = "sound/runtime/chatter/[phomeme]_[length].ogg"
	var/loc = speaker.loc
	playsound(loc, path,
		vol = 40, vary = 0, extrarange = 3)

	var/delay = (length + 1) * chatter_get_delay_multiplier(phomeme)
	addtimer(CALLBACK(null, /proc/chatter_speak, speaker, letter_count, phomeme), delay)

/proc/chatter_get_delay_multiplier(phomeme)
	. = 0.1 SECONDS
	switch(phomeme)
		if("papyrus")
			. = 0.05 SECONDS
		if("griffin")
			. = 0.05 SECONDS
		if("sans")
			. = 0.07 SECONDS
		if("owl")
			. = 0.07 SECONDS
