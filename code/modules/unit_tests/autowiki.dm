/// Tests that all autowikis generate something without runtiming
/datum/unit_test/autowiki

/datum/unit_test/autowiki/Run()
	TEST_ASSERT(istext(generate_autowiki_output()), "generate_autowiki_output() did not finish successfully!")

/// Test that `include_template` produces reasonable results
/datum/unit_test/autowiki_include_template

/datum/unit_test/autowiki_include_template/Run()
	var/datum/autowiki/autowiki_api = new

	TEST_ASSERT_EQUAL( \
		autowiki_api.include_template("Template"), \
		"{{Template}}", \
		"Basic template did not format correctly" \
	)

	TEST_ASSERT_EQUAL( \
		autowiki_api.include_template("Template", list("name" = "Mothblocks")), \
		"{{Template|name=Mothblocks}}", \
		"Template with basic arguments did not format correctly" \
	)

	TEST_ASSERT_EQUAL( \
		autowiki_api.include_template("Template", list("name" = autowiki_api.escape_value("P|peline"))), \
		"{{Template|name=P{{!}}peline}}", \
		"Template with escaped arguments did not format correctly" \
	)

	TEST_ASSERT_EQUAL( \
		autowiki_api.include_template("Template", list("food" = list("fruit", "candy"))), \
		"{{Template|food1=fruit|food2=candy", \
		"Template with array arguments did not format correctly" \
	)
