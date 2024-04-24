DATASYSTEM_DEF(security)
	name = "Security"

	/// Points that are available to be spent.
	var/available_points = 0
	/// List of criminals apprehended.
	var/list/datum/weakref/criminals_apprehended = list()
	/// Points that have been spent on upgrades.
	var/points_spent = 0
	/// Total points accumulated by the security department.
	var/total_points = 0
	/// Non-antagonist criminals apprehended.
	var/warcrimes = 0

/// Adds a weakref of the criminal to the list and awards points if the criminal is an antagonist.
/datum/system/security/proc/add_new_criminal(mob/living/baddie)
	criminals_apprehended += WEAKREF(baddie)

	if(!baddie.mind?.has_antag_datum(/datum/antagonist))
		warcrimes++
		return FALSE

	total_points += 500
	available_points += 500
	return TRUE
