/**
 * Tests that actions assigned to a mob's mind
 * are successfuly transferred when their mind is transferred to a new mob.
 */
/datum/unit_test/actions_moved_on_mind_transfer

/datum/unit_test/actions_moved_on_mind_transfer/Run()
	var/mob/living/carbon/human/wizard = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/basic/pet/dog/corgi/wizard_dog = allocate(/mob/living/basic/pet/dog/corgi)
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
