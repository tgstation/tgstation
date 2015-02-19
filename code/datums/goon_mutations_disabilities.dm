/datum/mutation/human/wacky
	name = "Wacky"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='sans'>You feel an off sensation in your voicebox.</span>"
	text_lose_indication = "<span class='notice'>The off sensation passes.</span>"

/datum/mutation/human/wacky/say_mod(var/message)
	if(message)
		message = "<span class='sans'>[message]</span>"
	return message

/datum/mutation/human/mute
	name = "Mute"
	quality = NEGATIVE
	text_gain_indication = "<span class='notice'>You feel unable to express yourself at all.</span>"
	text_lose_indication = "<span class='notice'>You feel able to speak freely again.</span>"

/datum/mutation/human/mute/on_acquiring(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities |= MUTE

/datum/mutation/human/mute/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner.disabilities &= ~MUTE

/datum/mutation/human/smile
	name = "Smile"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>You feel so happy. Nothing can be wrong with anything. :)</span>"
	text_lose_indication = "<span class='notice'>Everything is terrible again. :(</span>"

/datum/mutation/human/smile/say_mod(var/message)
	if(message)
		message = " [message] "
		//Time for a friendly game of SS13
		message = replacetext(message," stupid "," smart ")
		message = replacetext(message," retard "," genius ")
		message = replacetext(message," unrobust "," robust ")
		message = replacetext(message," dumb "," smart ")
		message = replacetext(message," awful "," great ")
		message = replacetext(message," gay ",pick(" nice "," ok "," alright "))
		message = replacetext(message," horrible "," fun ")
		message = replacetext(message," terrible "," terribly fun ")
		message = replacetext(message," terrifying "," wonderful ")
		message = replacetext(message," gross "," cool ")
		message = replacetext(message," disgusting "," amazing ")
		message = replacetext(message," loser "," winner ")
		message = replacetext(message," useless "," useful ")
		message = replacetext(message," oh god "," cheese and crackers ")
		message = replacetext(message," jesus "," gee wiz ")
		message = replacetext(message," weak "," strong ")
		message = replacetext(message," kill "," hug ")
		message = replacetext(message," murder "," tease ")
		message = replacetext(message," ugly "," beautiful ")
		message = replacetext(message," douchbag "," nice guy ")
		message = replacetext(message," whore "," lady ")
		message = replacetext(message," nerd "," smart guy ")
		message = replacetext(message," moron "," fun person ")
		message = replacetext(message," IT'S LOOSE "," EVERYTHING IS FINE ")
		message = replacetext(message," sex "," hug fight ")
		message = replacetext(message," idiot "," genius ")
		message = replacetext(message," fat "," thin ")
		message = replacetext(message," beer "," water with ice ")
		message = replacetext(message," drink "," water ")
		message = replacetext(message," feminist "," empowered woman ")
		message = replacetext(message," i hate you "," you're mean ")
		message = replacetext(message," nigger "," african american ")
		message = replacetext(message," jew "," jewish ")
		message = replacetext(message," shit "," shiz ")
		message = replacetext(message," crap "," poo ")
		message = replacetext(message," slut "," tease ")
		message = replacetext(message," ass "," butt ")
		message = replacetext(message," damn "," dang ")
		message = replacetext(message," fuck ","  ")
		message = replacetext(message," penis "," privates ")
		message = replacetext(message," cunt "," privates ")
		message = replacetext(message," dick "," jerk ")
		message = replacetext(message," vagina "," privates ")
	return trim(message)

/datum/mutation/human/unintelligable
	name = "Unintelligable"
	quality = NEGATIVE
	text_gain_indication = "<span class='notice'>You can't seem to form any coherent thoughts!</span>"
	text_lose_indication = "<span class='notice'>Your mind feels more clear.</span>"

/datum/mutation/human/unintelligable/say_mod(var/message)
	if(message)
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
		message = "[prefix][uppertext(list2text(rearranged," "))]!!"
	return message

/datum/mutation/human/swedish
	name = "Swedish"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>You feel Swedish, however that works.</span>"
	text_lose_indication = "<span class='notice'>The feeling of Swedishness passes.</span>"

/datum/mutation/human/swedish/say_mod(var/message)
	if(message)
		message = replacetext(message,"w","v")
		if(prob(30))
			message += " Bork[pick("",", bork",", bork, bork")]!"
	return message

/datum/mutation/human/chav
	name = "Chav"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Ye feel like a reet prat like, innit?</span>"
	text_lose_indication = "<span class='notice'>You no longer feel like being rude and sassy.</span>"

/datum/mutation/human/chav/say_mod(var/message)
	if(message)
		message = " [message] "
		message = replacetext(message," looking at  ","  gawpin' at ")
		message = replacetext(message," great "," bangin' ")
		message = replacetext(message," man "," mate ")
		message = replacetext(message," friend ",pick(" mate "," bruv "," bledrin "))
		message = replacetext(message," what "," wot ")
		message = replacetext(message," drink "," wet ")
		message = replacetext(message," get "," giz ")
		message = replacetext(message," what "," wot ")
		message = replacetext(message," no thanks "," wuddent fukken do one ")
		message = replacetext(message," i don't know "," wot mate ")
		message = replacetext(message," no "," naw ")
		message = replacetext(message," robust "," chin ")
		message = replacetext(message,"  hi  "," how what how ")
		message = replacetext(message," hello "," sup bruv ")
		message = replacetext(message," kill "," bang ")
		message = replacetext(message," murder "," bang ")
		message = replacetext(message," windows "," windies ")
		message = replacetext(message," window "," windy ")
		message = replacetext(message," break "," do ")
		message = replacetext(message," your "," yer ")
		message = replacetext(message," security "," coppers ")
	return trim(message)

/datum/mutation/human/elvis
	name = "Elvis"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>You feel pretty good, honeydoll.</span>"
	text_lose_indication = "<span class='notice'>You feel a little less conversation would be great.</span>"

/datum/mutation/human/elvis/on_life(mob/living/carbon/human/owner)
	switch(pick(1,2))
		if(1)
			if(prob(15))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> busts out some [dancemoves] moves!")
		if(2)
			if(prob(15))
				owner.visible_message("<b>[owner]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]!")

/datum/mutation/human/elvis/say_mod(var/message)
	if(message)
		message = " [message] "
		message = replacetext(message," i'm not "," I aint ")
		message = replacetext(message," girl ",pick(" honey "," baby "," baby doll "))
		message = replacetext(message," man ",pick(" son "," buddy "," brother"," pal "," friendo "))
		message = replacetext(message," out of "," outta ")
		message = replacetext(message," thank you "," thank you, thank you very much ")
		message = replacetext(message," what are you "," whatcha ")
		message = replacetext(message," yes ",pick(" sure", "yea "))
		message = replacetext(message," faggot "," square ")
		message = replacetext(message," muh valids "," getting my kicks ")
	return trim(message)
