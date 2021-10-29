/datum/antagonist
	///Whether the antagonist uses ambitions
	var/uses_ambitions = FALSE

///This gets called after our ambitions are submitted, or the antag datum is given to someone with filled ambitions
/datum/antagonist/proc/ambitions_add()
	return

///This gets called to remove things from an antagonist, given that they had ambitions submitted (ie. remove powers from ling, remove uplink from traitors)
/datum/antagonist/proc/ambitions_removal()
	return

/datum/antagonist/traitor
	uses_ambitions = TRUE

/datum/antagonist/traitor/ambitions_add()
	if(give_uplink)
		owner.give_uplink(silent = TRUE, antag_datum = src)
	uplink = owner.find_syndicate_uplink()

/datum/antagonist/changeling
	uses_ambitions = TRUE

/datum/antagonist/changeling/ambitions_add()
	create_actions()
	reset_powers()
	create_initial_profile()

/datum/antagonist/changeling/ambitions_removal()
	remove_changeling_powers()

/datum/antagonist/wizard
	uses_ambitions = TRUE

/datum/antagonist/wizard/ambitions_add()
	equip_wizard() //This apparently give the book if you didn't comment it in the antag one, you could use it and if you did get spells and then submit your ambitions, You actually could get twice as much spells. :pain:

/datum/antagonist/wizard/ambitions_removal()
	owner.RemoveAllSpells()

/datum/objective/ambitions
	name = "ambitions"
	explanation_text = "Open up ambitions from the IC tab and craft your unique antagonistic story."

/datum/objective/ambitions/check_completion()
	return TRUE
