/mob/living/carbon/human/say_quote(text)
	if(!text)
		return "says, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (src.stuttering)
		return "stammers, \"[text]\"";
	if(isliving(src))
		var/mob/living/L = src
		if (L.getBrainLoss() >= 60)
			return "gibbers, \"[text]\"";
	if (ending == "?")
		return "asks, \"[text]\"";
	if (ending == "!")
		return "exclaims, \"[text]\"";

	if(dna)
		return "[dna.species.say_mod], \"[text]\"";

	return "says, \"[text]\"";

/mob/living/carbon/human/treat_message(message)
	if(dna)
		message = dna.species.handle_speech(message,src)
	if (dna.check_mutation(UNINTELLIGABLE))
		var/prefix=copytext(message,1,2)
		if(prefix == ";")
			message = copytext(message,2)
		else if(prefix in list(":","#"))
			prefix += copytext(message,2,3)
			message = copytext(message,3)
		else
			prefix=""

		var/list/words = text2list(message," ")
		var/list/rearranged = list()
		for(var/i=1;i<=words.len;i++)
			var/cword = pick(words)
			words.Remove(cword)
			var/suffix = copytext(cword,length(cword)-1,length(cword))
			while(length(cword)>0 && suffix in list(".",",",";","!",":","?"))
				cword  = copytext(cword,1              ,length(cword)-1)
				suffix = copytext(cword,length(cword)-1,length(cword)  )
			if(length(cword))
				rearranged += cword
		return "[prefix][uppertext(list2text(rearranged," "))]!!"
	if (dna.check_mutation(SWEDISH))
		message = replacetext(message,"w","v")
		if(prob(30))
			message += " Bork[pick("",", bork",", bork, bork")]!"
	if (dna.check_mutation(ELVIS))
		message = replacetext(message,"im not","I ain't")
		message = replacetext(message,"i'm not","I aint")
		message = replacetext(message," girl ",pick(" honey "," baby "," baby doll "))
		message = replacetext(message," man ",pick(" son "," buddy "," brother ", " pal ", " friendo "))
		message = replacetext(message,"out of","outta")
		message = replacetext(message,"thank you","thank you, thank you very much")
		message = replacetext(message,"what are you","whatcha")
		message = replacetext(message,"yes",pick("sure", "yea"))
		message = replacetext(message,"faggot","square")
		message = replacetext(message,"muh valids","getting my kicks")
	if (dna.check_mutation(CHAV))
		message = replacetext(message,"dick","prat")
		message = replacetext(message,"comdom","knob'ead")
		message = replacetext(message,"looking at","gawpin' at")
		message = replacetext(message,"great","bangin'")
		message = replacetext(message,"man","mate")
		message = replacetext(message,"friend",pick("mate","bruv","bledrin"))
		message = replacetext(message,"what","wot")
		message = replacetext(message,"drink","wet")
		message = replacetext(message,"get","giz")
		message = replacetext(message,"what","wot")
		message = replacetext(message,"no thanks","wuddent fukken do one")
		message = replacetext(message,"i don't know","wot mate")
		message = replacetext(message,"no","naw")
		message = replacetext(message,"robust","chin")
		message = replacetext(message," hi ","how what how")
		message = replacetext(message,"hello","sup bruv")
		message = replacetext(message,"kill","bang")
		message = replacetext(message,"murder","bang")
		message = replacetext(message,"windows","windies")
		message = replacetext(message,"window","windy")
		message = replacetext(message,"break","do")
		message = replacetext(message,"your","yer")
		message = replacetext(message,"security","coppers")
	if (dna.check_mutation(SMILE))
		//Time for a friendly game of SS13
		message = replacetext(message,"stupid","smart")
		message = replacetext(message,"retard","genius")
		message = replacetext(message,"unrobust","robust")
		message = replacetext(message,"dumb","smart")
		message = replacetext(message,"awful","great")
		message = replacetext(message,"gay",pick("nice","ok","alright"))
		message = replacetext(message,"horrible","fun")
		message = replacetext(message,"terrible","terribly fun")
		message = replacetext(message,"terrifying","wonderful")
		message = replacetext(message,"gross","cool")
		message = replacetext(message,"disgusting","amazing")
		message = replacetext(message,"loser","winner")
		message = replacetext(message,"useless","useful")
		message = replacetext(message,"oh god","cheese and crackers")
		message = replacetext(message,"jesus","gee wiz")
		message = replacetext(message,"weak","strong")
		message = replacetext(message,"kill","hug")
		message = replacetext(message,"murder","tease")
		message = replacetext(message,"ugly","beautiful")
		message = replacetext(message,"douchbag","nice guy")
		message = replacetext(message,"whore","lady")
		message = replacetext(message,"nerd","smart guy")
		message = replacetext(message,"moron","fun person")
		message = replacetext(message,"IT'S LOOSE","EVERYTHING IS FINE")
		message = replacetext(message,"rape","hug fight")
		message = replacetext(message,"idiot","genius")
		message = replacetext(message,"fat","thin")
		message = replacetext(message,"beer","water with ice")
		message = replacetext(message,"drink","water")
		message = replacetext(message,"feminist","empowered woman")
		message = replacetext(message,"i hate you","you're mean")
		message = replacetext(message,"nigger","african american")
		message = replacetext(message,"jew","jewish")
		message = replacetext(message,"shit","shiz")
		message = replacetext(message,"crap","poo")
		message = replacetext(message,"slut","tease")
		message = replacetext(message,"ass","butt")
		message = replacetext(message,"damn","dang")
		message = replacetext(message,"fuck","")
		message = replacetext(message,"penis","privates")
		message = replacetext(message,"cunt","privates")
		message = replacetext(message,"dick","jerk")
		message = replacetext(message,"vagina","privates")
	if (dna.check_mutation(HULK))
		message = "[uppertext(replacetext(message, ".", "!"))]!!" //because I don't know how to code properly in getting vars from other files -Bro
	if (dna.check_mutation(MUTE))
		message = ""
	if(viruses.len)
		for(var/datum/disease/pierrot_throat/D in viruses)
			var/list/temp_message = text2list(message, " ") //List each word in the message
			var/list/pick_list = list()
			for(var/i = 1, i <= temp_message.len, i++) //Create a second list for excluding words down the line
				pick_list += i
			for(var/i=1, ((i <= D.stage) && (i <= temp_message.len)), i++) //Loop for each stage of the disease or until we run out of words
				if(prob(3 * D.stage)) //Stage 1: 3% Stage 2: 6% Stage 3: 9% Stage 4: 12%
					var/H = pick(pick_list)
					if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":")) continue
					temp_message[H] = "HONK"
					pick_list -= H //Make sure that you dont HONK the same word twice
				message = list2text(temp_message, " ")
	if (dna.check_mutation(WACKY))
		message = "<span class='sans'>[message]</span>"
	message = ..(message)

	return message

/mob/living/carbon/human/GetVoice()
	if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = wear_mask
		if(V.vchange && wear_id)
			var/obj/item/weapon/card/id/idcard = wear_id.GetID()
			if(istype(idcard))
				return idcard.registered_name
			else
				return real_name
		else
			return real_name
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/IsVocal()
	if(mind)
		return !mind.miming
	return 1

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/binarycheck()
	if(ears)
		var/obj/item/device/radio/headset/dongle = ears
		if(!istype(dongle)) return 0
		if(dongle.translate_binary) return 1

/mob/living/carbon/human/radio(message, message_mode)
	. = ..()
	if(. != 0)
		return .

	switch(message_mode)
		if(MODE_HEADSET)
			if (ears)
				ears.talk_into(src, message)
			return ITALICS | REDUCE_RANGE

		if(MODE_SECURE_HEADSET)
			if (ears)
				ears.talk_into(src, message, 1)
			return ITALICS | REDUCE_RANGE

		if(MODE_DEPARTMENT)
			if (ears)
				ears.talk_into(src, message, message_mode)
			return ITALICS | REDUCE_RANGE

	if(message_mode in radiochannels)
		if(ears)
			ears.talk_into(src, message, message_mode)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"

/mob/living/carbon/human/proc/forcesay(list/append) //this proc is at the bottom of the file because quote fuckery makes notepad++ cri
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtextEx(temp, "Say \"", 1, 7) && length(temp) > 5)	//"case sensitive means

				temp = replacetext(temp, ";", "")	//general radio

				if(findtext(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext(trim_left(temp), 3)

				if(findtext(temp, "*", 1, 2))	//emotes
					return

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")
