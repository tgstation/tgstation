




//				INTEGRATION: Adding Procs and Datums to existing "classes"




/mob/living/proc/AmBloodsucker(falseIfInDisguise=FALSE)
	// No Datum
	if (!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return FALSE

	return TRUE





// 			EXAMINING


/mob/living/carbon/human/proc/ReturnVampExamine(var/mob/viewer)
	// If Vamp or Vassal, show it.
	return

//mob/living/carbon/human/proc/ReturnVassalExamine(var/mob/viewer)
//	return



// Am I "pale" when examined? Bloodsuckers can trick this.
/mob/living/carbon/proc/ShowAsPaleExamine()

	// Normal Creatures:
	if(!mind || !mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		return blood_volume < BLOOD_VOLUME_SAFE

	// If a Bloodsucker is malnourished, AND if his temperature matches his surroundings (aka he hasn't fed recently and looks COLD)...
	return blood_volume < BLOOD_VOLUME_BAD && !(bodytemperature <= get_temperature() + 2)

