//Santa spells!
/obj/effect/proc_holder/spell/aoe_turf/conjure/presents
	name = "Conjure Presents!"
	desc = "This spell lets you reach into S-space and retrieve presents! Yay!"
	school = SCHOOL_CONJURATION
	charge_max = 600
	clothes_req = FALSE
	magic_resistances = NONE
	invocation = "HO HO HO"
	invocation_type = INVOCATION_SHOUT
	range = 3
	cooldown_min = 50

	summon_type = list("/obj/item/a_gift")
	summon_lifespan = 0
	summon_amt = 5
