/// Unit Test to ensure that all config tags that we associate to all jobs in SSjob.joinable_occupations are valid.
/datum/unit_test/verify_config_tags

/datum/unit_test/verify_config_tags/Run()
	var/job_tag
	var/list/collected_tags = list()
	var/number_of_jobs = length(SSjob.joinable_occupations)
	var/number_of_keys

	// I CREATED THE NEW SYSTEM TO GET AWAY FROM REGEXING SHIT BUT I AM STUCK IN THIS FILTHY MEAT CAGE FUCK
	// Check for any whitespace in a config tag.
	var/regex/tag_regex_whitespace = new("\\s")
	// Check to ensure that no config tag has lowercase characters (enforce SCREAMING_SNAKE_CASE).
	var/regex/tag_regex_lowercase = new("\[a-z\]+")

	for(var/datum/job/occupation as anything in SSjob.joinable_occupations)
		job_tag = occupation.config_tag

		TEST_ASSERT_NOTEQUAL(job_tag, "", "Job [occupation.title] has no config_tag!") // The base job datum has an empty string, so it's likely that we forgot to give it a unique config tag in the first place.
		if(tag_regex_whitespace.Find(job_tag)) // regex Find() passes 0 and not null, so we can't do TEST_ASSERT_NOTNULL
			TEST_FAIL("Job [occupation.title] has a config_tag [job_tag] with whitespace in it! Please remove the whitespace (use SCREAMING_SNAKE_CASE rules).")
		if(tag_regex_lowercase.Find(job_tag)) // We do not have exactly one regex capturing group, this key is definitely bad.
			TEST_FAIL("The config tag [job_tag], for the job [occupation.title] contains lowercase characters. Please change it to SCREAMING_SNAKE_CASE.")

		collected_tags += job_tag

	number_of_keys = length(collected_tags)
	TEST_ASSERT_EQUAL(number_of_keys, number_of_jobs, "Mismatch between the number of joinable occupations: [number_of_jobs] against the number of unique config tags: [number_of_keys]!")

	for(var/iterated_tag in collected_tags)
		collected_tags -= iterated_tag // Remove this tag from the list. If the tag still exists, it means that there are two jobs with the same config tag (duplicate).
		if(collected_tags.Find(iterated_tag))
			TEST_FAIL("The config tag [iterated_tag] is used by two or more jobs! Please ensure that all config tags are unique.")
