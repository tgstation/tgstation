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
/datum/dna/gene/disability/speech
	var/datum/speech_filter/filter

	New()
		..()
		filter = new

	OnSay(var/mob/M, var/message)
		return filter.FilterSpeech(message)

// WAS: /datum/bioEffect/smile
/datum/dna/gene/disability/speech/smile
	name = "Smile"
	desc = "Causes the speech center of the subject's brain to produce large amounts of seratonin and a chemical resembling ecstacy when engaged."
	activation_message = "You feel so happy. Nothing can be wrong with anything :)"
	deactivation_message = "Everything is terrible again. :("

	New()
		..()
		block=SMILEBLOCK

		//Time for a friendly game of SS13
		// NOW IN REGEX
		filter.addWordReplacement("stupid","smart")
		filter.addWordReplacement("retards","geniuses")
		filter.addWordReplacement("retard\[ed\]","genius")
		filter.addWordReplacement("unrobust","robust")
		filter.addWordReplacement("dumb","smart")
		filter.addWordReplacement("awful","great")
		filter.addPickReplacement("\\bgay\\b",list("nice","ok","alright"))
		filter.addWordReplacement("horrible","fun")
		filter.addWordReplacement("terrible","terribly fun")
		filter.addReplacement("terrifying","wonderful")
		filter.addReplacement("gross","cool")
		filter.addReplacement("disgusting","amazing")
		filter.addReplacement("\\bloser","\\bwinner")
		filter.addWordReplacement("useless","useful")
		filter.addWordReplacement("oh god","cheese and crackers")
		filter.addWordReplacement("jesus","gee wiz")
		filter.addReplacement("weak","strong")
		filter.addReplacement("kill","hug")
		filter.addReplacement("murder","tease")
		filter.addReplacement("ugly","beautiful")
		filter.addReplacement("douche?bag","nice guy")
		filter.addWordReplacement("whores","ladies")
		filter.addWordReplacement("whore","lady")
		filter.addReplacement("nerd","smart guy")
		filter.addWordReplacement("moron","fun person")
		filter.addReplacement("(IT'S\\s+|SINGU|SINGULOTH\\s*(\[I'\]S)?)LOOSE","EVERYTHING IS FINE")
		filter.addWordReplacement("rape","hug fight")
		filter.addReplacement("idiot","genius")
		filter.addReplacement("fat","thin")
		filter.addWordReplacement("beer","water with ice")
		filter.addReplacement("drink","water")
		filter.addWordReplacement("feminists","empowered women")
		filter.addWordReplacement("feminist","empowered woman")
		filter.addReplacement("(i|me) hate you","you're mean")
		filter.addReplacement("nigger","african american")
		filter.addWordReplacement("jew","upstanding jewish citizen")
		filter.addReplacement("shit+","sludge") // "t+" means at least one t
		filter.addReplacement("crap","poo")
		filter.addReplacement("slut","tease")
		filter.addReplacement("ass","butt")
		filter.addReplacement("damn","dang")
		filter.addReplacement("fuck(ing|s)","frick$1")
		filter.addReplacement("(dick|dong|wang|penis|cunt|axe wound|vagina|shlong)","naughty place")

	OnSay(var/mob/M, var/message)
		message = ..(M,message)
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
		filter.addReplacement("i'?m not","I ain't")
		filter.addPickReplacement("\\bgirl\\b",list("honey","baby","baby doll"))
		filter.addPickReplacement("\\bman\\b",list("son","buddy","brother", "pal", "friendo"))
		filter.addWordReplacement("out of","outta")
		filter.addWordReplacement("thank(s|\\s+you)","thank you, thank you very much")
		filter.addWordReplacement("what are you","whatcha")
		filter.addPickReplacement("\\byes\\b",list("sure", "yea"))
		filter.addWordReplacement("(faggot|dick|shitlord|fuck(er|wit)?|asshole|nigger)","square")
		filter.addWordReplacement("muh valids","getting my kicks")
		filter.addWordReplacement("vox","bird")

	OnSay(var/mob/M, var/message)
		if(prob(5))
			return ""
			M.visible_message("<b>[M]</b> [pick("rambles to themselves.","begins talking to themselves.")]")
		else
			return ..(M,message)

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

		// THIS ENTIRE THING BEGS FOR REGEX
		// NOW IN REGEX
		filter.addPickReplacement("\\b(dick|comdom|shit(ter|lord)?|fuck(er|lord))",list("prat","knob'ead"))
		filter.addReplacement("lookin\['g\] at","gawpin' at")
		filter.addWordReplacement("great","bangin'")
		filter.addWordReplacement("man","mate")
		filter.addPickReplacement("\\bfriend\\b",list("mate","bruv","bledrin"))
		filter.addWordReplacement("what","wot")
		filter.addReplacement("\\bdrink","wet")
		filter.addWordReplacement("get","giz")
		filter.addWordReplacement("no thank(s| you)","wuddent fukken do one")
		filter.addWordReplacement("i don't know","wot mate")
		filter.addWordReplacement("no","naw")
		filter.addReplacement("robust","chin")
		filter.addPickReplacement("\\b(hi|hello)\\b",list("how what how","sup bruv"))
		filter.addWordReplacement("(kill|murder)","bang")
		filter.addWordReplacement("windows","windies")
		filter.addWordReplacement("window","windy")
		filter.addReplacement("\\b(break|destroy|bust)","do")
		filter.addWordReplacement("(your|you're)","yer")
		filter.addWordReplacement("(se|shit)curity","coppers")

// WAS: /datum/bioEffect/swedish
/datum/dna/gene/disability/speech/swedish
	name = "Swedish"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	activation_message = "You feel Swedish, however that works."
	deactivation_message = "The feeling of Swedishness passes."

	New()
		..()
		block=SWEDEBLOCK

		// FUN WITH REGEX
		filter.addReplacement("w","v")
		filter.addReplacement("or","ör") // May need to make this one use the HTML entity.
		filter.addReplacement("the","thur")
		filter.addReplacement("e\\b","e-a")
		filter.addReplacement("\\bth","z")

	OnSay(var/mob/M, var/message)
		// svedish!
		message = ..(M,message)
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
		var/mob/living/carbon/human/skellington/nH = new /mob/living/carbon/human/skellington(H.loc)
		nH.real_name = H.real_name
		nH.name = "[H.name]'s skeleton"
		//H.decomp_stage = 4
		nH.brain_op_stage = 4
		H.gib(1)
	else
		usr.visible_message("\red <b>[usr.name] melts into a pile of bloody viscera!</b>")
		usr.gib(1)

	return
