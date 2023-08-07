/// Tests that abductors get their baton recall spell when being equipped
/datum/unit_test/abductor_baton_spell

/datum/unit_test/abductor_baton_spell/Run()
	// Test abductor agents get a linked "summon item" spell that marks their baton.
	var/mob/living/carbon/human/ayy = allocate(/mob/living/carbon/human/consistent)
	ayy.equipOutfit(/datum/outfit/abductor/agent)

	var/datum/action/cooldown/spell/summonitem/abductor/summon = locate() in ayy.actions
	TEST_ASSERT_NOTNULL(summon, "Abductor agent does not have summon item spell.")
	TEST_ASSERT(istype(summon.marked_item, /obj/item/melee/baton/abductor), "Abductor agent's summon item spell did not mark their baton.")

	// Also test abductor solo agents also get the spell.
	var/mob/living/carbon/human/ayy_two = allocate(/mob/living/carbon/human/consistent)
	ayy_two.equipOutfit(/datum/outfit/abductor/scientist/onemanteam)

	var/datum/action/cooldown/spell/summonitem/abductor/summon_two = locate() in ayy_two.actions
	TEST_ASSERT_NOTNULL(summon_two, "Abductor solo agent does not have summon item spell.")
	TEST_ASSERT(istype(summon_two.marked_item, /obj/item/melee/baton/abductor), "Abductor solo agent's summon item spell did not mark their baton.")
