/datum/antagonist/vassal/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(vassal_warning_message)
		to_chat(owner, vassal_warning_message)

/**
 * Returns a Vassals's examine strings.
 * Args:
 * viewer - The person examining.
 */
/datum/antagonist/vassal/proc/return_vassal_examine(mob/living/viewer)
	if(!viewer.mind || !iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/carbon_current = owner.current
	// Target must be a Vassal
	// Default String
	var/returnString = "\[<span class='warning'>"
	var/returnIcon = ""
	// Vassals and Bloodsuckers recognize eachother, while Monster Hunters can see Vassals.
	if(!IS_BLOODSUCKER(viewer) && !IS_VASSAL(viewer))
		return FALSE
	// Am I Viewer's Vassal?
	if(master.owner == viewer.mind)
		returnString += "This [carbon_current.dna.species.name] bears YOUR mark!"
		returnIcon = "[icon2html('modular_meta/features/antagonists/icons/bloodsuckers/vampiric.dmi', world, "vassal")]"
	// Am I someone ELSE'S Vassal?
	else if(IS_BLOODSUCKER(viewer))
		returnString += "This [carbon_current.dna.species.name] bears the mark of <span class='boldwarning'>[master.return_full_name()][master.broke_masquerade ? " who has broken the Masquerade" : ""]</span>"
		returnIcon = "[icon2html('modular_meta/features/antagonists/icons/bloodsuckers/vampiric.dmi', world, "vassal_grey")]"
	// Are you serving the same master as I am?
	else if(viewer.mind.has_antag_datum(/datum/antagonist/vassal) in master.vassals)
		returnString += "[p_they(TRUE)] bears the mark of your Master"
		returnIcon = "[icon2html('modular_meta/features/antagonists/icons/bloodsuckers/vampiric.dmi', world, "vassal")]"
	// You serve a different Master than I do.
	else
		returnString += "[p_they(TRUE)] bears the mark of another Bloodsucker"
		returnIcon = "[icon2html('modular_meta/features/antagonists/icons/bloodsuckers/vampiric.dmi', world, "vassal_grey")]"

	returnString += "</span>\]" // \n"  Don't need spacers. Using . += "" in examine.dm does this on its own.
	return returnIcon + returnString

/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
	powers += power
	power.Grant(owner.current)
	log_uplink("[key_name(owner.current)] purchased [power].")

/datum/antagonist/vassal/proc/LevelUpPowers()
	for(var/datum/action/cooldown/bloodsucker/power in powers)
		power.level_current++

/// Called when we are turned into a special type of vassal.
/datum/antagonist/vassal/proc/make_special(datum/antagonist/vassal/vassal_type)
	//store what we need
	var/datum/mind/vassal_owner = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = master

	//remove our antag datum
	silent = TRUE
	vassal_owner.remove_antag_datum(/datum/antagonist/vassal)

	//give our new one
	var/datum/antagonist/vassal/vassaldatum = new vassal_type(vassal_owner)
	vassaldatum.master = bloodsuckerdatum
	vassaldatum.silent = TRUE
	vassal_owner.add_antag_datum(vassaldatum)
	vassaldatum.silent = FALSE

	//send alerts of completion
	to_chat(master, span_danger("You have turned [vassal_owner.current] into your [vassaldatum.name]! They will no longer be deconverted upon mindshielding!"))
	to_chat(vassal_owner, span_notice("As blood drips over your body, you feel closer to your master... you are now the [vassaldatum.name]!"))
	vassal_owner.current.playsound_local(null, 'sound/effects/magic/mutate.ogg', 75, FALSE, pressure_affected = FALSE)
