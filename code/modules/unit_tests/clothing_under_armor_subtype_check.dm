/**
 * Test if all jumpsuits are using the proper armor subtype.
 */
/datum/unit_test/clothing_under_armor_subtype_check

/datum/unit_test/clothing_under_armor_subtype_check/Run()
	for(var/obj/item/clothing/under/jumpsuit as anything in typesof(/obj/item/clothing/under))
		if(!ispath(initial(UNLINT(jumpsuit.armor_type)), /datum/armor/clothing_under))
			TEST_FAIL("[jumpsuit] does not use clothing_under as its armor!")
