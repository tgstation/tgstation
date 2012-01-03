// Contains:
//	/datum/text_parser/parser/eliza
//	/datum/text_parser/keyword

/datum/text_parser/parser/eliza
	//var/datum/text_parser/reply/replies[] // R(X) 36
	var/prev_reply = ""	// previous reply
	var/username = ""
	var/callsign = ""
	var/yesno_state = ""
	var/yesno_param = ""

/datum/text_parser/parser/eliza/new_session()
	..()
	for(var/datum/text_parser/keyword/key in keywords)
		key.eliza = src

	prev_reply = ""
	username = ""
	yesno_state = ""
	yesno_param = ""
	print("Hi! I'm [callsign], how are you doing? You can talk to me by beginning your statements with \"[callsign],\"")

/datum/text_parser/parser/eliza/process_line()
	..()
	// pad so we can detect initial and final words correctly
	input_line = " " + src.input_line + " "
	// remove apostrophes
	for(var/i = -1, i != 0, i = findtext(input_line, "'"))
		if(i == -1)
			continue
		input_line = copytext(input_line, 1, i) + copytext(input_line, i + 1, 0)

	// did user insult us? (i don't really want cursing in the source code,
	// so keep it the simple original check from the 70's code :p)
	if(findtext(input_line, "shut"))
		// sssh
		return

	if(input_line == prev_reply)
		print("Please don't repeat yourself!")

	// find a keyword
	var/keyphrase = ""
	var/datum/text_parser/keyword/keyword	// the actual keyword
	var/keypos = 0	// pos of keyword so we can grab extra text after it

	for(var/i = 1, i <= keywords.len, i++)
		keyword = keywords[i]
		for(var/j = 1, j <= keyword.phrases.len, j++)
			keypos = findtext(input_line, " " + keyword.phrases[j])
			if(keypos != 0)
				// found it!
				keyphrase = keyword.phrases[j]
				break
		if(keyphrase != "")
			break

	//world << "keyphrase: " + keyphrase + " " + num2text(keypos)

	var/conjugated = ""
	// was it not recognized? then make it nokeyfound
	if(keyphrase == "")
		keyword = keywords[keywords.len] // nokeyfound
	else
		// otherwise, business as usual

		// let's conjugate this mess
		conjugated = copytext(input_line, 1 + keypos + lentext(keyphrase))

		// go ahead and strip punctuation
		if(lentext(conjugated) > 0 && copytext(conjugated, lentext(conjugated)) == " ")
			conjugated = copytext(conjugated, 1, lentext(conjugated))
		if(lentext(conjugated) > 0)
			var/final_punc = copytext(conjugated, lentext(conjugated))
			if(final_punc == "." || final_punc == "?" || final_punc == "!")
				conjugated = copytext(conjugated, 1, lentext(conjugated))

		conjugated += " "

		if(keyword.conjugate)
			// now run through conjugation pairs
			for(var/i = 1, i <= lentext(conjugated), i++)
				for(var/x = 1, x <= conjugs.len, x += 2)
					var/cx = conjugs[x]
					var/cxa = conjugs[x + 1]
					if(i + lentext(cx) <= lentext(conjugated) + 1 && cmptext(cx, copytext(conjugated, i, i + lentext(cx))))
						// world << cx

						conjugated = copytext(conjugated, 1, i) + cxa + copytext(conjugated, i + lentext(cx))
						i = i + lentext(cx)
						// don't count right padding
						if(copytext(cx, lentext(cx)) == " ")
							i--
						break
					else if(i + lentext(cxa) <= lentext(conjugated) + 1 && cmptext(cxa, copytext(conjugated, i, i + lentext(cxa))))
						// world << cxa

						conjugated = copytext(conjugated, 1, i) + cx + copytext(conjugated, i + lentext(cxa))
						i = i + lentext(cxa)
						// don't count right padding
						if(copytext(cxa, lentext(cxa)) == " ")
							i--
						break

		conjugated = copytext(conjugated, 1, lentext(conjugated))

	//world << "Conj: " + conjugated

	// now actually get a reply
	var/reply = keyword.process(conjugated)
	print(reply)

	prev_reply = reply

/datum/text_parser/keyword
	var/list/phrases = new()
	var/list/replies = new()
	var/datum/text_parser/parser/eliza/eliza
	var/conjugate = 1

	New(p, r)
		phrases = p
		replies = r

	proc/process(object)
		eliza.yesno_state = ""
		eliza.yesno_param = ""
		var/reply = pick(replies)
		if(copytext(reply, lentext(reply)) == "*")
			// add object of statement (hopefully not actually mess :p)
			if(object == "")
				object = pick(generic_objects)
			// possibly add name or just ?
			if(eliza.username != "" && rand(3) == 0)
				object += ", " + eliza.username
			return copytext(reply, 1, lentext(reply)) + object + "?"
		else
			// get punct
			var/final_punc = ""
			if(lentext(reply) > 0)
				final_punc = copytext(reply, lentext(reply))
				if(final_punc == "." || final_punc == "?" || final_punc == "!")
					reply = copytext(reply, 1, lentext(reply))
				else
					final_punc = ""

			// possibly add name or just ?/./!
			if(eliza.username != "" && rand(2) == 0)
				reply += ", " + eliza.username

			return reply + final_punc
