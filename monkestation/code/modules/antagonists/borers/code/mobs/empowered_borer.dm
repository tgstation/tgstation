/**
 * They can only spawn from a dead body that had an egg implanted into it
 * Starts SIGNIFICANTLY stronger than any other option you can get
 */
/mob/living/basic/cortical_borer/empowered
	maxHealth = 150
	health = 150
	health_per_level = 15
	health_regen_per_level = 0.04

	stat_evolution = 8
	chemical_evolution = 8

	max_chemical_storage = 250
	chemical_storage = 250
	chem_regen_per_level = 1.5
	chem_storage_per_level = 25
