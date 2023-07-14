// Dedicated to testing language holders

/// Simply tests that swapping to a new species gives you the languages of that species and removes the languages of the old species
/datum/unit_test/language_species_swap_simple

/datum/unit_test/language_species_swap_simple/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/datum/language_holder/holder = dummy.get_language_holder()

	var/list/initial_spoken = holder.spoken_languages.Copy()
	var/list/initial_understood = holder.understood_languages.Copy()

	TEST_ASSERT(length(initial_spoken) == 1, \
		"Dummy should only speak one language! Instead, it knew the following: [print_language_list(initial_spoken)]")
	TEST_ASSERT(length(initial_understood) == 1, \
		"Dummy should only understand one language! Instead, it knew the following: [print_language_list(initial_understood)]")

	dummy.set_species(/datum/species/lizard)

	TEST_ASSERT(length(holder.spoken_languages) == 2, \
		"Dummy should speak two languages - Common and Draconic! Instead, it knew the following: [print_language_list(holder.spoken_languages)]")

	TEST_ASSERT(length(holder.understood_languages) == 2, \
		"Dummy should understand two languages - Common and Draconic! Instead, it knew the following: [print_language_list(holder.understood_languages)]")

	dummy.set_species(/datum/species/human)

	TEST_ASSERT(length(initial_spoken & holder.spoken_languages) == 1, \
		"Dummy did not speak Common after returning to human! Instead, it knew the following: [print_language_list(holder.spoken_languages)]")

	TEST_ASSERT(length(initial_understood & holder.understood_languages) == 1, \
		"Dummy did not understand Common after returning to human! Instead, it knew the following: [print_language_list(holder.understood_languages)]")

/// Tests species changes which are more complex are functional (e.g. from a species which speaks common to one which does not)
/datum/unit_test/language_species_swap_complex

/datum/unit_test/language_species_swap_complex/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/datum/language_holder/holder = dummy.get_language_holder()

	dummy.set_species(/datum/species/lizard/silverscale)

	TEST_ASSERT(!dummy.has_language(/datum/language/common, SPOKEN_LANGUAGE), \
		"Changing a mob's species from one which speaks common to one which does not should remove the language!")

	TEST_ASSERT(dummy.has_language(/datum/language/common, UNDERSTOOD_LANGUAGE), \
		"Changing a mob's species from one which understands common another which does should not remove the language!")

	TEST_ASSERT(length(holder.spoken_languages) == 2, \
		"Dummy should speak two languages - Uncommon and Draconic! Instead, it knew the following: [print_language_list(holder.spoken_languages)]")

	TEST_ASSERT(length(holder.understood_languages) == 3, \
		"Dummy should understand three languages - Common, Uncommon and Draconic! Instead, it knew the following: [print_language_list(holder.understood_languages)]")

/// Test that other random languages known are not lost on species change
/datum/unit_test/language_species_change_other_known

/datum/unit_test/language_species_change_other_known/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.grant_language(/datum/language/piratespeak, source = LANGUAGE_MIND)
	dummy.grant_language(/datum/language/draconic, source = LANGUAGE_ATOM)
	dummy.set_species(/datum/species/lizard)

	TEST_ASSERT(dummy.has_language(/datum/language/piratespeak, SPOKEN_LANGUAGE), \
		"Dummy should still speak Pirate after changing species, as it's a mind language!")

	TEST_ASSERT(dummy.has_language(/datum/language/piratespeak, UNDERSTOOD_LANGUAGE), \
		"Dummy should still understand Pirate after changing species, as it's a mind language!")

	dummy.set_species(/datum/species/human)

	TEST_ASSERT(dummy.has_language(/datum/language/draconic, SPOKEN_LANGUAGE), \
		"Dummy should still speak Draconic after changing species, as it's an atom language!")

	TEST_ASSERT(dummy.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE), \
		"Dummy should still understand Draconic after changing species, as it's an atom language!")

/// Tests that mind bound languages are not lost swapping into a new mob, but other languages are
/datum/unit_test/language_mind_transfer

/datum/unit_test/language_mind_transfer/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/basic/pet/dog/corgi/transfer_target = allocate(/mob/living/basic/pet/dog/corgi)
	dummy.mind_initialize()
	dummy.grant_language(/datum/language/piratespeak, source = LANGUAGE_MIND)
	dummy.grant_language(/datum/language/draconic, source = LANGUAGE_ATOM)
	dummy.set_species(/datum/species/lizard/silverscale)

	dummy.mind.transfer_to(transfer_target)

	// transfer_target should speak and understand pirate
	TEST_ASSERT(!dummy.has_language(/datum/language/piratespeak, SPOKEN_LANGUAGE), \
		"Dummy should no longer be speaking Pirate after losing their mind!")
	TEST_ASSERT(transfer_target.has_language(/datum/language/piratespeak, SPOKEN_LANGUAGE), \
		"Dummy's new mob should be capable of speaking Pirate!")

	TEST_ASSERT(!dummy.has_language(/datum/language/piratespeak, UNDERSTOOD_LANGUAGE), \
		"Dummy should no longer be understanding Pirate after losing their mind!")
	TEST_ASSERT(transfer_target.has_language(/datum/language/piratespeak, UNDERSTOOD_LANGUAGE), \
		"Dummy's new mob should be capable of understanding Pirate!")

	// transfer_target should NOT speak and understand draconic
	TEST_ASSERT(dummy.has_language(/datum/language/draconic, SPOKEN_LANGUAGE), \
		"Dummy should still understand Draconic after losing their mind - it's an atom language!")
	TEST_ASSERT(!transfer_target.has_language(/datum/language/draconic, SPOKEN_LANGUAGE), \
		"Dummy's new mob should not understand Draconic - it's an atom language!")

	TEST_ASSERT(dummy.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE), \
		"Dummy should still understand Draconic after losing their mind - it's an atom language!")
	TEST_ASSERT(!transfer_target.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE), \
		"Dummy's new mob should not understand Draconic - it's an atom language!")

	// transfer_target should NOT speak and understand uncommon
	TEST_ASSERT(dummy.has_language(/datum/language/uncommon, SPOKEN_LANGUAGE), \
		"Dummy should still understand Uncommon after losing their mind - it's a species language!")
	TEST_ASSERT(!transfer_target.has_language(/datum/language/uncommon, SPOKEN_LANGUAGE), \
		"Dummy's new mob should not understand Uncommon - it's a species language!")

	TEST_ASSERT(dummy.has_language(/datum/language/uncommon, UNDERSTOOD_LANGUAGE), \
		"Dummy should still understand Uncommon after losing their mind - it's a species language!")
	TEST_ASSERT(!transfer_target.has_language(/datum/language/uncommon, UNDERSTOOD_LANGUAGE), \
		"Dummy's new mob should not understand Uncommon - it's a species language!")

/// Tests that mind bound languages are not lost when swapping with another person (wiz mindswap)
/datum/unit_test/language_mind_swap

/datum/unit_test/language_mind_swap/Run()
	var/mob/living/carbon/human/dummy_A = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/dummy_B = allocate(/mob/living/carbon/human/consistent)

	dummy_A.mind_initialize()
	dummy_B.mind_initialize()

	var/datum/mind/dummy_A_mind = dummy_A.mind
	var/datum/mind/dummy_B_mind = dummy_B.mind

	dummy_A.set_species(/datum/species/lizard)
	dummy_B.grant_language(/datum/language/piratespeak, source = LANGUAGE_MIND)

	dummy_A_mind.transfer_to(dummy_B)
	dummy_B_mind.transfer_to(dummy_A)

	var/datum/language_holder/holder_A = dummy_A.get_language_holder()
	var/datum/language_holder/holder_B = dummy_B.get_language_holder()

	// Holder A is a lizard: starts with 2 languages (common, draconic)
	// Holder B is a human with a mind language: starts with 2 language (common, pirate)
	// Swap occurs
	// Holder A is a lizard with 2 languages, but should now also have pirate: 3 languages (common, draconic, pirate)
	// Holder B is a human with just 1 language left over (common)

	TEST_ASSERT_EQUAL(length(holder_A.spoken_languages), 3, \
		"Holder A / Dummy A / Dummy B mind should speak Common, Draconic, and Pirate! \
		Instead, it knew the following: [print_language_list(holder_A.spoken_languages)]")

	TEST_ASSERT_EQUAL(length(holder_A.understood_languages), 3, \
		"Holder A / Dummy A / Dummy B mind should only understand Common, Draconic, and Pirate! \
		Instead, it knew the following: [print_language_list(holder_A.understood_languages)]")

	TEST_ASSERT_EQUAL(length(holder_B.spoken_languages), 1, \
		"Holder B / Dummy B / Dummy A mind should only speak 1 language - Common! \
		Instead, it knew the following: [print_language_list(holder_B.spoken_languages)]")

	TEST_ASSERT_EQUAL(length(holder_B.understood_languages), 1, \
		"Holder B / Dummy B / Dummy A mind only understand 1 language - Common! \
		Instead, it knew the following: [print_language_list(holder_B.understood_languages)]")

/// Tests that the book of babel, and by extension grant_all_languages, works as intended
/datum/unit_test/book_of_babel

/datum/unit_test/book_of_babel/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/book_of_babel/book = allocate(/obj/item/book_of_babel)
	var/datum/language_holder/holder = dummy.get_language_holder()
	var/expected_amount = length(GLOB.all_languages)

	book.attack_self(dummy)
	TEST_ASSERT_EQUAL(length(holder.spoken_languages), expected_amount, "Book of Babel failed to give all languages out!")
	dummy.set_species(/datum/species/lizard)
	TEST_ASSERT_EQUAL(length(holder.spoken_languages), expected_amount, "Changing species after using the Book of Bable should not remove languages!")

/// Helper proc to print a list of languages in a human readable format
/proc/print_language_list(list/languages_to_print)
	var/list/printed_languages = list()

	for(var/datum/language/language as anything in languages_to_print)
		printed_languages += initial(language.name)

	return english_list(printed_languages)
