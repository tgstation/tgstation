
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	activation_message = "YOU FEEL LIKE YELLING!"
	deactivation_message = "You feel like being quiet.."

	New()
		..()
		block=LOUDBLOCK



	OnSay(var/mob/M, var/message)
		message = replacetext(message,".","!")
		message = replacetext(message,"?","?!")
		message = replacetext(message,"!","!!")
		return uppertext(message)


/datum/dna/gene/disability/speech/whisper
	name = "Quiet"
	desc = "Damages the subjects vocal cords"
	activation_message = "<i>Your throat feels sore..</i>"
	deactivation_message = "You feel fine again."

	New()
		..()
		block=WHISPERBLOCK

	can_activate(var/mob/M,var/flags)
		// No loud whispering.
		if(M_LOUD in M.mutations)
			return 0
		return ..(M,flags)

	OnSay(var/mob/M, var/message)
		M.whisper(message)
		
		
/datum/dna/gene/disability/dizzy
	name = "Dizzy"
	desc = "Causes the cerebellum to shut down in some places."
	activation_message = "You feel very dizzy..."
	deactivation_message = "You regain your balance."
	flags = GENE_UNNATURAL

	New()
		..()
		block=DIZZYBLOCK


	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		if(M_DIZZY in M.mutations)
			M.make_dizzy(300)


/datum/dna/gene/disability/speech/sans
	name = "Wacky"
	desc = "Forces the subject to talk in an odd manner."
	activation_message = "You feel an off sensation in your voicebox.."
	deactivation_message = "The off sensation passes.."

	New()
		..()
		block=SANSBLOCK


	OnSay(var/mob/M, var/message)
		return "<span class='sans'>message</span>"
