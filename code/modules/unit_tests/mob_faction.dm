/// Checks if any mob's faction var initial value is not a list, which is not supported by the current code
/datum/unit_test/mob_faction

/datum/unit_test/mob_faction/Run()
	/// Right now taken from create_and_destroy
	var/list/ignored = list(
		/mob/living/carbon,
		/mob/dview,
		/mob/oranges_ear
	)
	ignored += typesof(/mob/eye/imaginary_friend)
	ignored += typesof(/mob/living/silicon/robot/model)
	ignored += typesof(/mob/eye/camera/remote) // These will always just qdel themselves immediately if there was no creator arg

	/// We are going to add a 'test faction' here, something that won't be on any existing mobs
	var/test_faction = "about_to_be_poofed"
	/// Same as test_faction but for testing the list version of the proc
	var/list/test_factions = list("no_bugs_here", "look_over there")
	/// We are going to add a 'test ally' here, something that won't be on any existing mobs
	var/test_ally = "mybffjill"
	/// Same as test_ally but for testing the list version of the proc
	var/list/test_allies = list("mybffrose", "plank")

	// Bare sanity checks - do the procs work?
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/dummy_two = allocate(/mob/living/carbon/human/consistent)
	dummy_two.set_faction(list("copymeiguess"))

	if (dummy.faction_check_atom(dummy_two))
		TEST_FAIL("faction_check_atom() returned TRUE when it should have returned FALSE.")
	// set_faction()
	dummy.set_faction(test_factions)
	if (dummy.get_faction() != string_list(test_factions))
		TEST_FAIL("set_faction() failed to set the factions to the correct list! Instead: ([jointext(dummy.get_faction(), ", ")]). Ensure that you are using string_list().")
	// remove_faction() - list arg
	dummy.remove_faction(test_factions)
	if (!isnull(dummy.get_faction()))
		TEST_FAIL("remove_faction() did not remove the factions properly, they should be null! Instead: ([jointext(dummy.get_faction(), ", ")]). Ensure that you are using string_list().")
	// add_faction() - string arg
	dummy.add_faction(test_faction)
	if (dummy.get_faction() != string_list(list(test_faction)))
		TEST_FAIL("add_faction() did not add the test faction! Instead: ([jointext(dummy.get_faction(), ", ")]). Ensure that you are using string_list().")
	// remove_faction() - string arg
	dummy.remove_faction(test_faction)
	if (!isnull(dummy.get_faction()))
		TEST_FAIL("remove_faction() did not remove the test faction! Instead: ([jointext(dummy.get_faction(), ", ")]). Ensure that you are using string_list().")

	// set_allies()
	dummy.set_allies(test_allies)
	if (!dummy.has_ally(test_allies, match_all = TRUE))
		TEST_FAIL("set_faction() failed to set the allies to the correct list! Instead: ([jointext(dummy.allies, ", ")]). Ensure that you are using string_list().")
	// remove_ally() - list arg
	dummy.remove_ally(test_allies)
	if (!isnull(dummy.allies))
		TEST_FAIL("remove_ally() did not remove the allies properly, they should be null! Instead: ([jointext(dummy.allies, ", ")]). Ensure that you are using string_list().")
	// add_ally() - string arg
	dummy.add_ally(test_ally)
	if (!dummy.has_ally(test_ally))
		TEST_FAIL("add_ally() did not add the test ally! Instead: ([jointext(dummy.allies, ", ")]). Ensure that you are using string_list().")
	// remove_ally() - string arg
	dummy.remove_ally(test_ally)
	if (!isnull(dummy.allies))
		TEST_FAIL("remove_ally() did not remove the test ally! Instead: ([jointext(dummy.allies, ", ")]). Ensure that you are using string_list().")

	dummy.add_ally(dummy) // put the dummy's orgiginal ally (itself) back

	// Test adding the factions and allies of another mob
	APPLY_FACTION_AND_ALLIES_FROM(dummy, dummy_two)

	// Their allies should match
	if (!(dummy.has_ally(REF(dummy)) && dummy.has_ally(REF(dummy_two))))
		TEST_FAIL("apply_faction_and_allies() failed to add the correct allies. Should have both dummy's refs. Instead: ([jointext(dummy.allies, ", ")])")
	// Test the list arg version too
	else if (!dummy.has_ally(list(REF(dummy), REF(dummy_two))))
		TEST_FAIL("has_ally() failed to return TRUE when passed a list of allies.")
	if (!dummy.faction_check_atom(dummy_two))
		TEST_FAIL("faction_check_atom() returned FALSE when it should have returned TRUE.")

	// Their faction should match
	if (!(dummy.has_faction("copymeiguess")))
		TEST_FAIL("apply_faction_and_allies() failed to add the correct faction. Should have the second dummy's faction. Instead: ([jointext(dummy.get_faction(), ", ")])")
	// Test the list arg version too
	else if (!dummy.has_faction(dummy_two.get_faction()))
		TEST_FAIL("has_faction() failed to return TRUE when passed a list of allies.")

	// Test the setting version - should be an exact match
	SET_FACTION_AND_ALLIES_FROM(dummy, dummy_two)

	if (!dummy.has_ally(dummy_two) || dummy.has_ally(dummy))
		TEST_FAIL("set_faction_and_allies() failed to add the correct allies Should have just the second dummy's ref. Instead: ([jointext(dummy.get_faction(), ", ")])")
	if (!(dummy.has_faction("copymeiguess")))
		TEST_FAIL("set_faction_and_allies() failed to add the correct faction. Should have the second dummy's faction. Instead: ([jointext(dummy.get_faction(), ", ")])")

	for (var/mob_type in typesof(/mob) - ignored)
		var/mob/mob_instance = allocate(mob_type)
		var/list/mob_faction = mob_instance.get_faction()
		if(isnull(mob_faction))
			qdel(mob_instance)
			continue
		else if (!islist(mob_faction))
			TEST_FAIL("[mob_type] faction variable is not a list or null! Only lazy lists are supported currently (currently set to [mob_faction]).")
			qdel(mob_instance)
			continue
		else if (!LAZYLEN(mob_faction))
			TEST_FAIL("[mob_type] faction variable is an empty list! Set to null instead, faction lists are lazy.")
			qdel(mob_instance)
			continue

		/// Sanity - Let's test that no mobs are mutating or not being assigned a string list somewhere along the line
		var/expected_faction = string_list(mob_faction)
		if(mob_faction != expected_faction)
			TEST_FAIL("Faction list does not match the cached string_list()! Make sure you are using the add_faction and remove_faction procs, \
				and not editing the faction list directly anywhere. Also make sure that the faction list is getting string_list()'d in the first place. \
				e.g. your mob might be short circuiting Initialize() (or returning INITIALIZE_HINT_QDEL). Either add string_list() its faction list, \
				or add its type to the ignored list if appropriate. \
				mob: [mob_instance]([mob_instance.type]) current factions: ([jointext(mob_faction, ", ")]) expected factions: ([jointext(expected_faction, ", ")])")
		qdel(mob_instance)
