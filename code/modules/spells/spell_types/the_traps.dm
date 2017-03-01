/obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps to confuse and weaken your enemies, and possibly you."
	school = "conjuration" // no one uses this var

	charge_max = 650
	clothes_req = 1
	invocation = "THE TRAPS"
	invocation_type = "shout"
	range = 3
	cooldown_min = 15

	summon_type = list(
		/obj/structure/trap/stun,
		/obj/structure/trap/fire,
		/obj/structure/trap/chill,
		/obj/structure/trap/damage,
		/obj/structure/swarmer/trap
	)
	summon_lifespan = 0
	summon_amt = 5
