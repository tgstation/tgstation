/// Test you can buckle yourself to a chair
/datum/unit_test/buckling_self

/datum/unit_test/buckling_self/Run()
	var/mob/living/carbon/human/consistent/dummy = EASY_ALLOCATE()
	dummy.mock_client = new()
	var/obj/structure/chair/chair = EASY_ALLOCATE()

	var/old_usr = usr

	usr = dummy // mouse drop still uses usr

	dummy.MouseDrop(chair)
	if(dummy.buckled != chair)
		TEST_FAIL("The dummy failed to buckle themselves to a chair via mouse drop.")

	usr = old_usr

/// Test you can buckle someone else to a chair
/datum/unit_test/buckling_others

/datum/unit_test/buckling_others/Run()
	var/mob/living/carbon/human/consistent/dummy = EASY_ALLOCATE()
	dummy.mock_client = new()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/structure/chair/chair = EASY_ALLOCATE()

	var/old_usr = usr

	usr = dummy // mouse drop still uses usr

	victim.MouseDrop(chair)
	if(victim.buckled != chair)
		TEST_FAIL("The dummy failed to buckle the victim to a chair via mouse drop.")

	usr = old_usr
