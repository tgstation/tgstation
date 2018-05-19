//Programs specifically engineered to cause harm (as opposed to ones that only do it due to broken programming)
//Very dangerous!

/datum/nanite_program/aggressive_replication
	name = "Aggressive Replication"
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host."
	use_rate = -1 //bonus nanites
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/aggressive_replication/active_effect()
	host_mob.adjustBruteLoss(1, TRUE)

/datum/nanite_program/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	use_rate = 10
	rogue_types = list(/datum/nanite_program/glitch)

/datum/nanite_program/meltdown/active_effect()
	host_mob.adjustFireLoss(3.5)

/datum/nanite_program/meltdown/enable_passive_effect()
	..()
	to_chat(host_mob, "<span class='userdanger'>Your blood is burning!</span>")
	nanites.safety_threshold = 0

/datum/nanite_program/meltdown/disable_passive_effect()
	..()
	to_chat(host_mob, "<span class='warning'>Your blood cools down, and the pain gradually fades.</span>")

/datum/nanite_program/pyro/active_effect()
	host_mob.fire_stacks += 1
	host_mob.IgniteMob()

/datum/nanite_program/pyro
	name = "Sub-Dermal Combustion"
	desc = "The nanites cause buildup of flammable fluids under the host's skin, then ignites them."
	use_rate = 4
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/cryo)

/datum/nanite_program/pyro/check_conditions()
	if(host_mob.fire_stacks >= 10 && host_mob.on_fire)
		return FALSE
	. = ..()

/datum/nanite_program/pyro/active_effect()
	host_mob.fire_stacks += 1
	host_mob.IgniteMob()

/datum/nanite_program/cryo
	name = "Cryogenic Treatment"
	desc = "The nanites rapidly skin heat through the host's skin, lowering their temperature."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/pyro)

/datum/nanite_program/cryo/check_conditions()
	if(host_mob.bodytemperature <= 70)
		return FALSE
	. = ..()

/datum/nanite_program/cryo/active_effect()
	host_mob.adjust_bodytemperature(-rand(15,25), 50)