//////////////////
// DISABILITIES //
//////////////////

////////////////////////////////////////
// Totally Crippling
////////////////////////////////////////

// WAS: /datum/bioEffect/mute
/datum/dna/gene/disability/mute
	name = "Mute"
	desc = "Completely shuts down the speech center of the subject's brain."
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
	flags = GENE_UNNATURAL

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

// WAS: /datum/bioEffect/smile
/datum/dna/gene/disability/speech/smile
	name = "Smile"
	desc = "Causes the speech center of the subject's brain to produce large amounts of seratonin and a chemical resembling ecstacy when engaged."
	activation_message = "You feel so happy. Nothing can be wrong with anything :)"
	deactivation_message = "Everything is terrible again. :("

	New()
		..()
		block=SMILEBLOCK

	OnSay(var/mob/M, var/message)
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
		message = replacetext(message,"ugly","beutiful")
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
//		message += "[pick(":)",":^)",":*)")]"             : ^ (
		if(prob(30))
			message += " check your privilege."
		return message


// WAS: /datum/bioEffect/elvis
/datum/dna/gene/disability/speech/elvis
	name = "Elvis"
	desc = "Forces the language center and primary motor cortex of the subject's brain to talk and act like the King of Rock and Roll."
	activation_message = "You feel pretty good, honeydoll."
	deactivation_message = "You feel a little less conversation would be great."

	New()
		..()
		block=ELVISBLOCK

	OnSay(var/mob/M, var/message)
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
		message = replacetext(message," vox ","bird")

		if(prob(5))
			return ""
			M.visible_message("<b>[M]</b> [pick("rambles to themselves.","begins talking to themselves.")]")
		else
			return message

	OnMobLife(var/mob/M)
		switch(pick(1,2))
			if(1)
				if(prob(15))
					var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
					var/dancemoves = pick(dancetypes)
					M.visible_message("<b>[M]</b> busts out some [dancemoves] moves!")
			if(2)
				if(prob(15))
					M.visible_message("<b>[M]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]")


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
		// THIS ENTIRE THING BEGS FOR REGEX
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
		// svedish!
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
	flags = GENE_UNNATURAL

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
/datum/dna/gene/disability/horns
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	activation_message = "A pair of horns erupt from your head."
	deactivation_message = "Your horns crumble away into nothing."
	flags = GENE_UNNATURAL

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


////////////////////////////////////////////////////////////////////////
// WAS: /datum/bioEffect/immolate
/datum/dna/gene/basic/grant_spell/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	flags = GENE_UNNATURAL
	activation_messages = list("You suddenly feel rather hot.")
	deactivation_messages = list("You no longer feel uncomfortably hot.")

	spelltype=/obj/effect/proc_holder/spell/targeted/immolate

	New()
		..()
		block = IMMOLATEBLOCK

/obj/effect/proc_holder/spell/targeted/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	panel = "Mutant Powers"

	charge_type = "recharge"
	charge_max = 600

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -1
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	include_user = 1

/obj/effect/proc_holder/spell/targeted/immolate/cast(list/targets)
	var/mob/living/L = usr

	L.adjust_fire_stacks(0.5) // Same as walking into fire. Was 100 (goon fire)
	L.visible_message("\red <b>[L.name]</b> suddenly bursts into flames!")
	L.on_fire = 1
	L.update_icon = 1
	playsound(L.loc, 'sound/effects/bamf.ogg', 50, 0)

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/melt
/datum/dna/gene/basic/grant_verb/melt
	name = "Self Biomass Manipulation"
	desc = "The subject becomes able to transform the matter of their cells into a liquid state."
	flags = GENE_UNNATURAL
	activation_messages = list("You feel strange and jiggly.")
	deactivation_messages = list("You feel more solid.")

	verbtype=/proc/bioproc_melt

	New()
		..()
		block = MELTBLOCK

/proc/bioproc_melt()
	set name = "Dissolve"
	set desc = "Transform yourself into a liquified state."
	set category = "Mutant Abilities"

	if (istype(usr,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = usr

		H.visible_message("\red <b>[H.name]'s flesh melts right off! Holy shit!</b>")
		//if (H.gender == "female")
		//	playsound(H.loc, 'female_fallscream.ogg', 50, 0)
		//else
		//	playsound(H.loc, 'male_fallscream.ogg', 50, 0)
		//playsound(H.loc, 'bubbles.ogg', 50, 0)
		//playsound(H.loc, 'loudcrunch2.ogg', 50, 0)
		var/mob/living/carbon/human/skellington/nH = new /mob/living/carbon/human/skellington(H.loc, delay_ready_dna=1)
		H.real_name = H.real_name
		nH.name = "[H.name]'s skeleton"
		//H.decomp_stage = 4
		H.brain_op_stage = 4
		H.gib(1)
	else
		usr.visible_message("\red <b>[usr.name] melts into a pile of bloody viscera!</b>")
		usr.gib(1)

	return
