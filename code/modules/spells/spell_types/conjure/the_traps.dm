/datum/action/cooldown/spell/conjure/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps around you. They will damage and enrage any enemies that step on them."
	action_icon_state = "the_traps"

	charge_max = 25 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS

	invocation = "CAVERE INSIDIAS"
	invocation_type = INVOCATION_SHOUT
	range = 3

	summon_type = list(
		/obj/structure/trap/stun,
		/obj/structure/trap/fire,
		/obj/structure/trap/chill,
		/obj/structure/trap/damage,
	)
	summon_lifespan = 5 MINUTES
	summon_amount = 5

	/// The amount of charges the traps spawn with.
	var/trap_charges = 1

/datum/action/cooldown/spell/conjure/the_traps/post_summon(atom/summoned_object)
	if(!istype(post_summon, /obj/structure/trap))
		return

	var/obj/structure/trap/summoned_trap = summoned_object
	if(owner.mind)
		summoned_trap.immune_minds += owner.mind
	summoned_trap.charges = trap_charges
