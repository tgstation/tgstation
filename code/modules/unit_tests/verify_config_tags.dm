/// Unit Test to ensure that all config tags that we associate to all jobs in SSjob.joinable_occupations are valid.
/datum/unit_test/verify_config_tags

/datum/unit_test/verify_config_tags/Run()
	var/list/collected_tags = list()
	// I CREATED THE NEW SYSTEM TO GET AWAY FROM REGEXING SHIT BUT I AM STUCK IN THIS FILTHY MEAT CAGE FUCK
	// Check for any whitespace in a config tag.
	var/regex/tag_regex_whitespace = new("\s")
	// Check to ensure that no config tag has lowercase characters.
	var/regex/tag_regex_lowercase = new("[A-Z]+(_[A-Z]+)*")

	for(var/datum/job/occupation as anything in SSjob.joinable_occupations)
		TEST_ASSERT_NOTEQUAL(occupation.config_tag, "", "Job [occupation.title] has no config_tag!") // The base job datum has an empty string, so it's likely that we forgot to give it a unique config tag in the first place.
		collected_tags += occupation.config_tag

		var/number_of_jobs = length(SSjob.joinable_occupations)
		var/number_of_keys = length(collected_tags)

		TEST_ASSERT_EQUAL(length(collected_tags), length(SSjob.joinable_occupations), "Mismatch between the number of joinable occupations: [number_of_jobs] against the number of unique config tags: [number_of_keys]!")

		for(var/tag in collected_tags)
			TEST_ASSERT_NOTNULL(tag_regex_whitespace.Find(tag), "The config tag [tag], for the job [occupation.title] has whitespace in it. Please remove the whitespace.")
			TEST_ASSERT_NOTNULL(tag_regex_lowercase.Find(tag), "The config tag [tag], for the job [occupation.title] has lowercase characters in it. Please ensure that the config tag is in SCREAMING_SNAKE_CASE!")
			collected_tags -= tag
			TEST_ASSERT_NULL(collected_tags["[tag]"], "The config tag [tag], for the job [occupation.title] is a duplicate of another config tag. Please ensure that the config tag is unique.")


