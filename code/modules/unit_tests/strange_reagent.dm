/// Checks to ensure strange reagent works as expected
/datum/unit_test/strange_reagent
	var/datum/reagent/medicine/strange_reagent/strange_reagent
	var/mob/living/target
	var/target_max_health
	var/amount_needed_to_full_heal
	var/amount_needed_to_revive

/datum/unit_test/strange_reagent/Run()
	strange_reagent = new

	var/list/types_to_check = typecacheof(list(
		/mob/living/carbon/human,
		/mob/living/simple_animal,
	))
	for(var/mob/living/type as anything in types_to_check)
		allocate_new_target(type)
		if(target.status_flags & GODMODE)
			continue
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/simple_animal = target
			simple_animal.loot?.Cut()

		test_damage_but_no_death(type)
		test_death_no_damage(type)
		test_death_with_damage(type)
		test_death_with_damage_but_not_enough_reagent(type)
		test_death_with_full_heal(type)
		test_death_from_damage(type)
		test_death_from_too_much_damage(type)
	// cleanup our vars
	QDEL_NULL(strange_reagent)
	QDEL_NULL(target)

/datum/unit_test/strange_reagent/proc/allocate_new_target(type)
	if(src.target?.type == type)
		src.target.revive(HEAL_ADMIN)
		return

	var/mob/living/target = allocate(type)
	target_max_health = target.getMaxHealth()
	src.target = target
	update_amounts()

/datum/unit_test/strange_reagent/proc/update_amounts()
	var/damage = target_max_health - target.get_organic_health()
	amount_needed_to_full_heal = CEILING(damage, strange_reagent.healing_per_reagent_unit) + 1
	amount_needed_to_revive = CEILING(-target.get_organic_health(), strange_reagent.healing_per_reagent_unit) + 1
	if(amount_needed_to_revive <= 0)
		amount_needed_to_revive = 1

/datum/unit_test/strange_reagent/proc/damage_target_to_percentage(percent)
	var/damage = target_max_health * percent * 0.5
	target.adjustBruteLoss(damage)
	target.adjustFireLoss(damage)
	update_amounts()
	if(percent >= 1)
		TEST_ASSERT_EQUAL(target.stat, DEAD, "Target should be dead but isnt")
		return FALSE
	return TRUE

/datum/unit_test/strange_reagent/proc/test_damage_but_no_death(target_type)
	allocate_new_target(target_type)
	if(!damage_target_to_percentage(0.8))
		return

	var/health = target.get_organic_health()
	strange_reagent.expose_mob(target, INGEST, 20)
	TEST_ASSERT_EQUAL(health, target.get_organic_health(), "Strange Reagent healed a target that was not dead.")

/datum/unit_test/strange_reagent/proc/test_death_no_damage(target_type)
	allocate_new_target(target_type)
	target.death()
	update_amounts()
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive)
	TEST_ASSERT_EQUAL(target_max_health, target.get_organic_health(), "Strange Reagent did not revive a dead target.")

/datum/unit_test/strange_reagent/proc/test_death_with_damage(target_type)
	allocate_new_target(target_type)
	if(!damage_target_to_percentage(0.8))
		return

	target.death()
	update_amounts()
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive)
	TEST_ASSERT_NOTEQUAL(target.stat, DEAD, "Strange Reagent did not revive a dead target.")

/datum/unit_test/strange_reagent/proc/test_death_with_damage_but_not_enough_reagent(target_type)
	allocate_new_target(target_type)
	if(!damage_target_to_percentage(0.8))
		return

	target.death()
	update_amounts()
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive - 1)
	TEST_ASSERT_NOTEQUAL(target.stat, DEAD, "Strange Reagent did not revive a dead target.")

/datum/unit_test/strange_reagent/proc/test_death_with_full_heal(target_type)
	allocate_new_target(target_type)
	if(!damage_target_to_percentage(0.8))
		return

	target.death()
	update_amounts()
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_full_heal)
	TEST_ASSERT_EQUAL(target_max_health, target.get_organic_health(), "Strange Reagent did not fully heal a dead target with the expected amount.")

/datum/unit_test/strange_reagent/proc/test_death_from_damage(target_type)
	allocate_new_target(target_type)
	if(!damage_target_to_percentage(1.6)) // under the 2x damage cap
		return

	update_amounts()
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive)
	TEST_ASSERT_NOTEQUAL(target.stat, DEAD, "Strange Reagent did not revive a target who died from damage.")

/datum/unit_test/strange_reagent/proc/test_death_from_too_much_damage(target_type)
	allocate_new_target(target_type)
	if(!damage_target_to_percentage(3)) // over the 2x damage cap
		return

	update_amounts()
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive + 1)
	TEST_ASSERT_EQUAL(target.stat, DEAD, "Strange Reagent revived a target with more than double their max health in damage.")
