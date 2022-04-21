//Santa spells!
/obj/effect/proc_holder/spell/aoe_turf/conjure/presents
	name = "Conjure Presents!"
	desc = "This spell lets you reach into S-space and retrieve presents! Yay!"
	school = SCHOOL_CONJURATION
	charge_max = 600
	clothes_req = FALSE
	invocation = "HO HO HO"
	invocation_type = INVOCATION_SHOUT
	range = 3
	cooldown_min = 50
	antimagic_flags = NONE

	summon_type = list("/obj/item/a_gift")
	summon_lifespan = 0
	summon_amt = 5

/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/santa
	name = "Santa Teleport"

	invocation = "HO HO HO"
	clothes_req = FALSE
	say_destination = FALSE // Santa moves in mysterious ways
	antimagic_flags = NONE
