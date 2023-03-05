/// Tests that weakrefs behave correctly
/datum/unit_test/weakrefs

/datum/unit_test/weakrefs/Run()
	var/obj/item/pen/thing = new

	var/datum/weakref/weakref = WEAKREF(thing)

	TEST_ASSERT_EQUAL(weakref, WEAKREF(thing), "WEAKREF() should return the same weakref for the same object")

	TEST_ASSERT_EQUAL(weakref.resolve(), thing, "resolve() should return the object")

	qdel(thing)
	TEST_ASSERT_EQUAL(weakref.resolve(), null, "resolve() should return null after the object is deleted")

	var/obj/item/pen/thing2 = new
	weakref = WEAKREF(thing2)
	qdel(weakref)
	TEST_ASSERT(QDELETED(thing2), "qdel()ing a weakref should qdel the object")
