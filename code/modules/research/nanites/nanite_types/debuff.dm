//Nanites that annoy or cripple the host.

/datum/reagent/nanites/programmed/paralyzing
	name = "Paralyzing Nanites"
	description = "Keeps the host paralyzed, but decays quickly while active."
	id = "paralyzing_nanites"
	metabolization_rate = 3
	rogue_types = list("nervous_nanites")

/datum/reagent/nanites/programmed/paralyzing/nanite_life(mob/living/M)
	M.Knockdown(30)

/datum/reagent/nanites/programmed/pacifying
	name = "Pacifying Nanites"
	description = "Pacifies the host while active."
	id = "pacifying_nanites"
	metabolization_rate = 1
	rogue_types = list("paralyzing_nanites")

/datum/reagent/nanites/programmed/pacifying/enable_passive_effect()
	..()
	host_mob.add_trait(TRAIT_PACIFISM, "nanites")

/datum/reagent/nanites/programmed/pacifying/disable_passive_effect()
	..()
	host_mob.remove_trait(TRAIT_PACIFISM, "nanites")

/datum/reagent/nanites/programmed/fake_death
	name = "Death Simulation Nanites"
	description = "Causes the host to fall into a near-death coma."
	id = "fakedeath_nanites"
	metabolization_rate = 3.5
	rogue_types = list("paralyzing_nanites","necrotic_nanites","braindecay_nanites")

/datum/reagent/nanites/programmed/fake_death/enable_passive_effect()
	..()
	host_mob.emote("deathgasp")
	host_mob.fakedeath("nanites")

/datum/reagent/nanites/programmed/fake_death/disable_passive_effect()
	..()
	host_mob.cure_fakedeath("nanites")
