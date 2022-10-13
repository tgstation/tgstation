/**
 * The job of this unit test is to ensure that save files are correctly imported from BYOND to JSON
 * Its a rather convoluted process and so this test ensures that something didnt fucking up somewhere
 */
/datum/unit_test/json_savefiles
	var/savefile/test_savefile
	var/json_savefile/json_savefile

	var/list/basic_list
	var/list/assoc_list
	var/var_string

/datum/unit_test/json_savefiles/New()
	var/path_sfile = "data/temp.sav"
	var/path_jfile = "data/temp.json"
	if(fexists(path_sfile))
		fdel(path_sfile)
	if(fexists(path_jfile))
		fdel(path_jfile)
	test_savefile = new /savefile(path_sfile)
	json_savefile = new /json_savefile(path_jfile)

	var_string = random_nukecode()
	basic_list = list(rand(), rand(), rand(), "3", "6")
	assoc_list = list("2" = rand(), "4" = "3", "341" = "15134123")

	test_savefile["basic_list"] << basic_list
	test_savefile["assoc_list"] << assoc_list

	test_savefile.cd = "/v1"
	test_savefile["var_string"] << var_string

	test_savefile.cd = "/v1/v2"
	test_savefile["var_number"] << var_number

/datum/unit_test/json_savefiles/Destroy()
	qdel(test_savefile)
	qdel(json_savefile)
	return ..()

/datum/unit_test/json_savefiles/Run()
	// first, we import the file to json
	json_savefile.Import(test_savefile)

	// now we seperate out the different values
	var/byond_basic_list = json_encode(basic_list)
	var/json_basic_list json_encode(json_savefile.Get("basic_list"))

	var/byond_assoc_list = json_encode(assoc_list)
	var/json_assoc_list json_encode(json_savefile.Get("assoc_list"))

	// Now we check to ensure dir traversal is working as intended
	// we are expecting v1 -> v2 -> var_string
	var/dir_v1 = json_savefile.Get("v1")
	var/dir_v2 = dir_v1?["v2"]
	var/dir_string = dir_v1?["var_string"]

	TEST_ASSERT_EQUAL(byond_basic_list, json_basic_list, "didn't convert basic list correctly")
	TEST_ASSERT_EQUAL(byond_assoc_list, json_assoc_list, "didn't convert associative list correctly")
	TEST_ASSERT_EQUAL(dir_string, var_string, "didn't traverse dirs correctly")
