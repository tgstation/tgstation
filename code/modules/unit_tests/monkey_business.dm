/**
 * Monkey Business
 *
 * This unit test spawns a predefined number of monkies, each of which
 * are set to have a 100% chance of attempting to use something next to them each Life
 *
 * This test basically just checks to see if attack procs are working correctly,
 * but its also hilarious and fun to watch locally.
 */
/datum/unit_test/monkey_business
	priority = TEST_DEFAULT + 1 // should be the last test to run, except for create and destroy
	var/monkey_count = 50
	var/monkey_timer = 30 SECONDS
	var/start_runtimes = 0
	var/list/monkey_list
	var/running = TRUE

/datum/unit_test/monkey_business/Run()
	monkey_list = list()
	start_runtimes = GLOB.total_runtimes
	for(var/monkey_id in 1 to monkey_count)
		var/turf/spawn_turf = get_safe_random_station_turf()
		var/mob/living/carbon/human/monkey = new /mob/living/carbon/human(spawn_turf)
		monkey.set_name("Monkey [monkey_id]")
		monkey.set_species(/datum/species/monkey)
		if(prob(10)) // BLOOD FOR THE BLOOD GODS
			monkey.put_in_active_hand(new /obj/item/knife/shiv)
			new /datum/ai_controller/monkey/angry(monkey)
		else
			new /datum/ai_controller/monkey(monkey)
		monkey_list += monkey
	addtimer(CALLBACK(src, .proc/finalize), monkey_timer)
	while(running)
		sleep(2 TICKS)

/datum/unit_test/monkey_business/proc/finalize()
	QDEL_LIST(monkey_list)
	var/monkey_runtimes = GLOB.total_runtimes - start_runtimes
	if(monkey_runtimes)
		TEST_FAIL("Monkey Business caused [monkey_runtimes] runtimes")
	running = FALSE

/// This is a copy/paste of monkey_set_combat_target/perform, but without the check preventing a monkey from aggroing to another monkey
/// Relies on unit tests loading after AI code, which is a safe assumption

/datum/ai_behavior/monkey_set_combat_target/perform(delta_time, datum/ai_controller/controller, set_key, enemies_key)
	var/list/enemies = controller.blackboard[enemies_key]
	var/list/valids = list()
	for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, controller.pawn))
		var/datum/weakref/enemy_ref = WEAKREF(possible_enemy)
		if(possible_enemy == controller.pawn || (!enemies[enemy_ref] && (!controller.blackboard[BB_MONKEY_AGGRESSIVE]))) //Are they an enemy? (And do we even care?)
			continue
		// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
		valids[enemy_ref] = CEILING(100 / (get_dist(controller.pawn, possible_enemy) || 1), 1)

	if(!valids.len)
		finish_action(controller, FALSE)
	controller.blackboard[set_key] = pick_weight(valids)
	finish_action(controller, TRUE)
