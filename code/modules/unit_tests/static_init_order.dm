/// This test checks that we have the right spot for the call to world.Genesis()
/datum/unit_test/static_init_order

/datum/unit_test/static_init_order/Run()
	var/list/init_order = StaticInitRecordKeeping(return_list = TRUE)

	log_test("Invocation order:")

	var/list/first_invocation
	for(var/entry in init_order)
		if(!first_invocation)
			first_invocation = entry

		log_test("\t[entry["file"]]#L[entry["line"]]: [replacetext(entry["invocation"], "\n", "\\n")]")

	if(!first_invocation)
		TEST_FAIL("No static variables initialized or, more likely, someone broke the test");

	if(first_invocation["invocation"] != "world.Genesis()")
		TEST_FAIL("First invocation was not The Genesis Call")

/proc/StaticInitRecordKeeping(value, invocation, file, line, return_list = FALSE)
	var/static/list/init_order
	LAZYINITLIST(init_order)
	if(return_list)
		return init_order

	init_order += list(list(
		"invocation" = invocation,
		"file" = file,
		"line" = line))
