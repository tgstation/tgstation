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
	priority = TEST_LONGER
	var/monkey_timer = 30 SECONDS
	var/monkey_angry_nth = 5 // every nth monkey will be angry

/datum/unit_test/monkey_business/Run()
	for(var/monkey_id in 1 to length(GLOB.the_station_areas))
		var/mob/living/carbon/human/monkey = allocate(/mob/living/carbon/human/consistent, get_first_open_turf_in_area(GLOB.the_station_areas[monkey_id]))
		monkey.set_species(/datum/species/monkey)
		monkey.set_name("Monkey [monkey_id]")
		if(monkey_id % monkey_angry_nth == 0) // BLOOD FOR THE BLOOD GODS
			monkey.put_in_active_hand(new /obj/item/knife/shiv)
			new /datum/ai_controller/monkey/angry(monkey)
		else
			new /datum/ai_controller/monkey(monkey)
		monkey.ai_controller.blackboard[BB_MONKEY_TARGET_MONKEYS] = TRUE
	sleep(monkey_timer)
