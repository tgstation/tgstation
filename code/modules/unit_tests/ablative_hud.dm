/// Check that player gains and loses sec hud when toggling the ablative hood
/datum/unit_test/ablative_hood_hud

/datum/unit_test/ablative_hood_hud/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/suit/hooded/ablative/coat = allocate(/obj/item/clothing/suit/hooded/ablative)
	var/datum/component/toggle_attached_clothing/hood = coat.GetComponent(/datum/component/toggle_attached_clothing)
	person.equip_to_slot(coat, ITEM_SLOT_OCLOTHING)
	TEST_ASSERT(!HAS_TRAIT(person, TRAIT_SECURITY_HUD), "Person already had a sechud before trying to equip the ablative hood.")
	hood.toggle_deployable()
	TEST_ASSERT(HAS_TRAIT(person, TRAIT_SECURITY_HUD), "Person toggled the ablative hood but didn't gain a sechud.")
	hood.toggle_deployable()
	TEST_ASSERT(!HAS_TRAIT(person, TRAIT_SECURITY_HUD), "Person lowered their ablative hood but still has a sechud.")

// Check that player doesn't gain sec hud if the hood is toggled when already wearing a helmet
/datum/unit_test/ablative_hood_hud_with_helmet

/datum/unit_test/ablative_hood_hud_with_helmet/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/suit/hooded/ablative/coat = allocate(/obj/item/clothing/suit/hooded/ablative)
	var/datum/component/toggle_attached_clothing/hood = coat.GetComponent(/datum/component/toggle_attached_clothing)
	var/obj/item/clothing/head/helmet/hat = allocate(/obj/item/clothing/head/helmet)
	person.equip_to_slot(coat, ITEM_SLOT_OCLOTHING)
	person.equip_to_slot(hat, ITEM_SLOT_HEAD)
	TEST_ASSERT(!HAS_TRAIT(person, TRAIT_SECURITY_HUD), "Person already had a sechud before trying to equip the ablative hood.")
	hood.toggle_deployable()
	TEST_ASSERT(!HAS_TRAIT(person, TRAIT_SECURITY_HUD), "Person has gained a sechud from toggling the ablative hood despite already wearing a helmet.")
