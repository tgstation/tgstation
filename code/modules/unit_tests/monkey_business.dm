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
	var/monkey_weapon_index = 1 // which weapon to give the next angry monkey
	var/list/monkey_weapon_list = list(
		/obj/item/knife/shiv,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/energy/laser,
		/obj/item/melee/baseball_bat,
		/obj/item/melee/baton,
		/obj/item/storage/toolbox,
	)

/datum/unit_test/monkey_business/Run()
	for(var/monkey_id in 1 to length(GLOB.the_station_areas))
		var/area/monkey_zone = GLOB.areas_by_type[GLOB.the_station_areas[monkey_id]]
		var/mob/living/carbon/human/monkey = allocate(/mob/living/carbon/human/consistent, get_first_open_turf_in_area(monkey_zone))
		monkey.set_species(/datum/species/monkey)
		monkey.set_name("Monkey [monkey_id]")
		if(monkey_id % monkey_angry_nth == 0) // BLOOD FOR THE BLOOD GODS
			var/obj/next_weapon = monkey_weapon_list[monkey_weapon_index]
			monkey_weapon_index = (monkey_weapon_index % length(monkey_weapon_list)) + 1
			monkey.put_in_active_hand(new next_weapon())
			new /datum/ai_controller/monkey/angry(monkey)
			if(ispath(next_weapon, /obj/item/gun))
				monkey.ai_controller.set_blackboard_key(BB_MONKEY_GUN_NEURONS_ACTIVATED, TRUE)
		else
			new /datum/ai_controller/monkey(monkey)
		monkey.ai_controller.set_blackboard_key(BB_MONKEY_TARGET_MONKEYS, TRUE)
	sleep(monkey_timer)
