#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/atom
	var/creation_test_master
	var/creation_test_has_child

/**
 * The create and destroy unit test is split up across multiple integration test runs so that status checks complete faster.
 * Because of this, some typepaths which are dependent on eachother are separated across runs and cause failures.
 * Relatively simple fix here: group them together.
 *
 * To use this macro, set all typepaths which are dependent on a different typepath as the child, and then the typepath it is dependent on as the master.
 * For example:
 *
 * CREATION_TEST_REQUIRED_NEIGHBOR(/obj/effect/ctf/dead_barricade, /obj/machinery/ctf)
 */
#define CREATION_TEST_REQUIRED_NEIGHBOR(child_typepath, master_typepath) \
##master_typepath/creation_test_has_child = TRUE; \
##child_typepath/creation_test_master = ##master_typepath;

#else

#define CREATION_TEST_REQUIRED_NEIGHBOR(child_typepath, master_typepath)

#endif
