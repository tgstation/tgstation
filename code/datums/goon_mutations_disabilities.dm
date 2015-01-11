/datum/mutation/human/wacky
	name = "Wacky"
	quality = MINOR_NEGATIVE
	text_indication = "<span class='sans'>You feel an off sensation in your voicebox.</span>"


/datum/mutation/human/wacky/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>The off sensation passes.</span>"

/datum/mutation/human/mute
	name = "Mute"
	quality = NEGATIVE
	text_indication = "<span class='notice'>You feel unable to express yourself at all.</span>"

/datum/mutation/human/mute/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>You feel able to speak freely again.</span>"

/datum/mutation/human/smile
	name = "Smile"
	quality = MINOR_NEGATIVE
	text_indication = "<span class='notice'>You feel so happy. Nothing can be wrong with anything. :)</span>"


/datum/mutation/human/smile/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>Everything is terrible again. :(</span>"

/datum/mutation/human/unintelligable
	name = "Unintelligable"
	quality = NEGATIVE
	text_indication = "<span class='notice'>You can't seem to form any coherent thoughts!</span>"

/datum/mutation/human/unintelligable/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>Your mind feels more clear.</span>"

/datum/mutation/human/swedish
	name = "Swedish"
	quality = MINOR_NEGATIVE
	text_indication = "<span class='notice'>You feel Swedish, however that works.</span>"

/datum/mutation/human/swedish/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>The feeling of Swedishness passes.</span>"

/datum/mutation/human/chav
	name = "Chav"
	quality = MINOR_NEGATIVE
	text_indication = "<span class='notice'>Ye feel like a reet prat like, innit?</span>"

/datum/mutation/human/chav/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>You no longer feel like being rude and sassy.</span>"

/datum/mutation/human/elvis
	name = "Elvis"
	quality = MINOR_NEGATIVE
	text_indication = "<span class='notice'>You feel pretty good, honeydoll.</span>"

/datum/mutation/human/elvis/on_losing(mob/living/carbon/human/owner)
	if(..())	return
	owner << "<span class='notice'>You feel a little less conversation would be great.</span>"

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
