DATASYSTEM_DEF(security)
	name = "Security"

	var/total_points = 0
	var/points_spent = 0
	var/points_available = 0

	var/warcrimes = 0
	var/list/criminals_apprehended = list()

/datum/system/security/proc/add_new_criminal(mob/living/baddie)
	criminals_apprehended += baddie

	if(!baddie.mind?.has_antag_datum(/datum/antagonist))
		warcrimes++
		return

	total_points += 500
	points_available += 500
