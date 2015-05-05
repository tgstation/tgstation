/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/colour = "body"         // CSS style to use for strings in this language.
	var/key = "x"                    // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                    // Various language flags.
	var/native                       // If set, non-native speakers will have trouble speaking.

/datum/language/proc/say_misunderstood(mob/M, message)
	return stars(message)

/datum/language/proc/format_message(message)
	return "[speech_verb], <span class='message'><span class='[colour]'>\"[capitalize(message)]\"</span></span>"

/datum/language/proc/format_message_plain(message)
	return "[speech_verb], \"[capitalize(message)]\""

/datum/language/proc/format_message_radio(message)
	return "[speech_verb], <span class='[colour]'>\"[capitalize(message)]\"</span>"

/datum/language/unathi
	name = "Sinta'unathi"
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	colour = "soghun"
	key = "o"
	flags = RESTRICTED

/datum/language/tajaran
	name = "Siik'tajr"
	desc = "An expressive language that combines yowls and chirps with posture, tail and ears. Native to the Tajaran."
	speech_verb = "mrowls"
	colour = "tajaran"
	key = "j"
	flags = RESTRICTED

/datum/language/skrell
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	colour = "skrell"
	key = "k"
	flags = RESTRICTED

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	colour = "vox"
	key = "v"
	flags = RESTRICTED

/datum/language/diona
	name = "Rootspeak"
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	colour = "soghun"
	key = "q"
	flags = RESTRICTED

/datum/language/human
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	key = "1"
	flags = RESTRICTED

/datum/language/human/monkey
	name = "Chimpanzee"
	desc = "Ook ook ook."
	speech_verb = "chimpers"
	key = "6"

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "say_quote"
	key = "2"

/datum/language/gutter
	name = "Gutter"
	desc = "Much like Standard, this crude pidgin tongue descended from numerous languages and serves as Tradeband for criminal elements."
	speech_verb = "growls"
	colour = "rough"
	key = "3"

/datum/language/grey
	name = "Grey"
	desc = "Sounds more like quacking than anything else."
	key = "x"
	speech_verb = "quacks"
	colour = "rough"
	native=1
	flags = RESTRICTED

/datum/language/grey/say_misunderstood(mob/M, message)
	message="ACK"
	var/len = max(1,Ceiling(length(message)/3))
	if(len > 1)
		for(var/i=0,i<len,i++)
			message += " ACK"
	return message+"!"

/datum/language/skellington
	name = "Clatter"
	desc = "Click clack go the bones."
	key = "z"
	speech_verb = "chatters"
	colour = "rough"
	native=1
	flags = RESTRICTED

/datum/language/skellington/say_misunderstood(mob/M, message)
	message="CLICK"
	var/len = max(1,Ceiling(length(message)/5))
	if(len > 1)
		for(var/i=0,i<len,i++)
			message += " CL[pick("A","I")]CK"
	return message+"!"

/datum/language/xenocommon
	name = "Xenomorph"
	colour = "alien"
	desc = "The common tongue of the xenomorphs."
	speech_verb = "hisses"
	key = "4"
	flags = RESTRICTED

/datum/language/xenocommon/say_misunderstood(mob/M, message)
	return speech_verb

// Language handling.
/mob/proc/add_language(var/language)

	var/datum/language/new_language = all_languages[language]

	if(!istype(new_language) || new_language in languages)
		return 0

	languages.Add(new_language)
	return 1

/mob/proc/remove_language(var/rem_language)
	var/datum/language/L = all_languages[rem_language]
	. = (L in languages)
	languages.Remove(L)

/mob/living/remove_language(rem_language)
	var/datum/language/L = all_languages[rem_language]
	if(default_language == L)
		default_language = null
	return ..()

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak_lang(datum/language/speaking)

	return (universal_speak || speaking in src.languages)

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return

/mob/living/check_languages()
	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	if(default_language)
		dat += "Current default language: [default_language] - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/><br/>"

	for(var/datum/language/L in languages)
		if(L == default_language)
			dat += "<b>[L.name] (:[L.key])</b> - default - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/>[L.desc]<br/><br/>"
		else
			dat += "<b>[L.name] (:[L.key])</b> - <a href='byond://?src=\ref[src];default_lang=[L]'>set default</a><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")

/mob/living/Topic(href, href_list)
	if(href_list["default_lang"])
		if(href_list["default_lang"] == "reset")
			set_default_language(null)
		else
			var/datum/language/L = all_languages[href_list["default_lang"]]
			if(L)
				set_default_language(L)
		check_languages()
		return 1
	else
		return ..()