/// Checks if any gloves or shoes that have non bio/fire/acid armor haven't been marked with ARMS or LEGS coverage respectively
/datum/unit_test/gloves_and_shoes_armor

/datum/unit_test/gloves_and_shoes_armor/Run()
	for (var/obj/item/clothing/gloves/gloves as anything in subtypesof(/obj/item/clothing/gloves))
		var/datum/armor/armor = gloves::armor_type
		if (!armor)
			continue

		if (gloves::body_parts_covered != HANDS)
			continue

		if (armor::melee || armor::bomb || armor::energy || armor::laser || armor::bullet || armor::wound)
			TEST_FAIL("[gloves] has non-bio/acid/fire armor but doesn't cover non-hand bodyparts.")

	for (var/obj/item/clothing/shoes/shoes as anything in subtypesof(/obj/item/clothing/shoes))
		var/datum/armor/armor = shoes::armor_type
		if (!armor)
			continue

		if (shoes::body_parts_covered != FEET)
			continue

		if (armor::melee || armor::bomb || armor::energy || armor::laser || armor::bullet || armor::wound)
			TEST_FAIL("[shoes] has non-bio/acid/fire armor but doesn't cover non-feet bodyparts.")
