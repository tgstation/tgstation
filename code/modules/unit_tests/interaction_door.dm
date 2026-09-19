/// Tests that airlocks can be closed by clicking on the floor, as [/datum/component/redirect_attack_hand_from_turf ] dictates
/datum/unit_test/door_click

/datum/unit_test/door_click/Run()
	var/mob/living/carbon/human/consistent/tider = EASY_ALLOCATE()
	var/obj/machinery/door/airlock/public/glass/door = EASY_ALLOCATE()

	tider.forceMove(locate(door.x + 1, door.y, door.z))
	door.open() // this sleeps we just have to cope
	TEST_ASSERT(!door.operating, "Airlock was operating after being opened.")
	TEST_ASSERT(!door.density, "Airlock was not open after being opened.")
	click_wrapper(tider, get_turf(door))
	TEST_ASSERT(door.operating, "Airlock was not closing after clicking the turf below, as per /datum/component/redirect_attack_hand_from_turf.")

/// Tests that janitor keys can open airlocks
/datum/unit_test/keyring_on_door

/datum/unit_test/keyring_on_door/Run()
	var/mob/living/carbon/human/consistent/janitor = EASY_ALLOCATE()
	var/obj/machinery/door/airlock/instant/real_door = allocate(/obj/machinery/door/airlock/instant, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/access_key/keyring = EASY_ALLOCATE()

	real_door.req_access = list(ACCESS_HOP)
	keyring.department_access = REGION_COMMAND
	keyring.key_speed = 0
	janitor.put_in_active_hand(keyring)

	click_wrapper(janitor, real_door)
	TEST_ASSERT(!real_door.density, "Airlock could not be opened by janitor keyring")

/// Tests that door remotes can perform their various functions on airlocks
/datum/unit_test/door_remote

/datum/unit_test/door_remote/Run()
	var/mob/living/carbon/human/consistent/captain = EASY_ALLOCATE()
	var/obj/item/door_remote/remote = EASY_ALLOCATE()
	var/obj/machinery/door/airlock/instant/entrance = allocate(/obj/machinery/door/airlock/instant, get_step(run_loc_floor_bottom_left, EAST))

	entrance.req_access = list(ACCESS_COMMAND)
	captain.put_in_active_hand(remote)

	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.density, "Door remote opened a door it should not have had access to in melee")

	remote.access_list = list(ACCESS_COMMAND)
	click_wrapper(captain, entrance)
	TEST_ASSERT(!entrance.density, "Door remote failed to open a door it should have had access to in melee")

	entrance.req_access = null
	captain.forceMove(run_loc_floor_top_right)
	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.density, "Door remote failed to close a door with no access requirements at range")

	remote.attack_self(captain)
	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.locked, "Door remote failed to bolt a door")

	remote.attack_self(captain)
	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.emergency, "Door remote failed to set a door to emergency access")

	remote.obj_flags = EMAGGED
	remote.attack_self(captain)
	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.isElectrified(), "Door remote failed to shock a door while emagged")

	remote.attack_self(captain)
	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.main_power_timer, "Door remote failed to depower a door while emagged")

	entrance.unbolt()
	remote.attack_self(captain)
	click_wrapper(captain, entrance)
	TEST_ASSERT(entrance.density, "Door remote successfully opened a door that was depowered")
