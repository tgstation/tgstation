// test Jewish holiday
/datum/unit_test/hanukkah_2123/Run()
	var/datum/holiday/hebrew/hanukkah/hanukkah = new
	TEST_ASSERT(hanukkah.shouldCelebrate(13, DECEMBER, 2123, 2, MONDAY), "December 13, 2123 was not Hannukkah.")

// test Islamic holiday
/datum/unit_test/ramadan_4208/Run()
	var/datum/holiday/islamic/ramadan/ramadan = new
	TEST_ASSERT(ramadan.shouldCelebrate(1, MARCH, 4208, 1, TUESDAY), "March 1, 4208 was not the start of Ramadan.")

// nth day of week
/datum/unit_test/thanksgiving_2020/Run()
	var/datum/holiday/nth_week/thanksgiving = new
	TEST_ASSERT(thanksgiving.shouldCelebrate(26, NOVEMBER, 2020, 4, THURSDAY), "November 26, 2020 was not Thanksgiving.")

// another nth day of week
/datum/unit_test/indigenous_3683/Run()
	var/datum/holiday/nth_week/indigenous = new
	TEST_ASSERT(indigenous.shouldCelebrate(9, OCTOBER, 3683, 2, MONDAY), "October 9, 3683 was not Indigenous Peoples' Day.")

// plain old simple holiday
/datum/unit_test/hello_2020/Run()
	var/datum/holiday/hello/hello = new
	TEST_ASSERT(hello.shouldCelebrate(21, NOVEMBER, 2020, 3, SATURDAY), "November 21, 2020 was not Hello day.")

// holiday which goes across months
/datum/unit_test/new_year_1983/Run()
	var/datum/holiday/new_year/new_year = new
	TEST_ASSERT(new_year.shouldCelebrate(2, JANUARY, 1983, 1, SUNDAY), "January 2, 1983 was not New Year.")
