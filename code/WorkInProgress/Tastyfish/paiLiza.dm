/datum/paiCandidate/chatbot
	name = "NT Standard Chatbot"
	description = "NT Standard Issue pAI Unit 13A"
	role = "Advisor"
	comments = "This is an actual AI."
	ready = 1

/mob/living/silicon/pai/chatbot
	var/datum/text_parser/parser/eliza/P = new()

	proc/init()
		P.speaker = src
		P.callsign = input("What do you want to call me?", "Chatbot Name", "NT") as text
		P.set_name(P.callsign)
		P.new_session()

	proc/hear_talk(mob/M, text)
		if(stat)
			return

		var/prefix = P.callsign + ","

		if(lentext(text) <= lentext(prefix))
			return
		var/i = lentext(prefix) + 1
		if(cmptext(copytext(text, 1, i), prefix))
			P.input_line = html_decode(copytext(text, i))
			P.process_line()
