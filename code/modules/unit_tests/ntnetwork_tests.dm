/datum/unit_test/ntnetwork
	var/list/valid_network_names = list("SS13.ATMOS.SCRUBBERS.SM", "DEEPSPACE.HYDRO.PLANT", "SINDIE.STINKS.BUTT")

	var/list/invalid_network_names = list(".SS13.BOB", "SS13.OHMAN.", "SS13.HAS A SPACE" )

	var/list/valid_network_trees = list(list("SS13","ATMOS","SCRUBBERS","SM"),list("DEEPSPACE","HYDRO","PLANT"), list("SINDIE","STINKS","BUTT"))

	var/list/network_roots = list(
				__STATION_NETWORK_ROOT,
				__CENTCOM_NETWORK_ROOT,
				__SYNDICATE_NETWORK_ROOT,
				__LIMBO_NETWORK_ROOT)

	var/list/random_words_for_testing = list(
				__NETWORK_TOOLS, __NETWORK_REMOTES, __NETWORK_AIRLOCKS,
				__NETWORK_DOORS, __NETWORK_ATMOS, __NETWORK_SCUBBERS,
				__NETWORK_AIRALARMS, __NETWORK_CONTROL, __NETWORK_STORAGE,
				__NETWORK_CARGO, __NETWORK_BOTS, __NETWORK_COMPUTER,
				__NETWORK_CARDS)

	var/number_of_names_to_test = 50
	var/length_of_test_network = 5

/datum/unit_test/proc/mangle_word(word)
	var/len = length(word)
	var/space_pos = round(len/2)
	word = copytext(word,1,space_pos) + " " + copytext(word,space_pos,len)
	return word

/datum/unit_test/ntnetwork/Run()
	// First check if name checks work
	for(var/name in valid_network_names)
		TEST_ASSERT(verify_network_name(name), "Network name ([name]) marked as invalid but supposed to valid")

	for(var/name in invalid_network_names)
		TEST_ASSERT(!verify_network_name(name), "Network name ([name]) marked as valid but supposed to be invalid")

	// Next check if we can pack and unpack network names
	for(var/i in 1 to valid_network_names.len)
		var/name = valid_network_names[i]
		var/list/name_list = SSnetworks.network_string_to_list(name)
		TEST_ASSERT(compare_list(name_list,  valid_network_trees[i]), "Network name ([name]) did not unpack into a proper list")
	for(var/i in 1 to valid_network_trees.len)
		var/list/name_list = valid_network_trees[i]
		var/name = SSnetworks.network_list_to_string(name_list)
		TEST_ASSERT_EQUAL(name, valid_network_names[i], "Network name ([name]) did not pack into a proper string")

	// Ok, we know we can verify network names now, and that we can pack and unpack.  Lets try making some random good names
	var/list/generated_network_names = list()
	var/test_string
	for(var/i in 1 to number_of_names_to_test)
		var/list/builder = list()
		builder += pick(network_roots)
		for(var/j in 1 to length_of_test_network)
			builder += pick(random_words_for_testing)
		test_string = SSnetworks.network_list_to_string(builder)
		var/name_fix = simple_network_name_fix(test_string)
		TEST_ASSERT_EQUAL(name_fix, test_string, "Network name ([test_string]) was not fixed correctly to ([name_fix])")
		generated_network_names += name_fix // save for future
	// test badly generated names
	for(var/i in 1 to number_of_names_to_test)
		var/list/builder = list()
		builder += mangle_word(pick(network_roots))
		for(var/j in 1 to length_of_test_network)
			builder += mangle_word(pick(random_words_for_testing))
		test_string = builder.Join(".")
		var/name_fix = simple_network_name_fix(test_string)
		TEST_ASSERT(verify_network_name(name_fix), "Network name ([test_string]) was not fixed correctly ([name_fix]) with bad name")
