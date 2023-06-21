/**
 * Test if all jumpsuits are using the proper armor subtype.
 */
/datum/unit_test/clothing_under_armor_subtype_check

/datum/unit_test/clothing_under_armor_subtype_check/Run()
	for(var/obj/item/clothing/under/jumpsuit as anything in typesof(/obj/item/clothing/under))
		TEST_ASSERT(istype(initial(jumpsuit.armor_type), /datum/armor/clothing_under), "[initial(jumpsuit.type)] does not use clothing_under as its armor!")
