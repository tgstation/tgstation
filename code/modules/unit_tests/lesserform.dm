/// Unit test to ensure that changelings can consistently turn from monkeys to humans and back
/datum/unit_test/lesserform

/datum/unit_test/lesserform/Run()
	var/mob/living/carbon/human/changeling = allocate(/mob/living/carbon/human/consistent)
	var/name = changeling.name
	changeling.mind_initialize()
	var/datum/mind/mind = changeling.mind
	var/datum/antagonist/changeling/changeling_datum = mind.add_antag_datum(/datum/antagonist/changeling)
	changeling_datum.adjust_chemicals(INFINITY) // We don't care about how many chemicals they have
	var/datum/action/changeling/lesserform/transform_ability = new(changeling)
	transform_ability.transform_instantly = TRUE
	transform_ability.Grant(changeling)

	transform_ability.Trigger()
	TEST_ASSERT(ismonkey(changeling), "Changeling failed to turn into a monkey after voluntarily transforming using lesser form.")
	TEST_ASSERT_NOTEQUAL(name, changeling.name, "Monkeyisation failed to anonymise changeling's name.")
	changeling.humanize(instant = TRUE)
	transform_ability.Trigger()
	TEST_ASSERT(ismonkey(changeling), "Changeling failed to turn into a monkey after involuntarily being made into a human.")
	transform_ability.Trigger()
	TEST_ASSERT(!ismonkey(changeling), "Changeling failed to stop being a monkey after voluntarily transforming using lesser form.")
	TEST_ASSERT_EQUAL(name, changeling.name, "Returning from monkey form failed to restore original name.")
	changeling.monkeyize(instant = TRUE)
	transform_ability.Trigger()
	TEST_ASSERT(!ismonkey(changeling), "Changeling failed to stop being a monkey after being involuntarily turned into one.")
