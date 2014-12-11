/mob/living/silicon/ai/say(var/message)
	if(parent && istype(parent) && parent.stat != 2)
		parent.say(message)
		return
		//If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
	..(message)

/mob/living/silicon/ai/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	if (istype(other, /mob/living/silicon/decoy))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	if (istype(other, /mob/living/silicon/pai))
		return 1
	return ..()

/mob/living/silicon/ai/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/ai/proc/IsVocal()

var/announcing_vox = 0 // Stores the time of the last announcement
var/const/VOX_CHANNEL = 200
var/const/VOX_DELAY = 600

/mob/living/silicon/ai/verb/announcement_help()

	set name = "Announcement Help"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"


	var/dat = "Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR> \
	<UL><LI>You can also click on the word to preview it.</LI>\
	<LI>You can only say 30 words for every announcement.</LI>\
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI></UL>\
	<font class='bad'>WARNING:</font><BR>Misuse of the announcement system will get you job banned.<HR>"

	var/index = 0
	for(var/word in vox_sounds)
		index++
		dat += "<A href='?src=\ref[src];say_word=[word]'>[capitalize(word)]</A>"
		if(index != vox_sounds.len)
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()


/mob/living/silicon/ai/verb/announcement()

	// If we're in an APC, and APC is ded, ABORT
	if(parent && istype(parent) && parent.stat)
		return

	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.control_disabled)
			usr << "Wireless control is disabled!"
			return

	if(announcing_vox > world.time)
		src << "<span class='notice'>Please wait [round((announcing_vox - world.time) / 10)] seconds.</span>"
		return

	var/message = input(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", src.last_announcement) as text

	last_announcement = message

	if(!message || announcing_vox > world.time)
		return

	var/list/words = text2list(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	var/total_word_len=0
	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!vox_sounds[word])
			incorrect_words += word
		// Thank Rippetoe for this!
		var/wordlen = 1
		if(word in vox_wordlen)
			wordlen=vox_wordlen[word]
		if(total_word_len+wordlen>50)
			src << "<span class='notice'>There are too many words in this announcement.</span>"
			return
		total_word_len+=wordlen

	if(incorrect_words.len)
		src << "<span class='notice'>These words are not available on the announcement system: [english_list(incorrect_words)].</span>"
		return

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name_admin(src)] made a vocal announcement with the following message: [message].")

	for(var/word in words)
		play_vox_word(word, src.z, null)


var/list/vox_units=list(
	'sound/vox_fem/one.ogg',
	'sound/vox_fem/two.ogg',
	'sound/vox_fem/three.ogg',
	'sound/vox_fem/four.ogg',
	'sound/vox_fem/five.ogg',
	'sound/vox_fem/six.ogg',
	'sound/vox_fem/seven.ogg',
	'sound/vox_fem/eight.ogg',
	'sound/vox_fem/nine.ogg',
	'sound/vox_fem/ten.ogg',
	'sound/vox_fem/eleven.ogg',
	'sound/vox_fem/twelve.ogg',
	'sound/vox_fem/thirteen.ogg',
	'sound/vox_fem/fourteen.ogg',
	'sound/vox_fem/fifteen.ogg',
	'sound/vox_fem/sixteen.ogg',
	'sound/vox_fem/seventeen.ogg',
	'sound/vox_fem/eighteen.ogg',
	'sound/vox_fem/nineteen.ogg'
)

var/list/vox_tens=list(
	'sound/vox_fem/ten.ogg',
	'sound/vox_fem/twenty.ogg',
	'sound/vox_fem/thirty.ogg',
	'sound/vox_fem/fourty.ogg',
	'sound/vox_fem/fifty.ogg',
	'sound/vox_fem/sixty.ogg',
	'sound/vox_fem/seventy.ogg',
	'sound/vox_fem/eighty.ogg',
	'sound/vox_fem/ninety.ogg'
)

// Stolen from here: http://stackoverflow.com/questions/2729752/converting-numbers-in-to-words-c-sharp
/proc/vox_num2list(var/number)
	if(!isnum(number))
		warning("vox_num2list fed a non-number: [number]")
		return list()
	number=round(number)
	if(number == 0)
		return list('sound/vox_fem/zero.ogg')

	if(number < 0)
		return list('sound/vox_fem/minus.ogg') + vox_num2list(abs(number))

	var/list/words=list()

	if (round(number / 1000000) > 0)
		words += vox_num2list(number / 1000000)
		words.Add('sound/vox_fem/million.ogg')
		number %= 1000000

	if (round(number / 1000) > 0)
		words += vox_num2list(number / 1000)
		words.Add('sound/vox_fem/thousand.ogg')
		number %= 1000

	if (round(number / 100) > 0)
		words += vox_num2list(number / 100)
		words.Add('sound/vox_fem/hundred.ogg')
		number %= 100

	if (number > 0)
		// Sounds fine without the and.
		//if (words != "")
		//	words += "and "

		if (number < 20)
			words += vox_units[number+1]
		else
			words += vox_tens[(number / 10)+1]
			if ((number % 10) > 0)
				words.Add(vox_units[(number % 10)+1])

	return words

/proc/play_vox_word(var/word, var/z_level, var/mob/only_listener)
	word = lowertext(word)
	if(vox_sounds[word])
		return play_vox_sound(vox_sounds[word],z_level,only_listener)
	return 0


/proc/play_vox_sound(var/sound_file, var/z_level, var/mob/only_listener)
	var/sound/voice = sound(sound_file, wait = 1, channel = VOX_CHANNEL)
	voice.status = SOUND_STREAM

	// If there is no single listener, broadcast to everyone in the same z level
	if(!only_listener)
		// Play voice for all mobs in the z level
		for(var/mob/M in player_list)
			if(M.client)
				var/turf/T = get_turf(M)
				if(T.z == z_level)
					M << voice
	else
		only_listener << voice
	return 1
