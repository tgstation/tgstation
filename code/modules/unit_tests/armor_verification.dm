/// Verifies that armor procs are working as expected
/datum/unit_test/armor_verification

/datum/unit_test/armor_verification/Run()
	var/obj/dummy = allocate(/obj)

	dummy.set_armor(/datum/armor/none)
	var/datum/armor/armor = dummy.get_armor()
	TEST_ASSERT_NOTNULL(armor, "armor didn't populate correctly when needed")
	TEST_ASSERT_EQUAL(armor_totals(armor), 0, "none armor type had armor values")

	armor = armor.generate_new_with_specific(list(FIRE = 20))
	TEST_ASSERT_EQUAL(armor_totals(armor), 20, "modified armor type had incorrect values")

	armor = armor.generate_new_with_specific(list(ACID = 20))
	TEST_ASSERT_EQUAL(armor_totals(armor), 40, "modified armor type had incorrect values")

	armor = get_armor_by_type(/datum/armor/immune)
	var/totals = armor_totals(armor)
	armor = armor.generate_new_with_multipliers(list(ARMOR_ALL = 0))
	TEST_ASSERT_EQUAL(armor_totals(armor), totals, "modified an immune armor type")

	var/wanted = 40
	dummy.set_armor(/datum/armor/none)
	dummy.set_armor_rating(ENERGY, wanted * 0.5)
	dummy.set_armor_rating(FIRE, wanted * 0.5)
	TEST_ASSERT_EQUAL(armor_totals(dummy.get_armor()), wanted, "modified armor type had incorrect values")

/datum/unit_test/armor_verification/proc/armor_totals(datum/armor/armor)
	var/total = 0
	for(var/key in ARMOR_LIST_ALL)
		total += armor.vars[key]
	return total
