//////////////////
// DISABILITIES //
//////////////////

////////////////////////////////////////
// Totally Crippling
////////////////////////////////////////

// WAS: /datum/bioEffect/mute
/datum/dna/gene/disability/mute
	name = "Mute"
	desc = "Completley shuts down the speech center of the subject's brain."
	activation_message   = "You feel unable to express yourself at all."
	deactivation_message = "You feel able to speak freely again."

	New()
		..()
		block=MUTEBLOCK

	OnSay(var/mob/M, var/message)
		return ""

////////////////////////////////////////
// Harmful to others as well as self
////////////////////////////////////////

/datum/dna/gene/disability/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	activation_message = "You feel a strange sickness permeate your whole body."
	deactivation_message = "You no longer feel awful and sick all over."

	New()
		..()
		block=RADBLOCK

	OnMobLife(var/mob/owner)
		owner.radiation = max(owner.radiation, 20)
		for(var/mob/living/L in range(1, owner))
			if(L == owner) continue
			L << "\red You are enveloped by a soft green glow emanating from [owner]."
			L.radiation += 5
		return

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "rads[fat]_s"

////////////////////////////////////////
// Other disabilities
////////////////////////////////////////

// WAS: /datum/bioEffect/fat
/datum/dna/gene/disability/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	activation_message = "You feel blubbery and lethargic!"
	deactivation_message = "You feel fit!"

	mutation = M_OBESITY

	New()
		..()
		block=FATBLOCK

/////////////////////////
// SPEECH MANIPULATORS //
/////////////////////////

// WAS: /datum/bioEffect/stutter
/datum/dna/gene/disability/stutter
	name = "Stutter"
	desc = "Hinders nerve transmission to and from the speech center of the brain, resulting in faltering speech."
	activation_message = "Y-you f.. feel a.. a bit n-n-nervous."
	deactivation_message = "You don't feel nervous anymore."

	New()
		..()
		block=STUTTERBLOCK

	OnMobLife(var/mob/owner)
		if (prob(10))
			owner:stuttering = max(10, owner:stuttering)

/datum/dna/gene/disability/speech
	can_activate(var/mob/M, var/flags)
		// Can only activate one of these at a time.
		if(is_type_in_list(/datum/dna/gene/disability/speech,M.mutations))
			return 0
		return ..(M,flags)

/* Figure out what the fuck this one does.
// WAS: /datum/bioEffect/smile
/datum/dna/gene/disability/speech/smile
	name = "Smile"
	desc = "Causes the speech center of the subject's brain to produce large amounts of seratonin when engaged."
	activation_message = "You feel like you want to smile and smile and smile forever :)"
	deactivation_message = "You don't feel like smiling anymore. :("

	New()
		..()
		block=SMILEBLOCK

	OnSay(var/mob/M, var/message)
		return message

// WAS: /datum/bioEffect/elvis
/datum/dna/gene/disability/speech/elvis
	name = "Elvis"
	desc = "Forces the language center of the subject's brain to drawl out sentences in a funky manner."
	activation_message = "You feel funky."
	deactivation_message = "You feel a little less conversation would be great."

	New()
		..()
		block=ELVISBLOCK

	OnSay(var/mob/M, var/message)
		return message
*/

// WAS: /datum/bioEffect/chav
/datum/dna/gene/disability/speech/chav
	name = "Chav"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	activation_message = "Ye feel like a reet prat like, innit?"
	deactivation_message = "You no longer feel like being rude and sassy."

	New()
		..()
		block=CHAVBLOCK

	OnSay(var/mob/M, var/message)
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
		message = replacetext(message,"hi","how what how")
		message = replacetext(message,"hello","sup bruv")
		message = replacetext(message,"kill","bang")
		message = replacetext(message,"murder","bang")
		message = replacetext(message,"windows","windies")
		message = replacetext(message,"window","windy")
		message = replacetext(message,"break","do")
		message = replacetext(message,"your","yer")
		message = replacetext(message,"security","coppers")
		return message

// WAS: /datum/bioEffect/swedish
/datum/dna/gene/disability/speech/swedish
	name = "Swedish"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	activation_message = "You feel Swedish, however that works."
	deactivation_message = "The feeling of Swedishness passes."

	New()
		..()
		block=SWEDEBLOCK

	OnSay(var/mob/M, var/message)
		// svedish
		message = replacetext(message,"w","v")
		if(prob(30))
			message += " Bork[pick("",", bork",", bork, bork")]!"
		return message

// WAS: /datum/bioEffect/unintelligable
/datum/dna/gene/disability/unintelligable
	name = "Unintelligable"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	activation_message = "You can't seem to form any coherent thoughts!"
	deactivation_message = "Your mind feels more clear."

	New()
		..()
		block=SCRAMBLEBLOCK

	OnSay(var/mob/M, var/message)
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
		return "[prefix][uppertext(dd_list2text(rearranged," "))]!!"

// WAS: /datum/bioEffect/toxic_farts
/datum/dna/gene/disability/toxic_farts
	name = "Toxic Farts"
	desc = "Causes the subject's digestion to create a significant amount of noxious gas."
	activation_message = "Your stomach grumbles unpleasantly."
	deactivation_message = "Your stomach stops acting up. Phew!"

	mutation = M_TOXIC_FARTS

	New()
		..()
		block=TOXICFARTBLOCK

//////////////////
// USELESS SHIT //
//////////////////

// WAS: /datum/bioEffect/strong
/datum/dna/gene/disability/strong
	// pretty sure this doesn't do jack shit, putting it here until it does
	name = "Strong"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	activation_message = "You feel buff!"
	deactivation_message = "You feel wimpy and weak."

	mutation = M_STRONG

	New()
		..()
		block=STRONGBLOCK

// WAS: /datum/bioEffect/horns
/datum/dna/gene/disability/strong
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	activation_message = "A pair of horns erupt from your head."
	deactivation_message = "Your horns crumble away into nothing."

	New()
		..()
		block=HORNSBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "horns_s"

/* Stupid
/datum/bioEffect/stinky
	name = "Apocrine Enhancement"
	desc = "Increases the amount of natural body substances produced from the subject's apocrine glands."
	id = "stinky"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel sweaty."
	msgLose = "You feel much more hygenic."
	var/personalized_stink = "Wow, it stinks in here!"

	New()
		..()
		src.personalized_stink = stinkString()
		if (prob(5))
			src.variant = 2

	OnLife()
		if (prob(10))
			for(var/mob/living/carbon/C in view(6,get_turf(owner)))
				if (C == owner)
					continue
				if (src.variant == 2)
					C << "\red [src.personalized_stink]"
				else
					C << "\red [stinkString()]"
*/