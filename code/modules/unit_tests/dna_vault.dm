/datum/unit_test/dna_vault_traits_survive_dormant_activator_cleanup/Run()
	var/mob/living/carbon/human/consistent/test_subject = allocate(/mob/living/carbon/human/consistent)

	test_subject.dna.add_mutation(/datum/mutation/adaptation/heat, MUTATION_SOURCE_ACTIVATED)
	TEST_ASSERT(HAS_TRAIT_FROM(test_subject, TRAIT_RESISTHEAT, GENETIC_MUTATION), "Heat adaptation should add heat resistance as a normal genetic mutation.")

	test_subject.dna.add_mutation(/datum/mutation/fire_immunity, MUTATION_SOURCE_DNA_VAULT)
	TEST_ASSERT(HAS_TRAIT_FROM(test_subject, TRAIT_RESISTHEAT, DNA_VAULT_TRAIT), "DNA vault fire immunity should use the DNA vault trait source.")
	TEST_ASSERT(HAS_TRAIT_FROM(test_subject, TRAIT_NOFIRE, DNA_VAULT_TRAIT), "DNA vault fire immunity should add fire immunity with the DNA vault trait source.")

	test_subject.dna.remove_all_mutations(list(MUTATION_SOURCE_GENE_SYMPTOM, MUTATION_SOURCE_ACTIVATED))

	TEST_ASSERT_NULL(test_subject.dna.get_mutation(/datum/mutation/adaptation/heat), "Dormant DNA Activator cleanup should remove normally activated mutations.")
	TEST_ASSERT_NOTNULL(test_subject.dna.get_mutation(/datum/mutation/fire_immunity), "Dormant DNA Activator cleanup should not remove DNA vault mutations.")
	TEST_ASSERT(HAS_TRAIT_FROM(test_subject, TRAIT_RESISTHEAT, DNA_VAULT_TRAIT), "Dormant DNA Activator cleanup should not strip shared DNA vault mutation traits.")
	TEST_ASSERT(HAS_TRAIT_FROM(test_subject, TRAIT_NOFIRE, DNA_VAULT_TRAIT), "Dormant DNA Activator cleanup should not strip DNA vault-only traits.")
