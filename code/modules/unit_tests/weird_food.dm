/// Unit test to ensure that moths can eat t-shirts successfully
/datum/unit_test/moth_food

/datum/unit_test/moth_food/Run()
	var/obj/item/clothing/suit/armor/bulletproof/light_snack = allocate(/obj/item/clothing/suit/armor/bulletproof)
	light_snack.create_moth_snack()
	var/datum/component/edible/eatability = light_snack.moth_snack.GetComponent(/datum/component/edible)
	eatability.eat_time = 0

	var/mob/living/carbon/human/species/moth/gourmet = allocate(/mob/living/carbon/human/species/moth)
	gourmet.nutrition = 0 // We need to be sufficiently hungry
	gourmet.put_in_active_hand(light_snack)

	var/times_to_bite = round(light_snack.max_integrity / MOTH_EATING_CLOTHING_DAMAGE) + 1
	for (var/i in 1 to times_to_bite)
		TEST_ASSERT(!QDELETED(light_snack), "Moth finished eating clothes faster than expected.")
		var/old_integrity = light_snack.get_integrity()
		light_snack.attack(gourmet, gourmet)
		TEST_ASSERT(light_snack.get_integrity() < old_integrity, "Clothing didn't take damage when bitten by moth.")
	TEST_ASSERT(QDELETED(light_snack), "Moth failed to finish eating clothing. Integrity left: [light_snack.get_integrity()]")

/// Unit test to ensure that golems can eat rocks successfully
/datum/unit_test/golem_food

/datum/unit_test/golem_food/Run()
	var/obj/item/stack/sheet/mineral/uranium/five/dinner = allocate(/obj/item/stack/sheet/mineral/uranium/five)
	var/datum/component/golem_food/golem_food_data = dinner.GetComponent(/datum/component/golem_food)
	golem_food_data.create_golem_snack(dinner)
	var/datum/component/edible/eatability = golem_food_data.golem_snack.GetComponent(/datum/component/edible)
	eatability.eat_time = 0

	var/mob/living/carbon/human/species/golem/rock_enjoyer = allocate(/mob/living/carbon/human/species/golem)
	rock_enjoyer.nutrition = 0 // We need to be sufficiently hungry
	rock_enjoyer.put_in_active_hand(dinner)

	var/status_applied = golem_food_data.snack_type.status_effect
	var/times_to_bite = dinner.amount
	for (var/i in 1 to times_to_bite)
		TEST_ASSERT(!QDELETED(dinner), "Golem finished eating rocks faster than expected.")
		dinner.attack(rock_enjoyer, rock_enjoyer)
	TEST_ASSERT(QDELETED(dinner), "Golem failed to finish eating rocks.")
	TEST_ASSERT(rock_enjoyer.has_status_effect(status_applied), "Golem didn't gain a food buff from eating its rocks.")
