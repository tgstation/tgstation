/// Tests strip_outer_punctuation()
/datum/unit_test/strip_outer_punctuation

/datum/unit_test/strip_outer_punctuation/Run()
	var/list/sample_to_expected = list(
		"Hello, world!" = "Hello, world",
		"|Who are you?|" = "Who are you",
		"Oh wow..." = "Oh wow",
		"My name is E.T, the alien!" = "My name is E.T, the alien",
		"I'm +YELLING+ at you!" = "I'm +YELLING+ at you",
		"+I'm REALLY yelling!+" = "I'm REALLY yelling",
	)

	for(var/sample in sample_to_expected)
		TEST_ASSERT_EQUAL(strip_outer_punctuation(sample), sample_to_expected[sample], "Strip punctuation failed for sample text: [sample]")

/// Tests find_last_punctuation()
/datum/unit_test/find_last_punctuation

/datum/unit_test/find_last_punctuation/Run()
	var/list/sample_to_expected = list(
		"Hello, world!" = "!",
		"|Who are you?|" = "?",
		"Really, |WHO are you|?" = "?",
		"Oh wow..." = "...",
		"My name is E.T, the alien!" = "!",
	)

	for(var/sample in sample_to_expected)
		TEST_ASSERT_EQUAL(find_last_punctuation(sample), sample_to_expected[sample], "Find punctuation failed for sample text: [sample]")
