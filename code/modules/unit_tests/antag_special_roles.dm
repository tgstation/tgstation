/// Verifies that all antag special roles are in GLOB.special_roles
/datum/unit_test/antag_special_roles

/datum/unit_test/antag_special_roles/Run()
	for(var/datum/antagonist/antag as anything in subtypesof(/datum/antagonist))
		// Ignore antags that don't have preview outfits, as they likely aren't preferences.
		if(!ispath(antag::preview_outfit))
			continue
		// For obvious reasons, skip over unset roles.
		var/role = antag::job_rank
		if(!istext(role))
			continue
		TEST_ASSERT(!isnull(GLOB.special_roles[role]), "Antagonist role [role] (used by [antag]) was not present in GLOB.special_roles!")
