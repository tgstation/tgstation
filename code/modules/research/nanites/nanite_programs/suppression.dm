//Programs that are generally useful for population control and non-harmful suppression.

/datum/nanite_program/paralyzing
	name = "Paralysis"
	desc = "The nanites actively suppress nervous pulses, effectively paralyzing the host."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/paralyzing/active_effect()
	host_mob.Knockdown(30)

/datum/nanite_program/pacifying
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/pacifying/enable_passive_effect()
	..()
	host_mob.add_trait(TRAIT_PACIFISM, "nanites")

/datum/nanite_program/pacifying/disable_passive_effect()
	..()
	host_mob.remove_trait(TRAIT_PACIFISM, "nanites")

/datum/nanite_program/fake_death
	name = "Death Simulation"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/nerve_decay, /datum/nanite_program/necrotic, /datum/nanite_program/brain_decay)

/datum/nanite_program/fake_death/enable_passive_effect()
	..()
	host_mob.emote("deathgasp")
	host_mob.fakedeath("nanites")

/datum/nanite_program/fake_death/disable_passive_effect()
	..()
	host_mob.cure_fakedeath("nanites")
