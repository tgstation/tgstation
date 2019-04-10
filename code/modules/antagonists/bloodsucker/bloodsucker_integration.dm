




//				INTEGRATION: Adding Procs and Datums to existing "classes"




/mob/living/proc/AmBloodsucker(falseIfInDisguise=FALSE)
	// No Datum
	if (!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return FALSE

	return TRUE





// 			EXAMINING


/mob/living/carbon/human/proc/ReturnVampExamine(var/mob/viewer)
	// If Vamp or Vassal, show it.
	if (!mind || !viewer.mind)
		return
	// Only looking for Vamps here...
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (!bloodsuckerdatum)
		return
	// Viewer not a Vamp 									  	// ...AND not the target's vassal?
	if (!viewer.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))	// && !(viewer in bloodsuckerdatum.vassals))
		return

	// Default String
	var/returnString = "\[<span class='warning'><EM>[bloodsuckerdatum.ReturnFullName(src,1)]</EM></span>\]"

	// In Disguise (Veil)?
	//if (name_override != null)
	//	returnString += "<span class='suicide'> ([real_name] in disguise!) </span>"

	returnString += "\n"
	return returnString


//mob/living/carbon/human/proc/ReturnVassalExamine(var/mob/viewer)
//	return



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

