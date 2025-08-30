/**
 * Unit Tests for Request Emergency Temporary Access (RETA) System
 *
 * Main system file: code\modules\reta\reta_system.dm
 */

/datum/unit_test/reta_basic_functions

/datum/unit_test/reta_basic_functions/Run()
	// Initialize RETA system for testing
	initialize_reta_system()

	// Test department mapping
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Engineering"), "Engineering", "Engineering department mapping failed")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("engineering"), "Engineering", "Engineering lowercase mapping failed")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Medical Department"), "Medical", "Medical department mapping failed")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("medbay"), "Medical", "Medbay alias mapping failed")
	TEST_ASSERT_NULL(reta_get_user_department_by_name("Unknown"), "Unknown department should return null")

	// Test cooldown system
	TEST_ASSERT(!reta_on_cooldown("Engineering", "Medical"), "Fresh cooldown should be false")
	reta_set_cooldown("Engineering", "Medical", 100)
	TEST_ASSERT(reta_on_cooldown("Engineering", "Medical"), "Set cooldown should be true")

	// Test department grants - check that departments get appropriate access levels
	TEST_ASSERT(GLOB.reta_dept_grants["Engineering"], "Engineering grants should exist")
	TEST_ASSERT(ACCESS_ENGINEERING in GLOB.reta_dept_grants["Engineering"], "Engineering should grant ACCESS_ENGINEERING")
	TEST_ASSERT(ACCESS_ATMOSPHERICS in GLOB.reta_dept_grants["Engineering"], "Engineering should grant ACCESS_ATMOSPHERICS")
	TEST_ASSERT(!(ACCESS_CONSTRUCTION in GLOB.reta_dept_grants["Engineering"]), "Engineering should NOT grant ACCESS_CONSTRUCTION")
	TEST_ASSERT(GLOB.reta_dept_grants["Medical"], "Medical grants should exist")
	TEST_ASSERT(ACCESS_MEDICAL in GLOB.reta_dept_grants["Medical"], "Medical should grant ACCESS_MEDICAL")
	TEST_ASSERT(ACCESS_SURGERY in GLOB.reta_dept_grants["Medical"], "Medical should grant ACCESS_SURGERY")
	TEST_ASSERT(GLOB.reta_dept_grants["Security"], "Security grants should exist")
	TEST_ASSERT(ACCESS_SECURITY in GLOB.reta_dept_grants["Security"], "Security should grant ACCESS_SECURITY")
	TEST_ASSERT(ACCESS_BRIG in GLOB.reta_dept_grants["Security"], "Security should grant ACCESS_BRIG")
	TEST_ASSERT(ACCESS_BRIG_ENTRANCE in GLOB.reta_dept_grants["Security"], "Security should grant ACCESS_BRIG_ENTRANCE")
	TEST_ASSERT(!(ACCESS_ARMORY in GLOB.reta_dept_grants["Security"]), "Security should NOT grant ACCESS_ARMORY")

	// Test new departments
	TEST_ASSERT(GLOB.reta_dept_grants["Command"], "Command grants should exist")
	TEST_ASSERT(ACCESS_COMMAND in GLOB.reta_dept_grants["Command"], "Command should grant ACCESS_COMMAND")
	TEST_ASSERT(!(ACCESS_CAPTAIN in GLOB.reta_dept_grants["Command"]), "Command should NOT grant ACCESS_CAPTAIN")

	TEST_ASSERT(GLOB.reta_dept_grants["Cargo"], "Cargo grants should exist")
	TEST_ASSERT(ACCESS_CARGO in GLOB.reta_dept_grants["Cargo"], "Cargo should grant ACCESS_CARGO")
	TEST_ASSERT(!(ACCESS_MINING in GLOB.reta_dept_grants["Cargo"]), "Cargo should NOT grant ACCESS_MINING")

	TEST_ASSERT(GLOB.reta_dept_grants["Mining"], "Mining grants should exist")
	TEST_ASSERT(ACCESS_MINING in GLOB.reta_dept_grants["Mining"], "Mining should grant ACCESS_MINING")
	TEST_ASSERT(ACCESS_MINING_STATION in GLOB.reta_dept_grants["Mining"], "Mining should grant ACCESS_MINING_STATION")
	TEST_ASSERT(ACCESS_CARGO in GLOB.reta_dept_grants["Mining"], "Mining should grant ACCESS_CARGO")

	// Test department name mapping including new Mining support
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Mining Station"), "Mining", "Mining Station should map to Mining")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Command"), "Command", "Command should map to Command")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Bridge"), "Command", "Bridge should map to Command")

	// Test autonamed service areas
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Kitchen"), "Service", "Kitchen should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Bar"), "Service", "Bar should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Cafeteria"), "Service", "Cafeteria should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Diner"), "Service", "Diner should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Hydroponics"), "Service", "Hydroponics should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Botany"), "Service", "Botany should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Janitor"), "Service", "Janitor should map to Service")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Custodial"), "Service", "Custodial should map to Service")

	// Test autonamed medical areas
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Pharmacy"), "Medical", "Pharmacy should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Chemistry"), "Medical", "Chemistry should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Chem"), "Medical", "Chem should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Morgue"), "Medical", "Morgue should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Virology"), "Medical", "Virology should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Surgery"), "Medical", "Surgery should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Operating"), "Medical", "Operating should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Cryo"), "Medical", "Cryo should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Patients"), "Medical", "Patients should map to Medical")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Exam"), "Medical", "Exam should map to Medical")

	// Test autonamed engineering areas
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Atmospherics"), "Engineering", "Atmospherics should map to Engineering")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Atmos"), "Engineering", "Atmos should map to Engineering")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Supermatter"), "Engineering", "Supermatter should map to Engineering")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Gravity"), "Engineering", "Gravity should map to Engineering")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Telecomm"), "Engineering", "Telecomm should map to Engineering")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Tcomm"), "Engineering", "Tcomm should map to Engineering")

	// Test autonamed science areas
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Xenobiology"), "Science", "Xenobiology should map to Science")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Xenobio"), "Science", "Xenobio should map to Science")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Robotics"), "Science", "Robotics should map to Science")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Genetics"), "Science", "Genetics should map to Science")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Ordnance"), "Science", "Ordnance should map to Science")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Cytology"), "Science", "Cytology should map to Science")

	// Test autonamed security areas
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Brig"), "Security", "Brig should map to Security")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Holding"), "Security", "Holding should map to Security")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Armory"), "Security", "Armory should map to Security")
	TEST_ASSERT_EQUAL(reta_get_user_department_by_name("Checkpoint"), "Security", "Checkpoint should map to Security")

/datum/unit_test/reta_id_card_access

/datum/unit_test/reta_id_card_access/Run()
	// Initialize RETA system for testing
	initialize_reta_system()

	var/obj/item/card/id/test_card = allocate(/obj/item/card/id)
	test_card.registered_name = "Test User"

	// Test temporary access granting
	TEST_ASSERT(!test_card.has_reta_access(ACCESS_ENGINEERING), "ID card should not have temp access initially")
	TEST_ASSERT(!(ACCESS_ENGINEERING in test_card.access), "ID card should not have engineering access initially")

	test_card.grant_reta_access("Engineering", 100)
	TEST_ASSERT(test_card.has_reta_access(ACCESS_ENGINEERING), "ID card should have temp access after granting")
	TEST_ASSERT(ACCESS_ENGINEERING in test_card.access, "ID card should have engineering access in main access list")

	// Test access clearing
	test_card.clear_reta_access()
	TEST_ASSERT(!test_card.has_reta_access(ACCESS_ENGINEERING), "ID card should not have temp access after clearing")
	TEST_ASSERT(!(ACCESS_ENGINEERING in test_card.access), "ID card should not have engineering access in main access list after clearing")

	// Test that permanent access is not affected
	test_card.access += ACCESS_ENGINEERING // Simulate HoP giving permanent access
	test_card.grant_reta_access("Engineering", 100)
	TEST_ASSERT(!test_card.has_reta_access(ACCESS_ENGINEERING), "ID card should not add temp access if already has permanent")
	TEST_ASSERT(ACCESS_ENGINEERING in test_card.access, "ID card should retain permanent access")

	test_card.clear_reta_access()
	TEST_ASSERT(ACCESS_ENGINEERING in test_card.access, "ID card should still have permanent access after clearing temp access")

/datum/unit_test/reta_paramedic_access

/datum/unit_test/reta_paramedic_access/Run()
	// Initialize RETA system for testing
	initialize_reta_system()

	var/datum/id_trim/job/paramedic/paramedic_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/paramedic]

	// Test that paramedic no longer has broad access
	TEST_ASSERT(!(ACCESS_CARGO in paramedic_trim.minimal_access), "Paramedic should not have cargo access")
	TEST_ASSERT(!(ACCESS_SCIENCE in paramedic_trim.minimal_access), "Paramedic should not have science access")
	TEST_ASSERT(!(ACCESS_CONSTRUCTION in paramedic_trim.minimal_access), "Paramedic should not have construction access")
	TEST_ASSERT(!(ACCESS_HYDROPONICS in paramedic_trim.minimal_access), "Paramedic should not have hydroponics access")
	TEST_ASSERT(!(ACCESS_MINING in paramedic_trim.minimal_access), "Paramedic should not have mining access")

	// Test that paramedic still has basic medical access
	TEST_ASSERT(ACCESS_MEDICAL in paramedic_trim.minimal_access, "Paramedic should have medical access")
	TEST_ASSERT(ACCESS_MAINT_TUNNELS in paramedic_trim.minimal_access, "Paramedic should have maintenance access")
	TEST_ASSERT(ACCESS_MORGUE in paramedic_trim.minimal_access, "Paramedic should have morgue access")
	TEST_ASSERT(ACCESS_MECH_MEDICAL in paramedic_trim.minimal_access, "Paramedic should have medical mech access")
