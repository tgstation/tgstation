




//				INTEGRATION: Adding Procs and Datums to existing "classes"




/mob/living/proc/AmBloodsucker(falseIfInDisguise=FALSE)
	// No Datum
	if (!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return FALSE

	return TRUE


/mob/living/proc/HaveBloodsuckerBodyparts(var/displaymessage="") // displaymessage can be something such as "rising from death" for Torpid Sleep. givewarningto is the person receiving messages.
	if (!getorganslot("heart"))
		if (displaymessage != "")
			to_chat(src, "<span class='warning'>Without a heart, you are incapable of [displaymessage].</span>")
		return FALSE
	if (!get_bodypart("head"))
		if (displaymessage != "")
			to_chat(src, "<span class='warning'>Without a head, you are incapable of [displaymessage].</span>")
		return FALSE
	if (!getorgan(/obj/item/organ/brain)) // NOTE: This is mostly just here so we can do one scan for all needed parts when creating a vamp. You probably won't be trying to use powers w/out a brain.
		if (displaymessage != "")
			to_chat(src, "<span class='warning'>Without a brain, you are incapable of [displaymessage].</span>")
		return FALSE
	return TRUE



// 			GET DAMAGE


// Do NOT count the damage on prosthetics for this.
/mob/living/proc/getBruteLoss_nonProsthetic()
	return getBruteLoss()
/mob/living/proc/getFireLoss_nonProsthetic()
	return getFireLoss()
/mob/living/carbon/getBruteLoss_nonProsthetic()
	var/amount = 0
	for(var/obj/item/bodypart/BP in bodyparts)
		if (BP.status < 2)
			amount += BP.brute_dam
	return amount
/mob/living/carbon/getFireLoss_nonProsthetic()
	var/amount = 0
	for(var/obj/item/bodypart/BP in bodyparts)
		if (BP.status < 2)
			amount += BP.burn_dam
	return amount




// 			EXAMINING





/mob/living/carbon/human/proc/ReturnVampExamine(var/mob/viewer)
	if (!mind || !viewer.mind)
		return ""
	// Target must be a Vamp
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (!bloodsuckerdatum)
		return ""

	// Viewer is Target's Vassal?
	if (viewer.mind.has_antag_datum(ANTAG_DATUM_VASSAL) in bloodsuckerdatum.vassals)
		var/returnString = "\[<span class='warning'><EM>This is your Master!</EM></span>\]"
		var/returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "bloodsucker")]"
		returnString += "\n"
		return returnIcon + returnString

	// Viewer not a Vamp AND not the target's vassal?
	if (!viewer.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) && !(viewer in bloodsuckerdatum.vassals))
		return ""

	// Default String
	var/returnString = "\[<span class='warning'><EM>[bloodsuckerdatum.ReturnFullName(1)]</EM></span>\]"
	var/returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "bloodsucker")]"

	// In Disguise (Veil)?
	//if (name_override != null)
	//	returnString += "<span class='suicide'> ([real_name] in disguise!) </span>"

	//returnString += "\n"  Don't need spacers. Using . += "" in examine.dm does this on its own.
	return returnIcon + returnString


/mob/living/carbon/human/proc/ReturnVassalExamine(var/mob/viewer)
	if (!mind || !viewer.mind)
		return ""
	// Am I not even a Vassal? Then I am not marked.
	var/datum/antagonist/vassal/vassaldatum = mind.has_antag_datum(ANTAG_DATUM_VASSAL)
	if (!vassaldatum)
		return ""
	// Only Vassals and Bloodsuckers can recognize marks.
	if (!viewer.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER) && !viewer.mind.has_antag_datum(ANTAG_DATUM_VASSAL))
		return ""

	// Default String
	var/returnString = "\[<span class='warning'>"
	var/returnIcon = ""
	// Am I Viewer's Vassal?
	if (vassaldatum.master.owner == viewer.mind)
		returnString += "This [dna.species.name] bears YOUR mark!"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal")]"
	// Am I someone ELSE'S Vassal?
	else if (viewer.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		returnString +=	"This [dna.species.name] bears the mark of <span class='boldwarning'>[vassaldatum.master.ReturnFullName(vassaldatum.master.owner.current,1)]</span>"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal_grey")]"
	// Are you serving the same master as I am?
	else if (viewer.mind.has_antag_datum(ANTAG_DATUM_VASSAL) in vassaldatum.master.vassals)
		returnString += "[p_they(TRUE)] bears the mark of your Master"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal")]"
	// You serve a different Master than I do.
	else
		returnString += "[p_they(TRUE)] bears the mark of another Bloodsucker"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal_grey")]"

	returnString += "</span>\]" // \n"  Don't need spacers. Using . += "" in examine.dm does this on its own.
	return returnIcon + returnString


// Am I "pale" when examined? Bloodsuckers can trick this.
/mob/living/carbon/proc/ShowAsPaleExamine()

	// Normal Creatures:
	if(!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return blood_volume < BLOOD_VOLUME_SAFE

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (bloodsuckerdatum.poweron_masquerade)
		return FALSE

	// If a Bloodsucker is malnourished, AND if his temperature matches his surroundings (aka he hasn't fed recently and looks COLD)...
	return  blood_volume < BLOOD_VOLUME_OKAY // && !(bodytemperature <= get_temperature() + 2)

/mob/living/carbon/human/ShowAsPaleExamine()
	// Check for albino, as per human/examine.dm's check.
	if (skin_tone == "albino")
		return TRUE

	return ..() // Return vamp check

/mob/living/carbon/proc/scan_blood_volume()
	// Vamps don't show up normally to scanners unless Masquerade power is on ----> scanner.dm
	if (mind)
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (istype(bloodsuckerdatum) && bloodsuckerdatum.poweron_masquerade)
			return BLOOD_VOLUME_NORMAL

	return blood_volume