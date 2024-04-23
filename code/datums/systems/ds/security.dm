DATASYSTEM_DEF(security)
	name = "Security"

	var/total_points = 0
	var/points_spent = 0
	var/available_points = 0

	var/warcrimes = 0
	var/list/datum/weakref/criminals_apprehended = list()

/datum/system/security/proc/add_new_criminal(mob/living/baddie)
	criminals_apprehended += WEAKREF(baddie)

	if(!baddie.mind?.has_antag_datum(/datum/antagonist))
		warcrimes++
		return FALSE

	total_points += 500
	available_points += 500
	return TRUE
