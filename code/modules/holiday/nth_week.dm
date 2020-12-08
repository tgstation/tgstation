///A holiday lasting one day only that falls on the nth weekday in a month i.e. 3rd Wednesday of February.
/datum/holiday/nth_week
	///Nth weekday of type begin_weekday in begin_month to start on (1 to 5).
	var/begin_week = 1
	///Weekday of begin_week to start on.
	var/begin_weekday = MONDAY

/datum/holiday/nth_week/shouldCelebrate(dd, mm, yy, ww, ddd)
	// Does not support end_day or end_month. Find me a holiday that needs that and I'll add it.
	// Same with adding an end_weekday or end_week.
	if (mm != begin_month)
		return FALSE
	if (begin_weekday != ddd)
		return FALSE
	var/day_number = 0
	// format of first_day_of_month proc (Monday 1 Sunday 7)
	switch (begin_weekday)
		if (MONDAY)
			day_number = 1
		if (TUESDAY)
			day_number = 2
		if (WEDNESDAY)
			day_number = 3
		if (THURSDAY)
			day_number = 4
		if (FRIDAY)
			day_number = 5
		if (SATURDAY)
			day_number = 6
		if (SUNDAY)
			day_number = 7
	var/fd = first_day_of_month(yy, mm)
	var/weekday_diff = day_number - fd
	if (weekday_diff < 0)
		weekday_diff += 7
	var/correct_day = (begin_week - 1) * 7 + weekday_diff + 1
	if (dd == correct_day)
		return TRUE
	return FALSE

/datum/holiday/nth_week/thanksgiving
	name = "Thanksgiving in the United States"
	begin_week = 4
	begin_month = NOVEMBER
	begin_weekday = THURSDAY
	drone_hat = /obj/item/clothing/head/that //This is the closest we can get to a pilgrim's hat

/datum/holiday/nth_week/thanksgiving/canada
	name = "Thanksgiving in Canada"
	begin_week = 2
	begin_month = OCTOBER
	begin_weekday = MONDAY

/datum/holiday/nth_week/indigenous
	// not Columbus day anymore get rekt, Columbus
	name = "Indigenous Peoples' Day"
	begin_week = 2
	begin_month = OCTOBER
	begin_weekday = MONDAY

/datum/holiday/nth_week/mother
	name = "Mother's Day"
	begin_week = 2
	begin_month = MAY
	begin_weekday = SUNDAY

/datum/holiday/nth_week/mother/greet()
	return "Happy Mother's Day in most of the Americas, Asia, and Oceania!"

/datum/holiday/nth_week/father
	name = "Father's Day"
	begin_week = 3
	begin_month = JUNE
	begin_weekday = SUNDAY

/datum/holiday/nth_week/todaytest
	name = "First Saturday of December"
	begin_week = 1
	begin_month = DECEMBER
	begin_weekday = SATURDAY
