/**
 * Tests that actions assigned to a mob's mind
 * are successfuly transferred when their mind is transferred to a new mob.
 */
/datum/unit_test/actions_moved_on_mind_transfer

/datum/unit_test/actiosn_moved_on_mind_transfer/Run()

	var/mob/living/carbon/human/wizard = allocate(/mob/living/carbon/human)
	var/mob/living/simple_animal/pet/dog/corgi/wizard_dog = allocate(/mob/living/simple_animal/pet/dog/corgi)
	wizard.mind_initialize()

	var/datum/action/cooldown/spell/pointed/projectile/fireball/fireball = new(wizard.mind)
	fireball.Grant(wizard)
	var/datum/action/cooldown/spell/aoe/magic_missile/missile = new(wizard.mind)
	missile.Grant(wizard)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jaunt = new(wizard.mind)
	jaunt.Grant(wizard)

	var/datum/mind/wizard_mind = wizard.mind
	wizard_mind.transfer_to(wizard_dog)

	TEST_ASSERT_EQUAL(wizard_dog.mind, wizard_mind, "Mind transfer failed to occur, which invalidates the test.")

	for(var/datum/action/cooldown/spell/remaining_spell in wizard.actions)
		Fail("Spell: [remaining_spell] failed to transfer minds when a mind transfer occured.")

	qdel(fireball)
	qdel(missile)
	qdel(jaunt)

/**
 * Validates that all spells have a correct
 * invocation type and invocation setup.
 */
/datum/unit_test/spell_invocations

/datum/unit_test/spell_invocations/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell)

	for(var/datum/action/cooldown/spell/spell_type as anything in types_to_test)
		var/spell_name = initial(spell_type.name)
		var/invoke_type = initial(spell_type.invocation_type)
		switch(invoke_type)
			if(INVOCATION_EMOTE)
				if(isnull(initial(spell_type.invocation_self_message)))
					Fail("Spell: [spell_name] ([spell_type]) set emote invocation type but did not set a self message.")
				if(isnull(initial(spell_type.invocation)))
					Fail("Spell: [spell_name] ([spell_type]) set emote invocation type but did not set an invocation message.")

			if(INVOCATION_SHOUT, INVOCATION_WHISPER)
				if(isnull(initial(spell_type.invocation)))
					Fail("Spell: [spell_name] ([spell_type]) set a speaking invocation type but did not set an invocation message.")

			// INVOCATION_NONE:
			// It doesn't matter what they have set for invocation text. So not it's skipped.
