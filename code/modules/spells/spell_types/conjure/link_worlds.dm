/obj/effect/proc_holder/spell/aoe_turf/conjure/link_worlds
	name = "Link Worlds"
	desc = "A whole new dimension for you to play with! They won't be happy about it, though."

	sound = 'sound/weapons/marauder.ogg'
	charge_max = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "WTF"
	spell_requirements = NONE
	range = 1

	summon_type = list(/obj/structure/spawner/nether)
	summon_amount = 1
