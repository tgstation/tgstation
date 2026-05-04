///Test that ensures that basic functions and interactions around suit sensors are working
/datum/unit_test/suit_sensor

/datum/unit_test/suit_sensor/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__)
	var/obj/item/clothing/under/sensor_test/under = allocate(__IMPLIED_TYPE__)

	dummy.equip_to_slot_or_del(under, ITEM_SLOT_ICLOTHING)

	TEST_ASSERT(under.set_sensor_mode(SENSOR_LIVING), "couldn't set the suit sensor mode to '[GLOB.suit_sensor_mode_to_defines[SENSOR_LIVING + 1]]'")
	TEST_ASSERT((dummy in GLOB.suit_sensors_list), "couldn't find the dummy in the GLOB.suit_sensors_list")

	var/obj/item/wirecutters/cutter = allocate(__IMPLIED_TYPE__)
	dummy.put_in_active_hand(cutter, forced = TRUE)
	click_wrapper(dummy, under) //cut sensor
	TEST_ASSERT_EQUAL(under.has_sensor, NO_SENSORS, "couldn't properly cut suit sensor from the jumpsuit")

	var/obj/item/suit_sensor/sensor = dummy.is_holding_item_of_type(__IMPLIED_TYPE__)
	TEST_ASSERT(sensor, "dummy isn't holding the cut sensor")
	//we set it to sensor_living before, remember?
	TEST_ASSERT_EQUAL(sensor.sensor_mode, SENSOR_LIVING, "cut sensor isn't set to '[GLOB.suit_sensor_mode_to_defines[SENSOR_LIVING + 1]]'")
	TEST_ASSERT(sensor.set_mode(SENSOR_OFF), "couldn't set cut sensor's mode to '[GLOB.suit_sensor_mode_to_defines[SENSOR_OFF + 1]]'")
	sensor.emp_act(EMP_HEAVY)
	TEST_ASSERT(sensor.broken, "cut sensor wasn't broken by EMP")

	dummy.dropItemToGround(cutter) //thank you for your service, wirecutters o7
	var/obj/item/stack/cable_coil/thirty/coil = allocate(__IMPLIED_TYPE__)
	dummy.put_in_active_hand(coil, forced = TRUE)
	click_wrapper(dummy, sensor) //fix sensor
	TEST_ASSERT(!sensor.broken, "cut sensor couldn't be fixed by cable coil")

	dummy.swap_hand(dummy.get_held_index_of_item(sensor))
	click_wrapper(dummy, under) //install sensor
	TEST_ASSERT_EQUAL(under.has_sensor, HAS_SENSORS, "couldn't properly install suit sensor on the jumpsuit")
	under.emp_act(EMP_HEAVY)
	TEST_ASSERT_EQUAL(under.has_sensor, BROKEN_SENSORS, "the jumpsuit sensor wasn't broken by EMP")
	dummy.swap_hand(dummy.get_held_index_of_item(coil))
	click_wrapper(dummy, under) //fix sensor, again
	TEST_ASSERT_EQUAL(under.has_sensor, HAS_SENSORS, "couldn't fix the jumpsuit sensor with cable coil")


/obj/item/clothing/under/sensor_test
	random_sensor = FALSE
