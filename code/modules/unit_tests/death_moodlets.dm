/// Tests death moodlets given various traits and personalities
/datum/unit_test/death_moodlets
	abstract_type = /datum/unit_test/death_moodlets
	/// What moodlet type we expect the test to give
	var/desired_moodlet = /datum/mood_event/conditional/see_death

/datum/unit_test/death_moodlets/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__)
	prepare_dummy(dummy)

	var/mob/living/dying = get_dying_mob()
	prepare_dying_mob(dying)
	dying.death()

	var/datum/mood_event/moodlet = dummy.mob_mood.mood_events["saw_death"]
	TEST_ASSERT_EQUAL(moodlet?.type, desired_moodlet, "Dummy did not receive the correct moodlet upon witnessing a death.")

/// Override to prepare the dummy as needed
/datum/unit_test/death_moodlets/proc/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	return

/// Override to provide the mob that will die
/datum/unit_test/death_moodlets/proc/get_dying_mob()
	return allocate(/mob/living/carbon/human/consistent)

/// Override to prepare the dying mob as needed
/datum/unit_test/death_moodlets/proc/prepare_dying_mob(mob/living/dying)
	return

/// Base type for human death moodlets
/datum/unit_test/death_moodlets/human
	abstract_type = /datum/unit_test/death_moodlets/human

/// Base type for pet death moodlets
/datum/unit_test/death_moodlets/pet
	abstract_type = /datum/unit_test/death_moodlets/pet

/datum/unit_test/death_moodlets/pet/get_dying_mob()
	return allocate(/mob/living/basic/pet/cat/_proc)

/// Test the normal ol default moodlet
/datum/unit_test/death_moodlets/human/normal
	desired_moodlet = /datum/mood_event/conditional/see_death

/// Test desensitized moodlet
/datum/unit_test/death_moodlets/human/desensitized
	desired_moodlet = /datum/mood_event/conditional/see_death/desensitized

/datum/unit_test/death_moodlets/human/desensitized/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	ADD_TRAIT(dummy, TRAIT_DESENSITIZED, TRAIT_SOURCE_UNIT_TESTS)

/// Test callous moodlet
/datum/unit_test/death_moodlets/human/callous
	desired_moodlet = /datum/mood_event/conditional/see_death/dontcare

/datum/unit_test/death_moodlets/human/callous/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	dummy.add_personality(/datum/personality/callous)

/// Tests that callous is prioritized over desensitized
/datum/unit_test/death_moodlets/human/desensitized_and_callous
	desired_moodlet = /datum/mood_event/conditional/see_death/dontcare

/datum/unit_test/death_moodlets/human/desensitized_and_callous/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	ADD_TRAIT(dummy, TRAIT_DESENSITIZED, TRAIT_SOURCE_UNIT_TESTS)
	dummy.add_personality(/datum/personality/callous)

/// Test cultist positive moodlet
/datum/unit_test/death_moodlets/human/cultist
	desired_moodlet = /datum/mood_event/conditional/see_death/cult

/datum/unit_test/death_moodlets/human/cultist/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	ADD_TRAIT(dummy, TRAIT_CULT_HALO, TRAIT_SOURCE_UNIT_TESTS)

/// Tests cultists are still sad when other cultists die
/datum/unit_test/death_moodlets/human/cultist/friendly_fire
	desired_moodlet = /datum/mood_event/conditional/see_death

/datum/unit_test/death_moodlets/human/cultist/friendly_fire/prepare_dying_mob(mob/living/dying)
	ADD_TRAIT(dying, TRAIT_CULT_HALO, TRAIT_SOURCE_UNIT_TESTS)

/// Tests animal moodlet
/datum/unit_test/death_moodlets/pet/animal_moodlet
	desired_moodlet = /datum/mood_event/conditional/see_death/pet

/// Tests desensitized moodlet when a pet dies
/datum/unit_test/death_moodlets/pet/desensitized_to_pet
	desired_moodlet = /datum/mood_event/conditional/see_death/pet

/datum/unit_test/death_moodlets/pet/desensitized_to_pet/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	ADD_TRAIT(dummy, TRAIT_DESENSITIZED, TRAIT_SOURCE_UNIT_TESTS)

/// Tests callous moodlet when a pet dies
/datum/unit_test/death_moodlets/pet/callous_to_pet
	desired_moodlet = /datum/mood_event/conditional/see_death/dontcare

/datum/unit_test/death_moodlets/pet/callous_to_pet/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	dummy.add_personality(/datum/personality/callous)

/// Tests animal disliker moodlet when a pet dies
/datum/unit_test/death_moodlets/pet/animal_disliker_to_pet
	desired_moodlet = /datum/mood_event/conditional/see_death/dontcare

/datum/unit_test/death_moodlets/pet/animal_disliker_to_pet/prepare_dummy(mob/living/carbon/human/consistent/dummy)
	dummy.add_personality(/datum/personality/animal_disliker)
