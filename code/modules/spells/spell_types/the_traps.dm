/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps to confuse and weaken your enemies, and possibly you."

	charge_max = 250
	cooldown_min = 100

	clothes_req = 1
	invocation = "CAVERE INSIDIAS"
	invocation_type = "shout"
	range = 3

	summon_type = list(
		/obj/structure/trap/stun,
		/obj/structure/trap/fire,
		/obj/structure/trap/chill,
		/obj/structure/trap/damage,
		/obj/structure/swarmer/trap
	)
	summon_lifespan = 0
	summon_amt = 5

	action_icon_state = "the_traps"
