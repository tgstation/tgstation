




//				INTEGRATION: Adding Procs and Datums to existing "classes"




/mob/living/proc/AmBloodsucker(falseIfInDisguise=FALSE)
	// No Datum
	if (!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return FALSE

	return TRUE





// 			EXAMINING





/mob/living/carbon/human/proc/ReturnVampExamine(var/mob/viewer)
	if (!mind || !viewer.mind)
		return ""
	// Target must be a Vamp
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (!bloodsuckerdatum)
		return ""
	// Viewer not a Vamp AND not the target's vassal?
	if (!viewer.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))// && !(viewer in bloodsuckerdatum.vassals))
		return ""

	// Default String
	var/returnString = "\[<span class='warning'><EM>[bloodsuckerdatum.ReturnFullName(src,1)]</EM></span>\]"
	var/returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "bloodsucker")]"

	// In Disguise (Veil)?
	//if (name_override != null)
	//	returnString += "<span class='suicide'> ([real_name] in disguise!) </span>"

	returnString += "\n"
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
		returnString +=	"<span class='boldwarning'>This [dna.species.name] bears the mark of [vassaldatum.master.ReturnFullName(vassaldatum.master.owner.current,1)]</span>"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal_grey")]"
	// Are you serving the same master as I am?
	else if (viewer.mind.has_antag_datum(ANTAG_DATUM_VASSAL) in vassaldatum.master.vassals)
		returnString += "[p_they(TRUE)] bears the mark of your Master"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal")]"
	// You serve a different Master than I do.
	else
		returnString += "<span class='boldwarning'>[p_they(TRUE)] bears the mark of another Bloodsucker</span>"
		returnIcon = "[icon2html('icons/Fulpicons/fulpicons_small.dmi', world, "vassal_grey")]"

	returnString += "</span>\]\n"
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

