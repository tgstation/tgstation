/// Checks to ensure strange reagent works as expected
/datum/unit_test/strange_reagent
	priority = TEST_LONGER

	var/datum/reagent/medicine/strange_reagent/instant/strange_reagent
	var/target_max_health
	var/amount_needed_to_full_heal
	var/amount_needed_to_revive

/datum/unit_test/strange_reagent/Run()
	strange_reagent = new

	var/list/types_to_check = typecacheof(list(
		/mob/living/carbon/human,
		/mob/living/simple_animal,
		/mob/living/basic,
	))
	types_to_check -= /mob/living/simple_animal/pet/gondola/gondolapod // need a pod, which we don't have

	for(var/mob/living/type as anything in types_to_check)
		var/mob/living/target = allocate_new_target(type)
		if(target.status_flags & GODMODE)
			continue
		if(!(target.mob_biotypes & MOB_ORGANIC))
			continue
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/simple_animal = target
			if(simple_animal.del_on_death)
				continue
			simple_animal.loot?.Cut()
		if(istype(target, /mob/living/basic))
			var/mob/living/basic/basic = target
			if(basic.basic_mob_flags & DEL_ON_DEATH)
				continue

		test_damage_but_no_death(type)
		test_death_no_damage(type)
		test_death_with_damage(type)
		test_death_with_damage_but_not_enough_reagent(type)
		test_death_with_full_heal(type)
		test_death_from_damage(type)
		test_death_from_too_much_damage(type)
	// cleanup our vars
	QDEL_NULL(strange_reagent)
	allocate_new_target(null)

/datum/unit_test/strange_reagent/proc/allocate_new_target(type)
	// cache the last one created so that we don't create N instances of the exact same mob
	var/static/mob/living/pre_allocated
	if(!type)
		pre_allocated = null
		return

	if(pre_allocated?.type == type)
		pre_allocated.revive(ALL) // for some reason HEAL_ADMIN doesn't work?
		return pre_allocated

	pre_allocated = allocate(type)
	target_max_health = pre_allocated.getMaxHealth()
	update_amounts(pre_allocated)
	return pre_allocated

/datum/unit_test/strange_reagent/proc/update_amounts(mob/living/target)
	amount_needed_to_full_heal = strange_reagent.calculate_amount_needed_to_full_heal()
	amount_needed_to_revive = strange_reagent.calculate_amount_needed_to_revive()

/datum/unit_test/strange_reagent/proc/damage_target_to_percentage(mob/living/target, percent)
	var/damage = target_max_health * percent * 0.5
	target.adjustBruteLoss(damage)
	target.adjustFireLoss(damage)
	update_amounts(target)
	if(percent >= 1)
		TEST_ASSERT_EQUAL(target.stat, DEAD, "Target type [target.type] should be dead but isnt")
		return FALSE
	return TRUE

/datum/unit_test/strange_reagent/proc/test_damage_but_no_death(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	if(!damage_target_to_percentage(target, 0.8))
		return

	var/health = target.get_organic_health()
	strange_reagent.expose_mob(target, INGEST, 20)
	TEST_ASSERT_EQUAL(health, target.get_organic_health(), "Strange Reagent healed a target type [target.type] that was not dead.")

/datum/unit_test/strange_reagent/proc/test_death_no_damage(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	target.death()
	update_amounts(target)
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive)
	TEST_ASSERT_EQUAL(target_max_health, target.get_organic_health(), "Strange Reagent did not revive a dead target type [target.type].")

/datum/unit_test/strange_reagent/proc/test_death_with_damage(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	if(!damage_target_to_percentage(target, 0.8))
		return

	target.death()
	update_amounts(target)
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive)
	TEST_ASSERT_NOTEQUAL(target.stat, DEAD, "Strange Reagent did not revive a dead target type [target.type].")

/datum/unit_test/strange_reagent/proc/test_death_with_damage_but_not_enough_reagent(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	if(!damage_target_to_percentage(target, 0.8))
		return

	target.death()
	update_amounts(target)
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive - 1)
	TEST_ASSERT_NOTEQUAL(target.stat, DEAD, "Strange Reagent did not revive a dead target type [target.type].")

/datum/unit_test/strange_reagent/proc/test_death_with_full_heal(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	if(!damage_target_to_percentage(target, 0.8))
		return

	target.death()
	update_amounts(target)
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_full_heal)
	TEST_ASSERT_EQUAL(target_max_health, target.get_organic_health(), "Strange Reagent did not fully heal a dead target type [target.type] with the expected amount.")

/datum/unit_test/strange_reagent/proc/test_death_from_damage(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	if(!damage_target_to_percentage(target, 1.6)) // under the 2x damage cap
		return

	update_amounts(target)
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive)
	TEST_ASSERT_NOTEQUAL(target.stat, DEAD, "Strange Reagent did not revive a target type [target.type] who died from damage.")

/datum/unit_test/strange_reagent/proc/test_death_from_too_much_damage(target_type)
	var/mob/living/target = allocate_new_target(target_type)
	if(!damage_target_to_percentage(target, 3)) // over the 2x damage cap
		return

	update_amounts(target)
	strange_reagent.expose_mob(target, INGEST, amount_needed_to_revive + 1)
	TEST_ASSERT_EQUAL(target.stat, DEAD, "Strange Reagent revived a target type [target.type] with more than double their max health in damage.")
