/datum/unit_test/json_savefiles
	var/savefile/test_savefile
	var/json_savefile/json_savefile

	var/list/basic_list
	var/list/assoc_list
	var/var_string
	var/var_number

/datum/unit_test/json_savefiles/New()
	var/path_sfile = "data/temp.sav"
	var/path_jfile = "data/temp.json"
	if(fexists(path_sfile))
		fdel(path_sfile)
	if(fexists(path_jfile))
		fdel(path_jfile)
	test_savefile = new /savefile(path_sfile)
	json_savefile = new /json_savefile(path_jfile)

	var_number = rand()
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
	json_savefile.Import(test_savefile)
	if(json_encode(basic_list) != json_encode(json_savefile.Get("basic_list")))
		TEST_FAIL("basic_list was not converted correctly")
	if(json_encode(assoc_list) != json_encode(json_savefile.Get("assoc_list")))
		TEST_FAIL("assoc list was not converted correctly")
	if(var_string != json_savefile.Get("v1")?["var_string"])
		TEST_FAIL("var_string was not imported correctly")
	if(var_number != json_savefile.Get("v1")?["v2"]/["var_number"])
		TEST_FAIL("var_number was not imported correctly")
